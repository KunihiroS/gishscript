#!/bin/bash

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
gish "$@"