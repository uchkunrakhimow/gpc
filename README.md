# GitHub Repository Cloner

A powerful and flexible command-line tool to clone all repositories from a specified GitHub user.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- Clone all repositories from any GitHub user
- Support for both HTTPS and SSH protocols
- Options to limit the number of repositories
- Ability to skip forked repositories
- Verbose output control
- Easy-to-use command-line interface

## Prerequisites

- [Git](https://git-scm.com/downloads) (version 2.0.0 or higher)
- [GitHub CLI](https://cli.github.com/) (version 2.0.0 or higher)
- [jq](https://stedolan.github.io/jq/download/) (version 1.6 or higher)

## Installation

1. Clone this repository:

```bash
git clone https://github.com/uchkunrakhimow/github-repo-cloner.git
```

2. Make the script executable:

```bash
chmod +x github-repo-cloner.sh
```

3. (Optional) Move the script to your PATH for system-wide access:

```bash
sudo mv github-repo-cloner.sh /usr/local/bin/github-repo-cloner
```

## Usage

```bash
./github-repo-cloner.sh [OPTIONS]
```

### Options

- `-u, --username USERNAME` - GitHub username (required)
- `-o, --output-dir DIR` - Output directory (default: USERNAME-repos)
- `-p, --protocol PROTOCOL` - Clone protocol: https or ssh (default: https)
- `-l, --limit LIMIT` - Maximum number of repositories to clone (default: 1000)
- `-s, --skip-forks` - Skip forked repositories
- `-q, --quiet` - Suppress verbose output
- `-h, --help` - Display help message and exit

### Examples

Clone all repositories from a user:

```bash
./github-repo-cloner.sh --username octocat
```

Clone repositories using SSH:

```bash
./github-repo-cloner.sh --username octocat --protocol ssh
```

Clone only original repositories (no forks):

```bash
./github-repo-cloner.sh --username octocat --skip-forks
```

Specify output directory:

```bash
./github-repo-cloner.sh --username octocat --output-dir my-octocat-repos
```

Limit the number of repositories:

```bash
./github-repo-cloner.sh --username octocat --limit 10
```

## Authentication

The script uses GitHub CLI for authentication. Before running the script, make sure you're authenticated with GitHub CLI:

```bash
gh auth login
```

## Error Handling

The script includes comprehensive error handling:

- Checks if required tools (GitHub CLI, jq) are installed
- Verifies GitHub CLI authentication status
- Validates command-line arguments
- Handles repository cloning failures gracefully

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [GitHub CLI](https://cli.github.com/) for providing a powerful API
- [jq](https://stedolan.github.io/jq/) for JSON processing
