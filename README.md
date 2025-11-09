# Terminal Setup

A macOS terminal setup script that automates the installation and configuration of essential development tools and a beautiful terminal prompt.

## Overview

This project provides an automated, non-interactive setup script for macOS that installs and configures:

- **Homebrew** - Package manager for macOS
- **Git** - Version control system
- **uv** - Fast Python package installer and resolver
- **Python 3.13** - Latest Python version via uv
- **Starship** - Cross-shell prompt with custom Catppuccin Mocha theme
- **Oh My Zsh** - Zsh configuration framework

## Features

- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Non-interactive** - Minimal user input required
- ✅ **Automatic backups** - Existing configs are backed up before overwriting
- ✅ **Custom Starship prompt** - Beautiful Catppuccin Mocha themed prompt
- ✅ **Cross-architecture** - Supports both Intel and Apple Silicon Macs

## Prerequisites

- macOS (Darwin)
- zsh shell
- Internet connection
- Admin privileges (for Homebrew installation)

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/mehta-raghav/terminal-setup.git
   cd terminal-setup
   ```

2. Run the setup script:
   ```bash
   zsh setup.sh
   ```

3. Reload your shell:
   ```bash
   exec $SHELL -l
   ```

## What Gets Installed

### Core Tools
- **Homebrew** - Installed to `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
- **Git** - Latest version via Homebrew
- **uv** - Python package manager via Homebrew
- **Python 3.13** - Installed and pinned via uv
- **Starship** - Prompt engine via Homebrew

### Shell Configuration
- **Oh My Zsh** - Installed in unattended mode
- **Starship prompt** - Configured with custom theme
- **PATH setup** - Homebrew and uv added to PATH in `.zprofile` and `.zshrc`

## Configuration

### Starship Prompt

The script downloads `config/starship.toml` from this repository and installs it to `~/.config/starship.toml`. The configuration includes:

- **Theme**: Catppuccin Mocha color palette
- **Modules**: OS, username, directory, git branch/status, Python version, conda environment, memory usage, and time
- **Custom formatting**: Powerline-style prompt with smooth transitions

### Customization

To customize the setup, edit the variables at the top of `setup.sh`:

```bash
STARSHIP_GH_USER="mehta-raghav"           # Your GitHub username
STARSHIP_GH_REPO="terminal-setup"         # Repository name
STARSHIP_GH_BRANCH="main"                 # Branch name
STARSHIP_FILE_PATH="config/starship.toml" # Path to starship config
```

### Additional .zshrc

The script attempts to fetch `config/.zshrc` from the same repository. If you want to use a custom `.zshrc`, add it to `config/.zshrc` in this repository.

## File Structure

```
terminal-setup/
├── setup.sh              # Main setup script
├── config/
│   └── starship.toml     # Starship prompt configuration
└── README.md             # This file
```

## What the Script Does

1. **Validates environment** - Ensures macOS and zsh
2. **Requests admin privileges** - Keeps sudo alive during installation
3. **Installs Xcode Command Line Tools** - Required for Homebrew
4. **Installs Homebrew** - Non-interactive installation
5. **Installs core tools** - Git, uv, and Starship via Homebrew
6. **Sets up Python 3.13** - Installs and pins via uv
7. **Configures Starship** - Downloads config from GitHub or uses preset fallback
8. **Installs Oh My Zsh** - Unattended installation
9. **Fetches .zshrc** - Downloads custom zsh config if available
10. **Verifies installation** - Displays versions of installed tools

## Safety Features

- **Backup creation** - Existing configs are backed up with timestamps before overwriting
- **Idempotent operations** - Safe to run multiple times
- **Error handling** - Script exits on errors with clear messages
- **Fallback options** - Uses Starship preset if config download fails

## Troubleshooting

### Script fails with "This script is for macOS"
- Ensure you're running on macOS (Darwin)
- Run with zsh: `zsh setup.sh`

### Homebrew installation fails
- Check your internet connection
- Ensure Xcode Command Line Tools are installed
- Try running: `xcode-select --install`

### Starship config not loading
- Verify the GitHub repository is public
- Check that `config/starship.toml` exists in the repository
- The script will fall back to a preset if download fails

### Python version issues
- After installation, reload your shell: `exec $SHELL -l`
- Verify with: `uv run python -V`
- Should show Python 3.13.x

## License

This project is open source and available for personal use.

## Contributing

Feel free to fork this repository and customize it for your own needs. If you have improvements, pull requests are welcome!

## Author

Created by [mehta-raghav](https://github.com/mehta-raghav)

