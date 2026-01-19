#!/bin/bash
# Check for domain documentation and provide context to Claude

set -euo pipefail

# Read input from stdin (hook input JSON)
input=$(cat)

# Get project directory
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
domain_docs_dir="$project_dir/docs/domain"

# Check if domain documentation exists
if [ -d "$domain_docs_dir" ]; then
  # Count documentation files
  doc_count=$(find "$domain_docs_dir" -name "*.md" 2>/dev/null | wc -l)

  if [ "$doc_count" -gt 0 ]; then
    # Domain docs exist - inform Claude
    echo "{\"systemMessage\": \"Domain documentation found at docs/domain/ ($doc_count files). Reference this documentation when working on features to ensure consistency with the established domain model and ubiquitous language.\"}"
  else
    # Directory exists but no docs
    echo "{\"systemMessage\": \"Domain documentation directory exists at docs/domain/ but contains no .md files. Consider running /ddd:explore to document the domain model.\"}"
  fi
else
  # No domain docs - silent (don't nag on every project)
  echo "{}"
fi

exit 0
