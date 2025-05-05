# 🚀 GitHub Repos Cloner

A powerful and flexible command-line tool to clone all repositories from any GitHub user in seconds.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Homebrew](https://img.shields.io/badge/Homebrew-Available-orange.svg)](https://brew.sh)

## ✨ Features

- Quickly clone all repositories from any GitHub user
- Support for both HTTPS and SSH protocols
- Option to limit the number of repositories to clone
- Ability to skip forked repositories
- Colorful and beautiful terminal interface
- Progress bar to track the cloning process
- Quick commands for faster usage (`ghc`, `ghcs`)

## 📋 Requirements

- [Git](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/)
- [jq](https://stedolan.github.io/jq/download/)

## 💻 Installation

### Via Homebrew (Recommended)

```bash
# Install GitHub CLI and jq if you don't have them
brew install gh jq

# Install ghclone
brew tap uchkunrakhimow/tools
brew install ghclone
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/uchkunrakhimow/ghclone.git
```

2. Make the script executable:

```bash
chmod +x ghclone
```

3. Move the script to your PATH for system-wide access:

```bash
sudo mv ghclone /usr/local/bin/
```

4. Create symbolic links for quick commands:

```bash
sudo ln -s /usr/local/bin/ghclone /usr/local/bin/ghc
sudo ln -s /usr/local/bin/ghclone /usr/local/bin/ghcs
```

## 🚀 Usage

### Basic Commands

```bash
# Full command
ghclone -u username

# Quick command
ghc username

# Clone only non-forked repositories (quick)
ghcs username
```

### All Options

```
USAGE:
  ghclone [OPTIONS] -u USERNAME

OPTIONS:
  -u, --username USERNAME    GitHub username (required)
  -o, --output-dir DIR       Output directory (default: USERNAME-repos)
  -p, --protocol PROTOCOL    Clone protocol: https or ssh (default: https)
  -l, --limit LIMIT          Maximum number of repositories to clone (default: 1000)
  -s, --skip-forks           Skip forked repositories
  -q, --quiet                Suppress verbose output
  -v, --version              Show version information
  -h, --help                 Display this help message and exit
```

### Example Commands

Clone all repositories from a user:

```bash
ghclone -u octocat
```

Clone repositories using SSH:

```bash
ghclone -u octocat -p ssh
```

Clone only original repositories (no forks):

```bash
ghclone -u octocat -s
```

Or with the quick command:

```bash
ghcs octocat
```

Specify output directory:

```bash
ghclone -u octocat -o my-octocat-repos
```

Limit the number of repositories:

```bash
ghclone -u octocat -l 10
```

## 🔑 Authentication

The script uses GitHub CLI for authentication. Before running the script, make sure you're authenticated with GitHub CLI:

```bash
gh auth login
```

## ⚙️ Error Handling

The script includes comprehensive error handling:

- Checks if required tools (GitHub CLI, jq) are installed
- Verifies GitHub CLI authentication status
- Validates command-line arguments
- Handles repository cloning failures gracefully
- Provides progress tracking with a visual progress bar

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [GitHub CLI](https://cli.github.com/) for providing a powerful API
- [jq](https://stedolan.github.io/jq/) for JSON processing
