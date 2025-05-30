# Gish - Git Command Helper

**Gish** is a powerful and user-friendly Bash script designed to simplify common Git operations and streamline workflows through intuitive commands and interactive prompts.

**Design Philosophy:**

Gish is primarily aimed at **individual developers** to efficiently synchronize their local workspace with remote repositories. By replacing complex Git commands with simpler, more intuitive operations, developers can focus more on coding.

## Version

Please refer to the source code (`ver: n.n.n` line at the top of the script).

## Important Notice

Gish must be executed from the root directory of your Git repository. Running Gish from a subdirectory may lead to unexpected behavior or errors that prevent proper Git operations. Please ensure that you navigate to the repository's root before executing the script.

## Recent Topics

*   Automatically move to the target branch after pulling with `gish --p`
*   Exclude the current branch from the branch selection list in `gish --p` and `gish`
*   Improved output for `gish --d` (statistics information and detailed diff selection, pager support, color display)
*   Changed the output format of `Change statistics` to user-friendly English

## Features

### `--s <stash_name>`: Save and Apply Named Stash

By specifying a stash name after the `--s` option, you can save the current state of the working directory and index as a named stash and apply it immediately. This allows for smooth saving and restoring of temporary changes, enhancing workflow efficiency.

**Example:** `gish --s my_stash_name` saves the current state as "my_stash_name" and applies it immediately, displaying the latest stash list.

*   Spaces cannot be used in the stash name.
*   If the stash name is omitted, it will automatically be named "yyyymmddhhmmss" (date and time).

### `--l`: Rollback to Stash@{0}

Using the `--l` option rolls back to the state of the most recent stash, `stash@{0}`, discarding all subsequent changes. This is useful when you want to quickly revert to the previous state.

**Example:** Executing `gish --l` displays a confirmation prompt and then rolls back the working directory state to `stash@{0}`. **Note:** All changes made after the rollback will be completely deleted.

### `--p`: Easy Pull from Remote

The `--p` option provides a simple way to pull the latest changes from the remote repository and discard all local changes. This is useful when you want to always synchronize with the remote repository without worrying about local changes.

**Example:** Executing `gish --p` performs the following steps:

1.  Fetch remote repository information (fetch --all --prune)
2.  Select the branch to pull from the list of remote branches (interactive selection menu)
3.  Discard local changes (reset --hard HEAD)
4.  Move to the selected remote branch (checkout -b or checkout)
5.  Reset the local branch to the state of the remote branch (reset --hard origin/branch_name)

### `--d`: Display Differences with Remote Repository (Diff)

The `--d` option displays detailed differences between the local working directory and the remote repository. This is useful for reviewing changes.

**Features:**

*   **Statistics Information:** Initially displays change statistics (added lines, deleted lines, changed files)
*   **Detailed Diff Display:**
    *   **Selective Display:**
        *   Choose to display the entire diff or only the statistics information
        *   If the entire diff is chosen, select from the following display modes:
            *   Display only the first N lines (specify the number of lines)
            *   Display the entire text with a pager (`less`) with color support
            *   Cancel
    *   **Color Display:** Color-coded display of file names, hunk headers, added lines, and deleted lines (improved readability)

### Automatic Commit Message Generation with OpenAI

Gish includes a feature that **automatically generates commit messages using the OpenAI API**. This reduces the time spent on creating commit messages and supports more efficient committing.

**Features:**

*   **AI Automatic Generation:** Analyzes the content of `git diff` and automatically generates an appropriate commit message
*   **Message Confirmation:** Allows review and editing of the generated message
*   **Manual Input Fallback:** Allows manual input of commit messages even if the OpenAI API is unavailable

**Note:**

*   An API key (`OPENAI_API_KEY`) is required to use the OpenAI API (set in the `.env` file).
*   The quality of the AI-generated messages depends on the content of `git diff` and the performance of the OpenAI API. Use the generated messages as suggestions and modify them as needed.

### User-Friendly Messages

Improved messages for `--s`, `--l`, `--p` options to provide clearer and more understandable information. For destructive operations (discarding changes, rollbacks, etc.), detailed prompts and warnings are displayed to prevent unintended actions.

### Help Option (`--help`)

Executing the `--help` option displays detailed usage instructions, option list, and examples for the Gish script. This helps even first-time users understand the script's functions and usage.

## Improvements

### Enhanced Error Handling

Improved error handling throughout the script to display more understandable error messages in situations such as:

*   **Invalid Options:** Specifying non-existent options like `gish --invalid_option`
*   **Insufficient Arguments:** Omitting the stash name for the `--s` option
*   **Other Errors:** Failure to execute Git commands, failure to activate the virtual environment, etc.

This prevents the script from stopping unexpectedly or encountering unexplained errors, providing users with the information needed to resolve issues.

**Example:**

*   Executing `gish --s mini update` (stash name not enclosed in quotes) now displays an error message.

### Improved Code Quality

*   **Readability and Maintainability:** Refactored the entire code to improve readability and maintainability. This included function splitting, variable name reviews, and adding comments to organize the code structure.
*   **Output Format Improvement:** Unified the output message format and enhanced visibility. Changed the display of `Change statistics` to user-friendly English, among other improvements.

## Usage

### Overview

Gish is a Bash script designed to perform Git operations efficiently and safely. It allows interactive execution of daily Git tasks such as committing, branch switching, pushing, and stash management.

### Main Features

*   **Uncommitted Change Management:** Track the change status of the working directory and select operations such as commit and stash
*   **Commit Creation:** Generate commit messages through AI automatic generation or manual input
*   **Branch Operations:** Select, switch, and create branches (including creation from remote branches)
*   **Remote Repository Synchronization:** Push to the remote repository and easily pull from the remote
*   **Stash Management:** Save and apply named stashes, rollback to `stash@{0}`
*   **Help Display:** Display detailed usage guide with the `--help` option
*   **Diff Display:** Display differences with the remote repository using the `--d` option (statistics information, detailed diff)

### Installation Steps

#### Prerequisites

Before installation, ensure you have the following tools installed:
- `uv` (recommended for Python virtual environment management): [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
- Git (version control system)
- Python 3.8 or later

#### Step 1: Create Required Directories

```bash
mkdir -p ~/.local/bin/gish-tools
```

#### Step 2: Install the Main Script

1. Copy the `gish.sh` script to `~/.local/bin/gish` and grant execute permission:

    ```bash
    cp gish.sh ~/.local/bin/gish
    chmod +x ~/.local/bin/gish
    ```

#### Step 3: Set Up AI Commit Message Generation (Optional but Recommended)

1. Copy the Python script and requirements file:

    ```bash
    cp generate_commit_message.py ~/.local/bin/gish-tools/
    cp requirements.txt ~/.local/bin/gish-tools/
    chmod +x ~/.local/bin/gish-tools/generate_commit_message.py
    ```

2. Create a `.env` file with your OpenAI API key:

    ```bash
    echo "OPENAI_API_KEY=your_openai_api_key_here" > ~/.local/bin/gish-tools/.env
    ```

    > **Note:** Replace `your_openai_api_key_here` with your actual OpenAI API key. You can get one from [OpenAI's website](https://platform.openai.com/api-keys).

3. Create a Python virtual environment using `uv` and install dependencies:

    ```bash
    cd ~/.local/bin/gish-tools
    uv venv venv
    source venv/bin/activate
    uv pip install -r requirements.txt
    deactivate
    ```

#### Step 4: Configure Your Shell

Add `~/.local/bin` to your PATH by adding the following line to your shell configuration file:

**For Bash users** (add to `~/.bashrc`):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**For Zsh users** (add to `~/.zshrc`):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

#### Step 5: Reload Your Shell

```bash
source ~/.bashrc  # for Bash users
# or
source ~/.zshrc   # for Zsh users
```

#### Step 6: Verify Installation

Test that the installation was successful:

```bash
gish --help
```

If everything is set up correctly, you should see the help message for the gish command.

**Final Directory Structure:**

```
~/.local/bin/
├── gish                             # Main executable script
└── gish-tools/                      # AI tools directory
    ├── generate_commit_message.py   # AI commit message generator
    ├── requirements.txt             # Python dependencies
    ├── .env                         # OpenAI API key configuration
    └── venv/                        # Python virtual environment (created by uv)
        ├── bin/
        ├── lib/
        └── ...
```

## Troubleshooting

- **Permission denied error:** Ensure both scripts have execute permissions:
  ```bash
  chmod +x ~/.local/bin/gish
  chmod +x ~/.local/bin/gish-tools/generate_commit_message.py
  ```

- **Command not found:** Verify that `~/.local/bin` is in your PATH:
  ```bash
  echo $PATH | grep -o ~/.local/bin
  ```

- **Python environment issues:** Make sure `uv` is installed and working:
  ```bash
  uv --version
  ```
  If you get an error, reinstall `uv` or try the alternative installation method:
  ```bash
  # Alternative: create virtual environment with standard Python
  cd ~/.local/bin/gish-tools
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate
  ```

- **API key issues:** Verify your `.env` file contains the correct API key:
  ```bash
  cat ~/.local/bin/gish-tools/.env
  ```

- **Branch switching fails:** Check for uncommitted changes and ensure there are no conflicts.

- **Push fails:** Check the internet connection and ensure you have access to the remote repository.

- **AI commit message generation fails:** Check that your OpenAI API key is correctly set in the `.env` file and that the virtual environment is properly configured.

- **Virtual environment activation fails:** Make sure the virtual environment was created correctly and all dependencies are installed:
  ```bash
  cd ~/.local/bin/gish-tools
  ls -la venv/  # Should show the virtual environment directory
  source venv/bin/activate
  python -c "import openai; print('OpenAI installed successfully')"
  deactivate
  ```

### Basic Operation Procedure (When Executing `gish` Command)

1.  Execute the `gish` command in the root directory of the Git repository. The current branch and workspace status will be displayed. If there are uncommitted changes, the following options will be displayed:
    *   **1) Commit to current branch**
    *   **2) Commit to existing branch**
    *   **3) Create and commit to new branch**
    *   **4) Cancel operation**

2.  Select `1`, `2`, or `3` to commit the changes.

3.  Choose the commit message generation method.
    *   **AI Automatic Generation:** Automatically generate a commit message using the OpenAI API. The generated message can be reviewed and edited.
    *   **Manual Input:** Follow the prompt to manually input the commit message.

4.  Select the target branch (for options `2`, `3`).
    *   **2) Commit to existing branch:** Select the target branch from the list of existing remote branches. **Warning:** The selected branch will be completely overwritten by local changes.
    *   **3) Create and commit to new branch:** Enter a new branch name to create the branch.

5.  Choose whether to push the changes to the remote repository.

Upon completion, the current branch name and Git status will be displayed.

### Notes

*   A commit message is required (empty commit messages are not allowed).
*   Be cautious when switching branches with uncommitted changes.
*   Push operations depend on the network environment and may fail in unstable conditions.
*   If the operation is canceled, staged changes will not be automatically reset. Use the `git reset` command as needed.

## Environment Setup

### Required Packages

Contents of `requirements.txt`:
```
openai>=1.0.0
python-dotenv>=0.19.0
```

### Python Script Path Setting

If you change the path of the Python script (`generate_commit_message.py`) from the default, modify the path setting in the `gish` script.

```bash
commit_message=$("$VENV_PYTHON" "$COMMIT_MESSAGE_SCRIPT" 2>&1)
```

Ensure this path correctly points to the script to avoid execution errors.

## Customization

You can customize the script by editing it to:

- Change the default branch name
- Execute additional Git commands
- Customize error messages

## Support

If you encounter any issues or have suggestions for improvement, please report them through the repository's Issue Tracker.
