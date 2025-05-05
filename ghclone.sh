#!/bin/bash

# Version
VERSION="1.0.0"

# Default values
USERNAME=""
OUTPUT_DIR=""
CLONE_PROTOCOL="https"
LIMIT=1000
SKIP_FORKS=false
VERBOSE=true

# Color codes for better output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage information with improved formatting
print_usage() {
    echo -e "${BLUE}GitHub Repos Cloner v$VERSION${NC}"
    echo -e "Clone all repositories from a GitHub user easily.\n"
    echo -e "${GREEN}USAGE:${NC}"
    echo -e "  ghclone [OPTIONS] -u USERNAME\n"
    echo -e "${GREEN}OPTIONS:${NC}"
    echo -e "  ${YELLOW}-u, --username${NC} USERNAME    GitHub username (required)"
    echo -e "  ${YELLOW}-o, --output-dir${NC} DIR       Output directory (default: USERNAME-repos)"
    echo -e "  ${YELLOW}-p, --protocol${NC} PROTOCOL    Clone protocol: https or ssh (default: https)"
    echo -e "  ${YELLOW}-l, --limit${NC} LIMIT          Maximum number of repositories to clone (default: 1000)"
    echo -e "  ${YELLOW}-s, --skip-forks${NC}           Skip forked repositories"
    echo -e "  ${YELLOW}-q, --quiet${NC}                Suppress verbose output"
    echo -e "  ${YELLOW}-v, --version${NC}              Show version information"
    echo -e "  ${YELLOW}-h, --help${NC}                 Display this help message and exit\n"
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo -e "  ghclone -u octocat                 # Clone with default settings"
    echo -e "  ghclone -u octocat -o my-repos -p ssh  # Use SSH and custom directory"
    echo -e "  ghclone -u octocat -s -q           # Skip forks and use quiet mode\n"
    echo -e "${GREEN}SHORTCUTS:${NC}"
    echo -e "  ghc USERNAME                       # Quick clone with defaults"
    echo -e "  ghcs USERNAME                      # Quick clone with defaults, skipping forks"
}

# Print version information
print_version() {
    echo "GitHub Repos Cloner v$VERSION"
}

# Handle shortcut commands
if [ "$#" -eq 1 ] && [[ "$1" != -* ]]; then
    # Single argument that's not an option - treat as username
    USERNAME="$1"
    # Other defaults are already set
elif [ "$#" -eq 1 ] && [ "$1" == "help" ]; then
    print_usage
    exit 0
elif [ "$0" == *"ghcs" ] || [ "$1" == "s" ]; then
    # If called as ghcs or with 's' shortcut, enable skip forks
    SKIP_FORKS=true
    if [ "$1" == "s" ]; then
        shift
    fi
    # If there's another argument, treat it as username
    if [ "$#" -eq 1 ] && [[ "$1" != -* ]]; then
        USERNAME="$1"
    fi
fi

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
                echo -e "${RED}Error: Protocol must be 'https' or 'ssh'${NC}" >&2
                exit 1
            fi
            ;;
        -l|--limit)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                LIMIT="$2"
                shift 2
            else
                echo -e "${RED}Error: Limit must be a positive number${NC}" >&2
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
        -v|--version)
            print_version
            exit 0
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            print_usage
            exit 1
            ;;
    esac
done

# Show progress of operation
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local completed=$((percent / 2))
    local remaining=$((50 - completed))
    
    # Create progress bar
    printf "\r[%-${completed}s%-${remaining}s] %d%%" "$(printf '%0.s#' $(seq 1 $completed))" "$(printf '%0.s ' $(seq 1 $remaining))" "$percent"
}

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}" >&2
    echo -e "Please install it with: ${YELLOW}brew install gh${NC}" >&2
    exit 1
fi

# Check if GitHub CLI is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}" >&2
    echo -e "Please run: ${YELLOW}gh auth login${NC} to authenticate." >&2
    exit 1
fi

# Check if username is provided
if [[ -z "$USERNAME" ]]; then
    echo -e "${RED}Error: GitHub username is required.${NC}" >&2
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
    echo -e "${RED}Error: Failed to create output directory: $OUTPUT_DIR${NC}" >&2
    exit 1
fi

# Change to output directory
cd "$OUTPUT_DIR" || {
    echo -e "${RED}Error: Failed to change to output directory: $OUTPUT_DIR${NC}" >&2
    exit 1
}

# Log information
if [[ "$VERBOSE" = true ]]; then
    echo -e "${BLUE}GitHub Repos Cloner${NC}"
    echo -e "${GREEN}Username:${NC} $USERNAME"
    echo -e "${GREEN}Output directory:${NC} $OUTPUT_DIR"
    echo -e "${GREEN}Clone protocol:${NC} $CLONE_PROTOCOL"
    echo -e "${GREEN}Repository limit:${NC} $LIMIT"
    echo -e "${GREEN}Skip forks:${NC} $SKIP_FORKS"
    echo -e "${YELLOW}Fetching repositories...${NC}"
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
    echo -e "${RED}No repositories found for user: $USERNAME${NC}" >&2
    exit 1
fi

# Count total repositories for progress display
TOTAL_REPOS=$(echo "$REPOS" | wc -l | tr -d '[:space:]')
CURRENT_REPO=0
CLONED_REPOS=0

# Clone repositories
echo "$REPOS" | while read -r repo_data; do
    CURRENT_REPO=$((CURRENT_REPO + 1))
    
    repo_name=$(echo "$repo_data" | jq -r '.nameWithOwner')
    is_fork=$(echo "$repo_data" | jq -r '.isFork')
    description=$(echo "$repo_data" | jq -r '.description')
    
    # Skip forks if requested
    if [[ "$SKIP_FORKS" = true && "$is_fork" = true ]]; then
        if [[ "$VERBOSE" = true ]]; then
            echo -e "\r${YELLOW}Skipping fork: $repo_name${NC}                                      "
        fi
        continue
    fi
    
    if [[ "$VERBOSE" = true ]]; then
        echo -e "\r${GREEN}Cloning ${BLUE}$repo_name${NC} ($CURRENT_REPO/$TOTAL_REPOS)             "
        if [[ -n "$description" && "$description" != "null" ]]; then
            echo -e "${YELLOW}Description:${NC} $description"
        fi
        show_progress $CURRENT_REPO $TOTAL_REPOS
    fi
    
    # Clone repository
    if [[ "$CLONE_PROTOCOL" == "https" ]]; then
        git clone "https://github.com/$repo_name.git" --quiet
    else
        git clone "git@github.com:$repo_name.git" --quiet
    fi
    
    if [[ $? -ne 0 ]]; then
        echo -e "\r${RED}Warning: Failed to clone repository: $repo_name${NC}                      " >&2
    else
        CLONED_REPOS=$((CLONED_REPOS + 1))
        if [[ "$VERBOSE" = true ]]; then
            echo -e "\r${GREEN}Successfully cloned ${BLUE}$repo_name${NC}                          "
        fi
    fi
done

echo -e "\n${GREEN}Completed!${NC} Cloned $CLONED_REPOS repositories to: $OUTPUT_DIR"

exit 0