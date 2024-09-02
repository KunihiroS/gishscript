# gishscript

Git command helper. 
A powerful and user-friendly Bash script that simplifies common Git operations, enhancing your workflow with intuitive commands and interactive prompts.

## Version

1.2.5

## Release Notes
1.2.5
Automatic commit message generation by OpenAI.
Remaining issues: unexpected error occur (works fine though), unable modifying generated commit message, detailed info is not updated.

1.2.4
This update introduces several improvements and new features to enhance the user experience when managing Git operations via the `gish` script.

### New Features:

* **Stash Management with `--s` Option:**
   * You can use the `--s` option followed by a stash name to save the current working directory and index state to a stash and immediately reapply it. This simplifies the workflow for those who frequently use stashes.
   * Example: `gish --s my_stash_name` saves the current state as `my_stash_name`, reapplies it, and displays the updated stash list. No space acceptable.

* **Rollback to Stash with `--l` Option:**
   * The `--l` option allows you to rollback to `stash@{0}`, discarding all changes made after that stash. This is useful for quickly reverting to a previous state.
   * Example: `gish --l` prompts for confirmation and then reverts the working directory to `stash@{0}`.

* **Easy Pull from Remote with `--p` Option:**
   * The `--p` option provides a simplified way to pull the latest changes from a remote branch, discarding all local changes.
   * Example: `gish --p` fetches all branches, allows you to select one, and resets your local branch to the selected remote branch.

* **User-Friendly Messaging:**
   * Added clearer messages when using the `--s`, `--l`, and `--p` options. The script provides detailed prompts and warnings to guide the user through potentially destructive operations.

* **Help Option (`--help`):**
   * The `--help` option displays a detailed usage guide for the `gish` script, making it easier for new users to understand and use the script effectively.

### Improvements:

* **Error Handling:**
   * Improved error handling across the script. Invalid options, missing arguments, and other errors now result in informative error messages, preventing unexpected script behavior.
   * For example, `gish --s mini update` without quotes around the stash name will now correctly trigger an error.

* **Code Refinements:**
   * General improvements in code readability and structure, ensuring smoother operation and easier future maintenance.
   * Corrected minor issues and improved the output format for better clarity.

## Usage

### Overview

Gish is a Bash script designed to streamline and safely execute Git operations. It allows you to interactively perform a series of Git tasks, including committing, branch switching, pushing, and managing stashes.

### Features

* Manage uncommitted changes
* Create commits
* Select and switch branches
* Create new branches
* Push to remote repositories
* Save and apply Git stashes with a single command (`--s` option)
* Rollback to a specific stash with one command "abbr. load" (`--l` option) 
* Easy pull from remote, discarding local changes (`--p` option)
* Access a help guide with usage instructions (`--help` option)

### Usage

1. Save the script as "gish.sh" in the following location: `~/.local/bin/gish.sh` (Note: `~` represents your home directory). Grant execute permissions to the script:

   ```bash
   chmod +x ~/.local/bin/gish.sh
   ```

2. Add the following line to your .bashrc or .zshrc:

   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   alias gish='~/.local/bin/gish.sh "$@"'
   ```

3. Restart your shell or run the following command to apply the changes:

   ```bash
   source ~/.bashrc # or source ~/.zshrc
   ```

4. Run the gish command within a Git repository.

### Operation Procedure

When you run the gish command, the current branch is displayed. If there are uncommitted changes, the following options are presented:

1. Commit changes
2. Stash changes
3. Continue with uncommitted changes
4. Cancel the operation

The changes are staged, and the result of git status is displayed.

Choose whether to commit:

- If Yes, you will be prompted to enter a commit message.
- If No, the operation is canceled.

Select the target branch:

1. Current branch
2. Existing branch
3. New branch

Depending on the selection, the branch is switched or created.

Finally, you are asked whether to push to the selected branch.

After the operation is completed, the current branch is displayed.

### Notes

- The commit message cannot be empty.
- Be cautious when switching branches with uncommitted changes.
- Push operations depend on the network connection status.
- If the operation is canceled, staged changes are not reset.

## Troubleshooting

- If the script cannot be executed: Ensure the script file has execute permissions. You can grant permissions by running:

  ```bash
  sudo chmod +x /usr/local/bin/gish
  ```

- If branch switching fails: Check for uncommitted changes. Ensure there are no conflicts.
- If pushing fails: Check your internet connection. Ensure you have access rights to the remote repository.

## Customization

By editing the script, the following customizations are possible:

- Changing the default branch name
- Executing additional Git commands
- Customizing error messages

## Support

If you encounter issues or have suggestions for improvement, please report them via the repository's Issue tracker.