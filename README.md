# Giti
### Simplify Your Git Workflow

<div align="center">

[![GitHub license](https://img.shields.io/github/license/mohsen-karami/giti)](https://github.com/mohsen-karami/giti/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mohsen-karami/giti)](https://github.com/mohsen-karami/giti/stargazers)
[![GitHub release](https://img.shields.io/github/release/mohsen-karami/giti)](https://github.com/mohsen-karami/giti/releases)

</div>

Giti is a powerful Git utility tailored to streamline your Git operations. Its user-friendly interactive interface ensures consistent commit formatting and addresses scenarios that are prone to causing conflicts and issues throughout the entire process of handling code updates and modifications. This results in a clean and organized commit history, enhancing overall team collaboration and productivity.

> **Warning:** Giti is currently in **EXPERIMENTAL** phase. Use with caution and at your own risk.

> **Note:** I strongly recommend testing commands on a trial repository first. Currently, only standard scenarios are supported - verify procedures for complex cases.

## Key Features

- Interactive interface
- Advanced and consistent commit formatting
- Effortless code change management
- Clean and organized commit history
- Powerful CLI with extensive options
- Enhanced team collaboration

## Installation

You can install Giti using one of the following methods:

### Method 1 (Recommended) - Download and verify first:
```bash
# Download the installation script
curl -sSLO https://github.com/mohsen-karami/giti/raw/master/install.sh

# Review the script content (recommended for security)
cat install.sh

# Run the installation with sudo
sudo bash install.sh
```

### Method 2 - Direct installation:
```bash
curl -sSL https://github.com/mohsen-karami/giti/raw/master/install.sh | sudo bash
```

> **⚠️ Security Note**: Method 1 is recommended as it allows you to review the script before execution. Method 2 is more convenient but less secure as it runs the script directly without inspection.

> **Note**: The installation requires sudo privileges to:
> - Install files in system directories for all users
> - Set proper executable permissions
> - Install required dependencies if needed


After the installation is complete, you can run the app using the `giti` command from your terminal.

## Command Reference

### giti fresh
Creates a new branch and sets up remote upstream tracking.

**Options:**
- `-n, --name <branch-name>` (Required): Specifies the name for the new branch
- `-b, --branch <source-branch>`: Sets the starting point for the new branch (defaults to current branch)
- `--push`: Creates remote repository, sets upstream, and pushes changes in one step
### giti push
Stages files, creates commits, and pushes changes to remote repository.

**Basic Usage:**
- `giti push`: Stages all changes, prompts for commit message, and pushes
- `giti push -i, --initial`: Sets up remote upstream tracking for new branches
- `giti push --staged`: Pushes only previously staged changes

**Advanced Options:**
- `-r, --revise <number>`: Rewrites last N commits with a new commit (force push)
- `-m, --merge <number>`: Merges working changes with last N commits (force push)
- `--manual`: Allows manual editing of commits before pushing (with -r/-m options)
- `--temp`: Creates temporary commit for work in progress
- `-a, --append`: Adds changes to previous commit (force push)
- `-t <tag-name>`: Tags latest commit (use --hash for specific commit)

> ⚠️ Options with force push are potentially destructive. Use with caution.
### giti remove
Removes branches locally and remotely.

**Options:**
- `-b, --branch <branch-name>`: Removes specified branch
- `-cb, --current-branch`: Removes currently checked out branch
### giti setup
Configures Git identity settings.

**Options:**
- Default: Configure name and email (local/global)
- `--clear`: Removes existing Git identity configuration

## License
Giti is licensed under the GPLv3 license. See [LICENSE](https://github.com/mohsen-karami/giti/blob/master/LICENSE) for more information.
