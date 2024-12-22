#!/bin/bash
# Help list
show_help() {
    echo "gish - A Git automation script"
    echo "ver: 1.3.6"
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
    echo "  --p           Easy pull from a remote repository, discarding all local changes and then move to targeted branch."
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

# 仮想環境を有効化
if [ -d "$HOME/.local/bin/gish-tools/venv" ]; then
    source "$HOME/.local/bin/gish-tools/venv/bin/activate"
fi

# stash save "name" -> stash apply stash@{0}
stash_and_apply() {
    local stash_name="$1"
    
    # If no stash name is provided, use the current timestamp as the stash name
    if [ -z "$stash_name" ]; then
        stash_name=$(date +"%Y%m%d%H%M%S")
    fi

    # ワーキングツリーに変更があるか確認
    if git diff-index --quiet HEAD --; then
        echo "No local changes to save"
        exit 0  # スクリプトを終了する
    fi

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
# easy_pull function
easy_pull() {
    read -p "Easy pull from remote repo anyway? *CAUTION: All rollback to remote repo condition, your modify will be deleted. [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # Get current branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        
        # Fetch all remote branches
        echo "Fetching remote repository information..."
        if ! git fetch --all --prune; then
            echo "Error: Failed to fetch remote repository information."
            exit 1
        fi

        # Get list of remote branches (excluding current branch)
        echo "Loading remote branches..."
        PS3="Select branch to pull: "
        mapfile -t remote_branches < <(git branch -r | \
            grep '^  origin/' | \
            grep -v '/HEAD' | \
            sed 's#  origin/##' | \
            grep -v "^${current_branch}\$" | \
            sort -u)

        if [ ${#remote_branches[@]} -eq 0 ]; then
            echo "No other remote branches available."
            exit 1
        fi

        # Display branch selection
        echo "Current branch: $current_branch (excluded from list)"
        select branch in "${remote_branches[@]}"; do
            if [ -n "$branch" ]; then
                # Validate branch name
                if [[ "$branch" == "HEAD" ]]; then
                    echo "Invalid branch selection."
                    exit 1
                fi

                read -p "Final confirmation - This will delete all local changes and switch to branch '$branch'. Continue? [y/N] " final_confirm
                if [[ $final_confirm =~ ^[Yy]$ ]]; then
                    echo "Switching to remote branch '$branch'..."

                    # まずチェックアウトを試みる
                    if ! git checkout "$branch" 2>/dev/null; then
                        # ローカルブランチが存在しない場合は新規作成
                        if ! git checkout -b "$branch" --track "origin/$branch"; then
                            echo "Error: Failed to create branch '$branch'"
                            exit 1
                        fi
                    fi

                    # 確実にリモートの状態にリセット
                    if ! git reset --hard "origin/$branch"; then
                        echo "Error: Failed to reset to origin/$branch"
                        exit 1
                    fi

                    echo "Successfully switched to remote branch '$branch'"
                    echo "Current branch is now: $(git rev-parse --abbrev-ref HEAD)"
                    echo "Branch is exactly at remote state"
                    
                    # 確認のため状態を表示
                    git status
                else
                    echo "Operation cancelled."
                fi
                break
            fi
        done
    else
        echo "Operation cancelled."
    fi
    exit 0
}

# スクリプトの場所を取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/gish-tools"
VENV_PYTHON="${TOOLS_DIR}/venv/bin/python3"
COMMIT_MESSAGE_SCRIPT="${TOOLS_DIR}/generate_commit_message.py"

generate_smart_commit_message() {
    # Python仮想環境とスクリプトの存在確認
    if [ ! -f "$VENV_PYTHON" ] || [ ! -f "$COMMIT_MESSAGE_SCRIPT" ]; then
        echo "AI commit message generation not available. Using manual input."
        commit_message=""
        return 1
    fi

    echo "Generating commit message with AI... please wait."
    commit_message=$("$VENV_PYTHON" "$COMMIT_MESSAGE_SCRIPT" 2>&1)
    if [ $? -eq 0 ]; then
        echo "Generated commit message: $commit_message"
        read -p "Is this commit message okay? [y/N]: " user_confirmation
        if [[ $user_confirmation =~ ^[Yy]$ ]]; then
            echo "$commit_message"
        else
            while true; do
                read -p "Enter your commit message: " commit_message
                if [ -n "$commit_message" ]; then
                    break
                else
                    echo "Commit message cannot be empty. Please try again."
                fi
            done
            echo "$commit_message"
        fi
    else
        echo "Error: Failed to generate commit message. Falling back to manual entry."
        return 1
    fi
}


# arg check
case "$1" in
    --help)
        show_help
        ;;
    --s)
        stash_name="$2"  # Capture the second argument (stash name)
        stash_and_apply "$stash_name"  # Pass it to the function
        ;;
    --l)
        apply_stash_rollback
        ;;
    --p)
        easy_pull
        ;;
    "")
        # Suppress "command not found" error while maintaining functionality
        # This is a workaround for the function definition order issue
        (gish) 2>/dev/null
        ;;
    *)
        echo "Error: Invalid option '$1'. Use --help to see available options."
        exit 1
        ;;
esac

# gish main
gish() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $current_branch"
    git status

    read -p "Proceed with changes? (y/N): " proceed
    case "$proceed" in
        [yY]*)
            echo "Select action for changes:"
            echo "1) Commit to current branch ($current_branch)"
            echo "2) Commit to existing branch"
            echo "3) Create and commit to new branch"
            echo "4) Cancel operation"
            
            read -p "Enter your choice (1-4): " branch_choice

            case "$branch_choice" in
                1|2|3)
                    # タイムスタンプベースの自動stash
                    stash_name="gish_auto_$(date +%Y%m%d_%H%M%S)"
                    echo "Temporarily preserving changes..."
                    git stash push -m "$stash_name"

                    # 選択に応じたブランチ処理
                    case "$branch_choice" in
                        1)
                            target_branch="$current_branch"
                            ;;
                        2)
                            # 既存のブランチ一覧を取得して表示（現在のブランチを除外）
                            branches=($(git branch --list | sed 's/^* //g' | grep -v "^${current_branch}$" | sort))
                            if [ ${#branches[@]} -eq 0 ]; then
                                echo "No other branches found."
                                return 1
                            fi

                            echo "Available branches:"
                            echo "0) Cancel operation"
                            for i in "${!branches[@]}"; do
                                echo "$((i+1))) ${branches[i]}"
                            done

                            while true; do
                                read -p "Select branch number (0 to cancel): " branch_num
                                if [ "$branch_num" = "0" ]; then
                                    echo "Operation cancelled."
                                    git stash pop  # 変更を元に戻す
                                    return 1
                                elif [ "$branch_num" -gt 0 ] && [ "$branch_num" -le "${#branches[@]}" ]; then
                                    target_branch="${branches[$((branch_num-1))]}"
                                    
                                    # 強制上書きの確認
                                    echo "Warning: This will completely overwrite the contents of branch '$target_branch'."
                                    read -p "Are you sure to proceed? This process will execute complete overwrite of the existing branch you selected. (y/N): " force_confirm
                                    if [[ ! $force_confirm =~ ^[Yy]$ ]]; then
                                        echo "Operation cancelled."
                                        git stash pop  # 変更を元に戻す
                                        return 1
                                    fi
                                    
                                    # 確認後、強制的にブランチを更新
                                    git checkout -B "$target_branch"
                                    echo "Branch $target_branch has been updated."
                                    break
                                else
                                    echo "Invalid selection. Please try again."
                                fi
                            done
                            ;;
                        3)
                            read -p "Enter new branch name: " new_branch
                            original_branch="$current_branch"  # 元のブランチ名を保存
                            
                            # 新規ブランチ作成
                            if ! git checkout -b "$new_branch"; then
                                echo "Failed to create new branch."
                                git stash pop  # stashを戻す
                                return 1
                            fi
                            target_branch="$new_branch"

                            # 変更を復元
                            if ! git stash pop; then
                                echo "Failed to restore changes."
                                git checkout "$original_branch"  # 元のブランチに戻る
                                git branch -D "$new_branch"      # 作成したブランチを削除
                                echo "Rolled back to original state."
                                return 1
                            fi

                            read -p "Proceed with commit? (y/N): " commit_confirm
                            if [[ ! $commit_confirm =~ ^[Yy]$ ]]; then
                                echo "Operation cancelled."
                                git checkout "$original_branch"  # 元のブランチに戻る
                                git branch -D "$new_branch"      # 作成したブランチを削除
                                echo "New branch '$new_branch' has been deleted."
                                echo "Rolled back to original state."
                                return 1
                            fi
                            ;;
                    esac

                    # 選択1,2の場合のstash pop
                    if [ "$branch_choice" != "3" ]; then
                        git stash pop
                    fi

                    # Add and commit changes
                    git add -A
                    commit_message=""
                    generate_smart_commit_message
                    if [ $? -ne 0 ] || [ -z "$commit_message" ]; then
                        while true; do
                            read -p "Enter your commit message: " msg
                            if [ -n "$msg" ]; then
                                git commit -m "$msg"
                                break
                            else
                                echo "Commit message cannot be empty. Please try again."
                            fi
                        done
                    else
                        git commit -m "$commit_message"
                    fi

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
                4)
                    echo "Operation cancelled."
                    return 1
                    ;;
                *)
                    echo "Invalid choice. Exiting."
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Operation cancelled. Changes are not committed."
            ;;
    esac

    echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
    return 0  # success response
}

# gish()
gish "$@"