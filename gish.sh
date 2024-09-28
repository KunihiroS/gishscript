#!/bin/bash

# Help list
show_help() {
    echo "gish - A Git automation script"
    echo "ver: 1.3.0"
    echo
    echo "gish simplifies common Git tasks such as committing changes, managing branches, and"
    echo "handling stashes. It automates the process of checking for uncommitted changes, switching"
    echo "branches, and pushing changes to a remote repository."
    echo
    echo "Usage: gish [OPTION]"
    echo
    echo "Options:"
    echo "  --s <name>    Save and apply a stash with the specified name. no space acceptable"
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

# エラー処理関数
handle_error() {
    local error_message="$1"
    local rollback_function="$2"
    echo "Error: $error_message"
    if [[ -n "$rollback_function" ]]; then
        echo "Attempting to rollback changes..."
        $rollback_function
    fi
    return 1
}

# stash save "name" -> stash apply stash@{0}
stash_and_apply() {
    local stash_name="$1"
    
    if [ -z "$stash_name" ]; then
        stash_name=$(date +"%Y%m%d%H%M%S")
    fi

    if git diff-index --quiet HEAD --; then
        echo "No local changes to save"
        return 0
    fi

    if ! git stash push -m "$stash_name"; then
        handle_error "Failed to save the stash."
        return 1
    fi

    if ! git stash apply "stash@{0}"; then
        handle_error "Failed to apply the stash." "git stash pop"
        return 1
    fi

    echo "Stashed and reapplied state: $stash_name"
    echo "Current stash list:"
    git stash list
    echo "Stash saved as '$stash_name'. The code has been reverted to the '$stash_name' condition."
    return 0
}

# reset --hard -> stash apply stash@{0}
apply_stash_rollback() {
    read -p "Want to apply stash@{0}? *CAUTION: All changes after stash@{0} will be deleted. Type 'yes' to confirm: " confirm
    if [[ $confirm == "yes" ]]; then
        if ! git reset --hard; then
            handle_error "Failed to reset the working directory."
            return 1
        fi
        if ! git stash apply "stash@{0}"; then
            handle_error "Failed to apply stash@{0}."
            return 1
        fi
        echo "Rolled back to stash@{0}. All changes after stash@{0} have been deleted."
    else
        echo "Operation cancelled."
    fi
    return 0
}

# reset --hard -> pull origin {branch}
easy_pull() {
    read -p "Easy pull from remote repo anyway? *CAUTION: All local changes will be deleted. Type 'yes' to confirm: " confirm
    if [[ $confirm == "yes" ]]; then
        if ! git fetch --all; then
            handle_error "Failed to fetch from remote repository."
            return 1
        fi
        PS3="Select branch to pull: "
        select branch in $(git branch -r | grep -v '\->' | grep -v "HEAD" | sed 's/origin\///'); do
            if [ -n "$branch" ]; then
                read -p "Final confirmation, are you sure to rollback? Type 'yes' to confirm: " final_confirm
                if [[ $final_confirm == "yes" ]]; then
                    if ! git reset --hard "origin/$branch"; then
                        handle_error "Failed to reset to origin/$branch."
                        return 1
                    fi
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
    return 0
}

generate_smart_commit_message() {
    if command -v python3 &> /dev/null; then
        python_cmd="python3"
    elif command -v python &> /dev/null; then
        python_cmd="python"
    else
        echo "Error: Neither python3 nor python found in PATH. Falling back to manual entry."
        commit_message=""
        return 1
    fi

    # Get the directory of the current script
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    commit_script="$script_dir/generate_commit_message.py"
    env_file="$HOME/.gish_env"

    if [ ! -f "$commit_script" ]; then
        echo "Error: generate_commit_message.py not found in the same directory as gish.sh"
        return 1
    fi

    if [ ! -f "$env_file" ]; then
        echo "Error: .gish_env file not found in your home directory."
        return 1
    fi

    # Set up environment variables
    export $(grep -v '^#' "$env_file" | xargs)

    echo "Generating commit message with AI... please wait."
    commit_message=$($python_cmd "$commit_script" 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate commit message. Error output:"
        echo "$commit_message"
        echo "Falling back to manual entry."
        commit_message=""
    else
        echo "Generated commit message: $commit_message"
        read -p "Is this commit message okay? [y/N]: " user_confirmation
        if [[ ! $user_confirmation =~ ^[Yy]$ ]]; then
            commit_message=""
        fi
    fi

    while [ -z "$commit_message" ]; do
        read -p "Enter your commit message: " commit_message
        if [ -z "$commit_message" ]; then
            echo "Commit message cannot be empty. Please try again."
        fi
    done

    echo "$commit_message"
}


# gish main
gish() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $current_branch"
    git status

    # 未ステージの変更を確認
    if ! git diff-index --quiet HEAD --; then
        echo "You have unstaged changes. Choose an option:"
        echo "1) Stage all changes"
        echo "2) Cancel operation"
        read -p "Enter your choice (1-2): " stage_choice
        case "$stage_choice" in
            1)
                if ! git add -A; then
                    handle_error "Failed to stage changes."
                    return 1
                fi
                ;;
            2)
                echo "Operation cancelled."
                return 1
                ;;
            *)
                echo "Invalid choice. Operation cancelled."
                return 1
                ;;
        esac
    fi

    # ターゲットブランチの選択
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
            ;;
        3)
            read -p "Enter new branch name: " new_branch
            # 新しいブランチを作成し、必ず切り替える
            if ! git checkout -b "$new_branch"; then
                handle_error "Failed to create and checkout new branch $new_branch."
                return 1
            fi
            echo "New branch created and switched to $new_branch."
            target_branch="$new_branch"
            ;;
        *)
            echo "Invalid choice. Exiting."
            return 1
            ;;
    esac

    if [ "$target_branch" != "$current_branch" ]; then
        # 変更をスタッシュ
        if ! git stash push -m "gish-stash"; then
            handle_error "Failed to stash changes."
            return 1
        fi

        # ターゲットブランチに切り替え
        if ! git checkout "$target_branch"; then
            handle_error "Failed to checkout branch $target_branch."
            return 1
        fi
        echo "Switched to branch $target_branch."

        # スタッシュを適用
        if ! git stash pop; then
            handle_error "Failed to apply stashed changes."
            return 1
        fi

        # ステージング（必要であれば）
        if ! git diff-index --quiet HEAD --; then
            if ! git add -A; then
                handle_error "Failed to stage changes."
                return 1
            fi
        fi
    fi

    # コミットの確認と実行
    read -p "Proceed with commit on $target_branch? (y/N): " proceed
    if [[ $proceed =~ ^[Yy]$ ]]; then
        commit_message=""
        if ! generate_smart_commit_message; then
            while true; do
                read -p "Enter your commit message: " commit_message
                if [ -n "$commit_message" ]; then
                    break
                else
                    echo "Commit message cannot be empty. Please try again."
                fi
            done
        fi

        if ! git commit -m "$commit_message"; then
            handle_error "Failed to commit changes on $target_branch."
            return 1
        fi
    else
        echo "Operation cancelled. Changes are not committed."
        return 1
    fi

    # プッシュの確認と実行
    read -p "Push changes to $target_branch? (y/N): " push_confirm
    if [[ $push_confirm =~ ^[Yy]$ ]]; then
        if ! git push origin "$target_branch"; then
            handle_error "Push to $target_branch failed. Check your connection or remote settings."
            return 1
        fi
        echo "Push to $target_branch successful."
    else
        echo "Push cancelled."
    fi

    # 元のブランチに戻る（必要であれば）
    if [ "$target_branch" != "$current_branch" ]; then
        if ! git checkout "$current_branch"; then
            handle_error "Failed to switch back to branch $current_branch."
            return 1
        fi
        echo "Switched back to branch $current_branch."
    fi

    echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
    return 0  # success response
}

# 引数チェック（変更なし）
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --s)
        stash_name="$2"
        stash_and_apply "$stash_name"
        exit 0
        ;;
    --l)
        apply_stash_rollback
        exit 0
        ;;
    --p)
        easy_pull
        exit 0
        ;;
    "")
        # 引数がない場合はそのまま進む
        ;;
    *)
        echo "Error: Invalid option '$1'. Use --help to see available options."
        exit 1
        ;;
esac

# Run gish function
gish "$@"