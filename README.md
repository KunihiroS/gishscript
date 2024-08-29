# gishscript
Git command helper.

## Version
1.0.0
Initial release

## Usage

### Overview
Gish is a Bash script designed to streamline and safely execute Git operations. It allows you to interactively perform a series of Git tasks, including committing, branch switching, and pushing.

### Features
- Manage uncommitted changes
- Create commits
- Select and switch branches
- Create new branches
- Push to remote repositories

### Usage
Save the script as "gish.sh" in the following location: ~/.local/bin/gish.sh Note: ~ represents your home directory.
Grant execute permissions to the script: chmod +x ~/.local/bin/gish.sh
Add the following line to your .bashrc or .zshrc:
```
export PATH="$HOME/.local/bin:$PATH"
alias gish='~/.local/bin/gish.sh "$@"' 
```
Restart your shell or run the following command to apply the changes: source ~/.bashrc # or source ~/.zshrc
Run the gish command within a Git repository.

### Operation Procedure
When you run the gish command, the current branch is displayed.
If there are uncommitted changes, the following options are presented:
- Commit changes
- Stash changes
- Continue with uncommitted changes
- Cancel the operation
The changes are staged, and the result of git status is displayed.
Choose whether to commit:
- If Yes, you will be prompted to enter a commit message.
- If No, the operation is canceled.
Select the target branch:
- Current branch
- Existing branch
- New branch
Depending on the selection, the branch is switched or created.
Finally, you are asked whether to push to the selected branch.
After the operation is completed, the current branch is displayed.

### Notes
The commit message cannot be empty.
Be cautious when switching branches with uncommitted changes.
Push operations depend on the network connection status.
If the operation is canceled, staged changes are not reset.

### Troubleshooting
- If the script cannot be executed:
Ensure the script file has execute permissions.
You can grant permissions by running sudo chmod +x /usr/local/bin/gish.
- If branch switching fails:
Check for uncommitted changes.
Ensure there are no conflicts.
- If pushing fails:
Check your internet connection.
Ensure you have access rights to the remote repository.

### Customization
By editing the script, the following customizations are possible:
- Changing the default branch name
- Executing additional Git commands
- Customizing error messages

### Support
If you encounter issues or have suggestions for improvement, please report them via the repository's Issue tracker.

