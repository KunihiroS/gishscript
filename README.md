# gishscript

Git command helper.

## Version

1.1.0

## Release Notes

This update introduces several improvements and new features to enhance the user experience when managing Git operations via the `gish` script.

### New Features:

* **Stash Management with `--s` Option:**
   * You can now use the `--s` option followed by a stash name to save the current working directory and index state to a stash and immediately reapply it. This simplifies the workflow for those who frequently use stashes.
   * Example: `gish --s my_stash_name` saves the current state as `my_stash_name`, reapplies it, and displays the updated stash list.

* **User-Friendly Messaging:**
   * Added clearer messages when using the `--s` option. For example, after executing `gish --s my_stash_name`, the script now outputs:
      * `Stash saved as 'my_stash_name'. The code has been reverted to the 'my_stash_name' condition.`

* **Help Option (`--help`):**
   * Introduced the `--help` option to display a detailed usage guide for the `gish` script, making it easier for new users to understand and use the script effectively.

### Improvements:

* **Code Refinements:**
   * General improvements in code readability and structure, ensuring smoother operation and easier future maintenance.
   * Corrected minor issues and improved the output format for better clarity.

## Usage

### Overview

Gish is a Bash script designed to streamline and safely execute Git operations. It allows you to interactively perform a series of Git tasks, including committing, branch switching, and pushing.

### Features

* Manage uncommitted changes
* Create commits
* Select and switch branches
* Create new branches
* Push to remote repositories
* Save and apply Git stashes with a single command (`--s` option)
* Access a help guide with usage instructions (`--help` option)

### Usage

1. Save the script as "gish.sh" in the following location: `~/.local/bin/gish.sh` (Note: `~` represents your home directory). Grant execute permissions to the script:

   ```bash
   chmod +x ~/.local/bin/gish.sh
   ```

2. Add the following line to your `.bashrc` or `.zshrc`:

   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   alias gish='~/.local/bin/gish.sh "$@"'
   ```

3. Restart your shell or run the following command to apply the changes:

   ```bash
   source ~/.bashrc # or source ~/.zshrc
   ```

4. Run the `gish` command within a Git repository.

### Operation Procedure

1. When you run the `gish` command, the current branch is displayed. If there are uncommitted changes, the following options are presented:
   * Commit changes
   * Stash changes
   * Continue with uncommitted changes
   * Cancel the operation

2. The changes are staged, and the result of `git status` is displayed.

3. Choose whether to commit:
   * If Yes, you will be prompted to enter a commit message.
   * If No, the operation is canceled.

4. Select the target branch:
   * Current branch
   * Existing branch
   * New branch

5. Depending on the selection, the branch is switched or created.

6. Finally, you are asked whether to push to the selected branch.

7. After the operation is completed, the current branch is displayed.

### Notes

* The commit message cannot be empty.
* Be cautious when switching branches with uncommitted changes.
* Push operations depend on the network connection status.
* If the operation is canceled, staged changes are not reset.

## Troubleshooting

* **If the script cannot be executed:** Ensure the script file has execute permissions. You can grant permissions by running:

  ```bash
  sudo chmod +x /usr/local/bin/gish
  ```

* **If branch switching fails:** Check for uncommitted changes. Ensure there are no conflicts.
* **If pushing fails:** Check your internet connection. Ensure you have access rights to the remote repository.

## Customization

By editing the script, the following customizations are possible:

* Changing the default branch name
* Executing additional Git commands
* Customizing error messages

## Support

If you encounter issues or have suggestions for improvement, please report them via the repository's Issue tracker.