#!/bin/sh

# Start with the source file
cat pikkuwiki.sh > pikkuwiki

# Append run call
cat <<'EOF' >> pikkuwiki
run_pikkuwiki "$@"
EOF

# Make it executable
chmod +x pikkuwiki
