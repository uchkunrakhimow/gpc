#!/bin/bash
#
# github-repo-cloner - Clone all repositories from a specified GitHub user
#
# Author: Uchkun Rakhimov
# Version: 1.0.0
# License: MIT

# Default values
USERNAME=""
OUTPUT_DIR=""
CLONE_PROTOCOL="https"
LIMIT=1000
SKIP_FORKS=false
VERBOSE=true

# Print usage information
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Clone all repositories from a specified GitHub user."
    echo
    echo "Options:"
    echo "  -u, --username USERNAME    GitHub username (required)"
    echo "  -o, --output-dir DIR       Output directory (default: USERNAME-repos)"
    echo "  -p, --protocol PROTOCOL    Clone protocol: https or ssh (default: https)"
    echo "  -l, --limit LIMIT          Maximum number of repositories to clone (default: 1000)"
    echo "  -s, --skip-forks           Skip forked repositories"
    echo "  -q, --quiet                Suppress verbose output"
    echo "  -h, --help                 Display this help message and exit"
    echo
    echo "Example:"
    echo "  $0 --username octocat --output-dir my-repos --protocol ssh"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -p|--protocol)
            if [[ "$2" == "https" || "$2" == "ssh" ]]; then
                CLONE_PROTOCOL="$2"
                shift 2
            else
                echo "Error: Protocol must be 'https' or 'ssh'" >&2
                exit 1
            fi
            ;;
        -l|--limit)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                LIMIT="$2"
                shift 2
            else
                echo "Error: Limit must be a positive number" >&2
                exit 1
            fi
            ;;
        -s|--skip-forks)
            SKIP_FORKS=true
            shift
            ;;
        -q|--quiet)
            VERBOSE=false
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed." >&2
    echo "Please install it from https://cli.github.com/" >&2
    exit 1
fi

# Check if GitHub CLI is authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: GitHub CLI is not authenticated." >&2
    echo "Please run 'gh auth login' to authenticate." >&2
    exit 1
fi

# Check if username is provided
if [[ -z "$USERNAME" ]]; then
    echo "Error: GitHub username is required." >&2
    print_usage
    exit 1
fi

# Set output directory if not specified
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="${USERNAME}-repos"
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create output directory: $OUTPUT_DIR" >&2
    exit 1
fi

# Change to output directory
cd "$OUTPUT_DIR" || {
    echo "Error: Failed to change to output directory: $OUTPUT_DIR" >&2
    exit 1
}

# Log information
if [[ "$VERBOSE" = true ]]; then
    echo "GitHub username: $USERNAME"
    echo "Output directory: $OUTPUT_DIR"
    echo "Clone protocol: $CLONE_PROTOCOL"
    echo "Repository limit: $LIMIT"
    echo "Skip forks: $SKIP_FORKS"
    echo "Fetching repositories..."
fi

# Query parameters for GitHub CLI
QUERY_PARAMS="--limit $LIMIT"
if [[ "$SKIP_FORKS" = true ]]; then
    QUERY_PARAMS="$QUERY_PARAMS --no-forks"
fi

# JSON fields to fetch
JSON_FIELDS="nameWithOwner,isFork,description"

# Fetch repositories
REPOS=$(gh repo list "$USERNAME" $QUERY_PARAMS --json "$JSON_FIELDS" --jq '.[]')

# Check if any repositories were found
if [[ -z "$REPOS" ]]; then
    echo "No repositories found for user: $USERNAME" >&2
    exit 1
fi

# Clone repositories
echo "$REPOS" | while read -r repo_data; do
    repo_name=$(echo "$repo_data" | jq -r '.nameWithOwner')
    is_fork=$(echo "$repo_data" | jq -r '.isFork')
    description=$(echo "$repo_data" | jq -r '.description')
    
    # Skip forks if requested
    if [[ "$SKIP_FORKS" = true && "$is_fork" = true ]]; then
        if [[ "$VERBOSE" = true ]]; then
            echo "Skipping fork: $repo_name"
        fi
        continue
    fi
    
    if [[ "$VERBOSE" = true ]]; then
        echo "Cloning $repo_name..."
        if [[ -n "$description" && "$description" != "null" ]]; then
            echo "Description: $description"
        fi
    fi
    
    # Clone repository
    if [[ "$CLONE_PROTOCOL" == "https" ]]; then
        git clone "https://github.com/$repo_name.git"
    else
        git clone "git@github.com:$repo_name.git"
    fi
    
    if [[ $? -ne 0 ]]; then
        echo "Warning: Failed to clone repository: $repo_name" >&2
    elif [[ "$VERBOSE" = true ]]; then
        echo "Successfully cloned $repo_name"
        echo
    fi
done

if [[ "$VERBOSE" = true ]]; then
    echo "All repositories have been cloned to: $OUTPUT_DIR"
fi

exit 0