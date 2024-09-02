#!/bin/bash
# Version: 1.2.2

# Help list
show_help() {
    echo "gish - A Git automation script"
    echo "ver: 1.2.2"
    echo
    echo "gish simplifies common Git tasks such as committing changes, managing branches, and"
    echo "handling stashes. It automates the process of checking for uncommitted changes, switching"
    echo "branches, and pushing changes to a remote repository."
    echo
    echo "Usage: gish [OPTION]"
    echo
    echo "Options:"
    echo "  --s <name>    Save and apply a stash with the specified name. name needed inside \"name\""
    echo "  --l           Save and rollback to stash@{0}, deleting all changes after it."
    echo "  --p           Easy pull from a remote repository, discarding all local changes."
    echo "  --help        Display this help and exit."
    echo
    echo "Examples:"
    echo "  gish --s \"my_stash_name\""
    echo "      This will save the current working directory and index state with the name 'my_stash_name',"
    echo "      immediately apply the stash, and then display the stash list."
    echo
    echo "  gish --l"
    echo "      This will rollback to the state of stash@{0}, deleting all changes made after it."
    echo
    echo "  gish --p"
    echo "      This will discard all local changes and pull the latest changes from the selected remote branch."
    echo
    exit 0
}

# stash save "name" -> stash apply stash@{0}
stash_and_apply() {
    local stash_name="$1"
    if ! git stash save "$stash_name"; then
        echo "Error: Failed to save the stash."
        exit 1
    fi

    if ! git stash apply "stash@{0}"; then
        echo "Error: Failed to apply the stash."
        exit 1
    fi

    echo "Stashed and reapplied state: $stash_name"
    echo "Current stash list:"
    git stash list
    echo "Stash saved as '$stash_name'. The code has been reverted to the '$stash_name' condition."
    exit 0  # スクリプトを終了する
}

# reset --hard -> stash apply stash@{0}
apply_stash_rollback() {
    read -p "Want to apply stash@{0}? *CAUTION: All rollback to stash@{0} condition, your modify will be deleted. [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        git reset --hard
        git stash apply "stash@{0}"
        echo "Rolled back to stash@{0}. All changes after stash@{0} have been deleted."
    else
        echo "Operation cancelled."
    fi
    exit 0  # スクリプトを終了する
}

# reset --hard -> pull origin {branch}
easy_pull() {
    read -p "Easy pull from remote repo anyway? *CAUTION: All rollback to remote repo condition, your modify will be deleted. [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        git fetch --all
        PS3="Select branch to pull: "
        select branch in $(git branch -r | sed 's/origin\///'); do
            if [ -n "$branch" ]; then
                read -p "Final confirmation, are you sure to rollback? [y/N] " final_confirm
                if [[ $final_confirm =~ ^[Yy]$ ]]; then
                    git reset --hard "origin/$branch"
                    echo "Rolled back to remote branch '$branch'."
                else
                    echo "Operation cancelled."
                fi
                break
            fi
        done
    else
        echo "Operation cancelled."
    fi
    exit 0  # スクリプトを終了する
}

# Error check
case "$1" in
    --help)
        show_help
        ;;
    --s)
        if [ -n "$2" ]; then
            # Error check " " 
            if [[ "$2" != \"* ]]; then
                echo "Error: The name argument for --s must be enclosed in double quotation marks and can contain spaces. Usage: gish --s \"stash name\""
                exit 1
            fi
            # Remove " " to register stash name
            stash_name="${2//\"/}"
            
            # Check empty error
            if [ -z "$stash_name" ]; then
                echo "Error: Stash name cannot be empty. Usage: gish --s \"stash name\""
                exit 1
            fi
            
            stash_and_apply "$stash_name"
        else
            echo "Error: --s option requires a name argument. Usage: gish --s \"stash name\""
            exit 1
        fi
        ;;
    --l)
        apply_stash_rollback
        ;;
    --p)
        easy_pull
        ;;
    "")
        gish
        ;;
    *)
        echo "Error: Invalid option '$1'. Use --help to see available options."
        exit 1
        ;;
esac

# gish main
gish() {
    check_uncommitted_changes() {
        if ! git diff-index --quiet HEAD --; then
            echo "Warning: You have uncommitted changes."
            echo "1) Commit changes"
            echo "2) Stash changes"
            echo "3) Continue with uncommitted changes (not recommended)"
            echo "4) Cancel operation"
            read -p "Choose an option (1-4): " choice
            case "$choice" in
                1)
                    git add -A
                    while true; do
                        read -p "Enter commit message: " commit_msg
                        if [ -n "$commit_msg" ]; then
                            git commit -m "$commit_msg"
                            break
                        else
                            echo "Commit message cannot be empty. Please try again."
                        fi
                    done
                    ;;
                2)
                    git stash save "Automatic stash by gish script"
                    echo "Changes stashed."
                    ;;
                3)
                    echo "Warning: Proceeding with uncommitted changes."
                    ;;
                4)
                    echo "Operation cancelled."
                    return 1
                    ;;
                *)
                    echo "Invalid option. Operation cancelled."
                    return 1
                    ;;
            esac
        fi
    }

    safe_checkout() {
        target_branch="$1"
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" != "$target_branch" ]; then
            check_uncommitted_changes || return 1
            git checkout "$target_branch"
            echo "Switched to branch $target_branch."
        else
            echo "Already on branch $target_branch."
        fi
    }

    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $current_branch"

    git status

    read -p "Changes have been staged. Proceed with commit? (y/N): " proceed
    case "$proceed" in
        [yY]*)
            git add -A
            while true; do
                read -p "Enter commit message: " msg
                if [ -n "$msg" ]; then
                    git commit -m "$msg"
                    break
                else
                    echo "Commit message cannot be empty. Please try again."
                fi
            done

            echo "Select target branch:"
            echo "1) Current branch ($current_branch)"
            echo "2) Existing branch"
            echo "3) New branch"
            read -p "Enter your choice (1-3): " branch_choice

            case "$branch_choice" in
                1)
                    target_branch="$current_branch"
                    ;;
                2)
                    branches=$(git branch | sed 's/^* //g' | sort)
                    PS3="Select branch (enter number): "
                    select branch in $branches; do
                        if [ -n "$branch" ]; then
                            target_branch="$branch"
                            break
                        fi
                    done
                    safe_checkout "$target_branch"
                    ;;
                3)
                    read -p "Enter new branch name: " new_branch
                    read -p "Branch '$new_branch' will be created. Switch to new branch '$new_branch'? (y/N): " switch_choice
                    if [[ $switch_choice =~ ^[Yy]$ ]]; then
                        git checkout -b "$new_branch"
                        echo "New branch created, switched to new branch $new_branch."
                    else
                        git branch "$new_branch"
                        echo "New branch $new_branch created without switching. You are still on $current_branch."
                    fi
                    target_branch="$new_branch"
                    ;;
                *)
                    echo "Invalid choice. Exiting."
                    return 1
                    ;;
            esac

            read -p "Push changes to $target_branch? (y/N): " push_confirm
            if [[ $push_confirm =~ ^[Yy]$ ]]; then
                if git push origin "$target_branch"; then
                    echo "Push to $target_branch successful."
                else
                    echo "Push to $target_branch failed. Check your connection or remote settings."
                fi
            else
                echo "Push cancelled."
            fi
            ;;
        *)
            echo "Operation cancelled. Changes are not committed."
            ;;
    esac

    echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
}

# gish()
gish "$@"
