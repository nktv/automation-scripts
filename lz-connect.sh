#!/bin/bash

prefix=$1

# Validate input
if [ -z "$prefix" ]; then
    echo "Usage: lz-connect <group>"
    echo "Example: lz-connect scriptengine"
    exit 1
fi

# Extract host + IP
HOSTS=$(awk -v p="$prefix" '
$1=="Host" {host=$2}
$1=="HostName" && host ~ p"-[0-9]+$" {
    print host " " $2
}
' ~/.ssh/config)

# Check if empty
if [ -z "$HOSTS" ]; then
    echo "No instances found for prefix: $prefix"
    exit 1
fi

echo "$prefix instances found: $(echo "$HOSTS" | wc -l)"
echo "------------------------"

# Show numbered list
echo "$HOSTS" | nl -w2 -s'. '

echo ""
read -p "Select instance: " choice

# Validate number input
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid input"
    exit 1
fi

# Get selected line
SELECTED_LINE=$(echo "$HOSTS" | sed -n "${choice}p")

# Extract only hostname
SELECTED_HOST=$(echo "$SELECTED_LINE" | awk '{print $1}')

if [ -n "$SELECTED_HOST" ]; then
    echo "Connecting to $SELECTED_HOST..."
    ssh "$SELECTED_HOST"
else
    echo "Invalid selection"
fi
