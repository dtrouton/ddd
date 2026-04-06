#!/bin/bash
# Lightweight drift check that runs on session start.
# Compares documented bounded contexts against actual code modules
# and reports obvious mismatches as a system message.

set -euo pipefail

input=$(cat)

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
domain_docs_dir="$project_dir/docs/domain"
bc_file="$domain_docs_dir/bounded-contexts.md"
events_file="$domain_docs_dir/events.md"

# Only run if domain docs exist
if [ ! -f "$bc_file" ]; then
  echo "{}"
  exit 0
fi

warnings=()

# --- Check 1: Extract documented context names and look for matching code ---
# Pull context names from "### ContextName" headings under "## Contexts"
documented_contexts=$(grep -E '^### ' "$bc_file" 2>/dev/null | sed 's/^### //' | tr -d '\r' || true)

if [ -n "$documented_contexts" ]; then
  # Find top-level source directories (common patterns)
  src_dirs=""
  for candidate in src app lib pkg internal; do
    dir="$project_dir/$candidate"
    if [ -d "$dir" ]; then
      # List immediate subdirectories as potential context modules
      modules=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null || true)
      if [ -n "$modules" ]; then
        src_dirs="$modules"
      fi
    fi
  done

  # Check for undocumented code modules (only if we found source dirs)
  if [ -n "$src_dirs" ]; then
    while IFS= read -r module; do
      # Normalize: lowercase, replace hyphens/underscores with spaces for comparison
      module_normalized=$(echo "$module" | tr '[:upper:]' '[:lower:]' | tr '-_' '  ')
      found=false
      while IFS= read -r context; do
        context_normalized=$(echo "$context" | tr '[:upper:]' '[:lower:]' | tr '-_' '  ')
        if [[ "$module_normalized" == *"$context_normalized"* ]] || [[ "$context_normalized" == *"$module_normalized"* ]]; then
          found=true
          break
        fi
      done <<< "$documented_contexts"
      if [ "$found" = false ]; then
        # Skip common non-context directories
        case "$module" in
          common|shared|utils|config|test|tests|__pycache__|node_modules|dist|build) ;;
          *) warnings+=("Module '$module' exists in code but has no matching documented bounded context") ;;
        esac
      fi
    done <<< "$src_dirs"
  fi
fi

# --- Check 2: Look for event classes not in the events catalog ---
if [ -f "$events_file" ]; then
  documented_events=$(grep -E '^### ' "$events_file" 2>/dev/null | sed 's/^### //' | tr -d '\r' || true)

  if [ -n "$documented_events" ]; then
    # Search for event-like class definitions in source code
    for candidate in src app lib pkg internal; do
      dir="$project_dir/$candidate"
      if [ -d "$dir" ]; then
        # Find files with "Event" in name or event-like class definitions
        code_events=$(grep -rEoh '(class|type|interface|data class|record)\s+\w+(Event|Created|Placed|Updated|Deleted|Cancelled|Failed|Completed|Shipped|Received|Registered|Changed|Depleted|Reserved|Authorized)\b' "$dir" 2>/dev/null | sed -E 's/(class|type|interface|data class|record)\s+//' | sort -u || true)

        if [ -n "$code_events" ]; then
          while IFS= read -r event_class; do
            found=false
            while IFS= read -r doc_event; do
              if [ "$event_class" = "$doc_event" ]; then
                found=true
                break
              fi
            done <<< "$documented_events"
            if [ "$found" = false ]; then
              warnings+=("Event '$event_class' found in code but not in the domain events catalog")
            fi
          done <<< "$code_events"
        fi
      fi
    done
  fi
fi

# --- Output ---
if [ ${#warnings[@]} -gt 0 ]; then
  warning_text="Domain drift detected:\\n"
  for w in "${warnings[@]}"; do
    warning_text+="- $w\\n"
  done
  warning_text+="\\nRun /ddd:drift for a full drift analysis."
  echo "{\"systemMessage\": \"$warning_text\"}"
else
  echo "{}"
fi

exit 0
