# Gish - Git Command Helper

**Gish** is a powerful and user-friendly Bash script designed to simplify common Git operations and streamline workflows through intuitive commands and interactive prompts.

**Design Philosophy:**

Gish is primarily aimed at **individual developers** to efficiently synchronize their local workspace with remote repositories. By replacing complex Git commands with simpler, more intuitive operations, developers can focus more on coding.

## Version

Please refer to the source code (the `ver: n.n.n` line at the top of the script).

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

1. Save the `gish` script to `~/.local/bin/` and grant execute permission:

    ```bash
    chmod +x ~/.local/bin/gish
    ```

2. For AI commit message generation, set up the following in `~/.local/bin/gish-tools/`:
    - Place `generate_commit_message.py` and `requirements.txt` in this directory.
    - Create a `.env` file with your OpenAI API key:

        ```
        OPENAI_API_KEY=your_openai_api_key_here
        ```

    - Create a Python virtual environment and install requirements (using `uv` or `uvx` recommended):

        ```bash
        cd ~/.local/bin/gish-tools
        python3 -m venv venv
        source venv/bin/activate
        uv pip install -r requirements.txt
        ```

        > uv install is recommended, pip global install is not.

3. Add the following to your `.bashrc` or `.zshrc`:

    ```bash
    export PATH="$HOME/.local/bin:$PATH"
    ```

    This allows you to use the `gish` command directly, without any alias or function.

4. Reload your shell:

    ```bash
    source ~/.bashrc  # or source ~/.zshrc
    ```

**Directory structure example:**

```
~/.local/bin/
├── gish
└── gish-tools/
    ├── generate_commit_message.py
    ├── requirements.txt
    ├── .env
    └── venv/
```

---

**Notes:**
- Ensure the paths for the `gish` script and the `gish-tools` directory match.
- Verify that the API key in the `.env` file is correct.
- The virtual environment is automatically activated by the `gish` script.

---

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

### Environment Variables (`.env` File)

To use the AI commit message automatic generation feature, you need to set the OpenAI API key.

1.  Create a `.env` file in the same directory as `generate_commit_message.py` (`~/.local/bin/gish-tools/`).
2.  Add the following content to the `.env` file and replace `your_openai_api_key_here` with your actual API key.

    ```
    OPENAI_API_KEY=your_openai_api_key_here
    ```

### Python Script Path Setting

If you change the path of the Python script (`generate_commit_message.py`) from the default, modify the path setting in the `gish` script.

```bash
commit_message=$("$VENV_PYTHON" "$COMMIT_MESSAGE_SCRIPT" 2>&1)
```

Ensure this path correctly points to the script to avoid execution errors.

### Required Packages

Contents of `requirements.txt`:
```
openai>=1.0.0
python-dotenv>=0.19.0
```

### Virtual Environment

A virtual environment is used to execute the Python script. Set it up as follows:

1.  Create a virtual environment:
```bash
cd ~/.local/bin/gish-tools
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Note: The `gish` script internally calls `activate_virtual_env()`, so you typically do not need to be aware of the virtual environment during normal use. The virtual environment will be automatically activated when the command is executed.

### File Structure

```
~/.local/bin/
└── gish                    # Main shell script
~/.local/bin/gish-tools/    # Directory for gish-related tools
    ├── generate_commit_message.py
    ├── requirements.txt
    ├── .env
    └── venv/              # Python virtual environment
```

## Troubleshooting

- If the script cannot be executed:
  Ensure the script file has execute permissions.
  ```bash
  chmod +x ~/.local/bin/gish
  ```

- If branch switching fails:
  Check for uncommitted changes and ensure there are no conflicts.

- If push fails:
  Check the internet connection and ensure you have access to the remote repository.

## Customization

You can customize the script by editing it to:

- Change the default branch name
- Execute additional Git commands
- Customize error messages

## Support

If you encounter any issues or have suggestions for improvement, please report them through the repository's Issue Tracker.