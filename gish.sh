#!/bin/bash
# Help list
show_help() {
    echo "gish - A Git automation script"
    echo "ver: 1.3.9"
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
    echo "  --debug       Enable debug mode, outputs detailed logs."
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
activate_virtual_env() {
    if [ -d "$HOME/.local/bin/gish-tools/venv" ]; then
        source "$HOME/.local/bin/gish-tools/venv/bin/activate"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to activate virtual environment." >&2
            exit 1
        fi
        if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: Virtual environment activated."
        fi
    fi
}

# stash save "name" -> stash apply stash@{0}
stash_and_apply() {
    local stash_name="$1"
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "DEBUG: stash_and_apply function started with stash_name: $stash_name"
    fi

    # If no stash name is provided, use the current timestamp as the stash name
    if [ -z "$stash_name" ]; then
        stash_name=$(date +"%Y%m%d%H%M%S")
    fi
    if [[ "$DEBUG_MODE" == "true" ]]; then
         echo "DEBUG: Using stash_name: $stash_name"
    fi


    # ワーキングツリーに変更があるか確認
    if ! git diff-index --quiet HEAD --; then
        if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: Local changes detected. proceeding to stash"
        fi
    else
        echo "No local changes to save"
        exit 0  # スクリプトを終了する
    fi
    
    if ! git stash save "$stash_name" ; then
       echo "Error: Failed to save the stash. Stash name: $stash_name" >&2
        if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: Failed to save the stash. Stash name: $stash_name"
          git stash list
        fi
        exit 1
    fi
    if [[ "$DEBUG_MODE" == "true" ]]; then
      echo "DEBUG: stash save successful.  Stash name: $stash_name"
      git stash list
    fi


    if ! git stash apply "stash@{0}"; then
        echo "Error: Failed to apply the stash." >&2
        if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: Failed to apply the stash."
        fi
        exit 1
    fi
    if [[ "$DEBUG_MODE" == "true" ]]; then
      echo "DEBUG: stash apply successful"
    fi

    echo "Stashed and reapplied state: $stash_name"
    echo "Current stash list:"
    git stash list
    echo "Stash saved as '$stash_name'. The code has been reverted to the '$stash_name' condition."
    if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: stash_and_apply function finished successfully."
    fi
    exit 0  # スクリプトを終了する
}

# reset --hard -> stash apply stash@{0}
apply_stash_rollback() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "DEBUG: apply_stash_rollback function started"
    fi
    read -p "Want to apply stash@{0}? *CAUTION: All rollback to stash@{0} condition, your modify will be deleted. [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        if ! git reset --hard; then
          echo "Error: Failed to reset --hard" >&2
          if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: Failed to reset --hard."
          fi
          exit 1
        fi
        if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: git reset --hard successful"
        fi

        if ! git stash apply "stash@{0}"; then
            echo "Error: Failed to apply the stash." >&2
             if [[ "$DEBUG_MODE" == "true" ]]; then
              echo "DEBUG: Failed to apply the stash."
             fi
             exit 1
        fi
        if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: git stash apply successful"
        fi
        echo "Rolled back to stash@{0}. All changes after stash@{0} have been deleted."
    else
        echo "Operation cancelled."
    fi
     if [[ "$DEBUG_MODE" == "true" ]]; then
          echo "DEBUG: apply_stash_rollback function finished successfully."
    fi
    exit 0  # スクリプトを終了する
}

# reset --hard -> pull origin {branch}
easy_pull() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
       echo "DEBUG: easy_pull function started"
    fi
    read -p "Easy pull from remote repo anyway? *CAUTION: All rollback to remote repo condition, your modify will be deleted. [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # Get current branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: Current branch: $current_branch"
        fi

        # Fetch all remote branches
        echo "Fetching remote repository information..."
        if ! git fetch --all --prune; then
            echo "Error: Failed to fetch remote repository information." >&2
            if [[ "$DEBUG_MODE" == "true" ]]; then
              echo "DEBUG: Failed to fetch remote repository information."
            fi
            exit 1
        fi
         if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: git fetch --all --prune successful"
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
            if [[ "$DEBUG_MODE" == "true" ]]; then
              echo "DEBUG: No other remote branches available."
            fi
            exit 1
        fi
         if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: Remote branches loaded: ${remote_branches[@]}"
         fi


        # Display branch selection
        echo "Current branch: $current_branch (excluded from list)"
        select branch in "${remote_branches[@]}"; do
            if [ -n "$branch" ]; then
                # Validate branch name
                if [[ "$branch" == "HEAD" ]]; then
                    echo "Invalid branch selection." >&2
                    if [[ "$DEBUG_MODE" == "true" ]]; then
                       echo "DEBUG: Invalid branch selection: $branch."
                    fi
                    exit 1
                fi
                 if [[ "$DEBUG_MODE" == "true" ]]; then
                    echo "DEBUG: selected branch: $branch"
                 fi

                read -p "Final confirmation - This will delete all local changes and switch to branch '$branch'. Continue? [y/N] " final_confirm
                if [[ $final_confirm =~ ^[Yy]$ ]]; then
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                      echo "DEBUG: User confirmed to proceed with pull to branch: $branch."
                    fi
                    echo "Switching to remote branch '$branch'..."

                    # まずチェックアウトを試みる
                    if ! git checkout "$branch" 2>/dev/null; then
                        # ローカルブランチが存在しない場合は新規作成
                        if ! git checkout -b "$branch" --track "origin/$branch"; then
                            echo "Error: Failed to create branch '$branch'" >&2
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                              echo "DEBUG: Failed to create branch '$branch'."
                            fi
                            exit 1
                        fi
                        if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: created branch '$branch'."
                         fi
                    fi
                   if [[ "$DEBUG_MODE" == "true" ]]; then
                       echo "DEBUG: git checkout successful. branch: $branch"
                   fi


                    # 確実にリモートの状態にリセット
                    if ! git reset --hard "origin/$branch"; then
                        echo "Error: Failed to reset to origin/$branch" >&2
                         if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: Failed to reset to origin/$branch"
                         fi
                        exit 1
                    fi
                    if [[ "$DEBUG_MODE" == "true" ]]; then
                      echo "DEBUG: git reset --hard successful. branch: $branch"
                    fi
                    echo "Successfully switched to remote branch '$branch'"
                    echo "Current branch is now: $(git rev-parse --abbrev-ref HEAD)"
                    echo "Branch is exactly at remote state"

                    # 確認のため状態を表示
                    git status
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                        echo "DEBUG: Successfully switched to remote branch '$branch'"
                     fi
                else
                    echo "Operation cancelled."
                    if [[ "$DEBUG_MODE" == "true" ]]; then
                        echo "DEBUG: Operation cancelled by user."
                    fi
                fi
                break
            fi
        done
    else
        echo "Operation cancelled."
        if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: Operation cancelled by user."
        fi
    fi
    if [[ "$DEBUG_MODE" == "true" ]]; then
      echo "DEBUG: easy_pull function finished successfully."
    fi
    exit 0
}

# スクリプトの場所を取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/gish-tools"
VENV_PYTHON="${TOOLS_DIR}/venv/bin/python3"
COMMIT_MESSAGE_SCRIPT="${TOOLS_DIR}/generate_commit_message.py"
DEBUG_FILE="${SCRIPT_DIR}/gish_debug.log"

generate_smart_commit_message() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
      echo "DEBUG: generate_smart_commit_message function started."
    fi
    # Python仮想環境とスクリプトの存在確認
    if [ ! -f "$VENV_PYTHON" ] || [ ! -f "$COMMIT_MESSAGE_SCRIPT" ]; then
        echo "AI commit message generation not available. Using manual input." >&2
        if [[ "$DEBUG_MODE" == "true" ]]; then
            echo "DEBUG: AI commit message generation not available. Using manual input."
        fi
        commit_message=""
        return 1
    fi

    echo "Generating commit message with AI... please wait."
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "DEBUG: Calling Python script: $VENV_PYTHON $COMMIT_MESSAGE_SCRIPT"
    fi
    commit_message=$("$VENV_PYTHON" "$COMMIT_MESSAGE_SCRIPT" 2>&1)
    if [ $? -eq 0 ]; then
        if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: Python script execution successful. Commit message: $commit_message"
        fi
        echo "Generated commit message: $commit_message"
        read -p "Is this commit message okay? [y/N]: " user_confirmation
        if [[ $user_confirmation =~ ^[Yy]$ ]]; then
            if [[ "$DEBUG_MODE" == "true" ]]; then
                 echo "DEBUG: User accepted generated commit message."
             fi
            echo "$commit_message"
        else
            if [[ "$DEBUG_MODE" == "true" ]]; then
                echo "DEBUG: User rejected generated commit message. Prompting for manual input."
            fi
            while true; do
                read -p "Enter your commit message: " commit_message
                if [ -n "$commit_message" ]; then
                    if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: Manual commit message entered: $commit_message"
                    fi
                    break
                else
                    echo "Commit message cannot be empty. Please try again." >&2
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                       echo "DEBUG: Commit message cannot be empty."
                     fi
                fi
            done
            echo "$commit_message"
        fi
    else
        echo "Error: Failed to generate commit message. Falling back to manual entry." >&2
        if [[ "$DEBUG_MODE" == "true" ]]; then
             echo "DEBUG: Failed to generate commit message. Falling back to manual entry."
        fi
        return 1
    fi
    if [[ "$DEBUG_MODE" == "true" ]]; then
         echo "DEBUG: generate_smart_commit_message function finished successfully."
    fi
}


# arg check
DEBUG_MODE="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --s)
        shift
        stash_name="$1"
        if [[ -z "$stash_name" ]]; then
            echo "Error: Stash name is required after --s option." >&2
            exit 1
        fi
        shift
        ;;
    --l)
        shift
        ;;
    --p)
        shift
        ;;
    --debug)
        DEBUG_MODE="true"
        shift
        ;;
    *)
      echo "Error: Invalid option '$1'. Use --help to see available options." >&2
      exit 1
      ;;
  esac
done

# Activate virtual environment
activate_virtual_env


#DEBUG_MODE="true"  # デバッグモードを有効にするには、この行のコメントアウトを解除してください。
if [[ "$DEBUG_MODE" == "true" ]]; then
  echo "DEBUG MODE ENABLED. Detailed logging enabled."
  exec 3>&1 4>&2 >"$DEBUG_FILE" 2>&4
  echo "--- Start of gish debug log ---"
  set -x # コマンド実行をトレース
fi

case "$1" in
    --s)
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
        if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: No action matched: $1"
        fi
       exit 1
        ;;
esac

# gish main
gish() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "DEBUG: gish function started"
        echo "DEBUG: Current branch is $(git rev-parse --abbrev-ref HEAD)"
        git status
    fi
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
             if [[ "$DEBUG_MODE" == "true" ]]; then
               echo "DEBUG: User choice for branch operation: $branch_choice"
             fi

            case "$branch_choice" in
                1|2|3)
                    # タイムスタンプベースの自動stash
                    stash_name="gish_auto_$(date +%Y%m%d_%H%M%S)"
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                       echo "DEBUG: Temporary stash name: $stash_name"
                     fi
                    echo "Temporarily preserving changes..."
                    if ! git stash push -m "$stash_name"; then
                      echo "Error: Failed to save temporary stash." >&2
                       if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: Failed to save temporary stash."
                       fi
                      exit 1
                    fi
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                        echo "DEBUG: Temporary stash saved."
                     fi

                    # 選択に応じたブランチ処理
                    case "$branch_choice" in
                        1)
                             if [[ "$DEBUG_MODE" == "true" ]]; then
                               echo "DEBUG: User selected commit to current branch"
                             fi
                            target_branch="$current_branch"
                            ;;
                        2)
                             if [[ "$DEBUG_MODE" == "true" ]]; then
                               echo "DEBUG: User selected commit to existing branch"
                             fi
                            # 既存のブランチ一覧を取得して表示（現在のブランチを除外）
                            mapfile -t branches < <(git branch -r | \
                                grep '^  origin/' | \
                                grep -v '/HEAD' | \
                                sed 's#  origin/##' | \
                                grep -v "^${current_branch}$" | \
                                sort -u)

                            if [ ${#branches[@]} -eq 0 ]; then
                                echo "No other branches found." >&2
                                if [[ "$DEBUG_MODE" == "true" ]]; then
                                  echo "DEBUG: No other branches found."
                                 fi
                                return 1
                            fi
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                              echo "DEBUG: Available branches: ${branches[@]}"
                            fi

                            echo "Available branches:"
                            echo "0) Cancel operation"
                            for i in "${!branches[@]}"; do
                                echo "$((i+1))) ${branches[i]}"
                            done

                            while true; do
                                read -p "Select branch number (0 to cancel): " branch_num
                                 if [[ "$DEBUG_MODE" == "true" ]]; then
                                    echo "DEBUG: User selected branch number: $branch_num"
                                 fi
                                if [ "$branch_num" = "0" ]; then
                                    echo "Operation cancelled."
                                    if ! git stash pop; then
                                       echo "Error: Failed to restore stash." >&2
                                       if [[ "$DEBUG_MODE" == "true" ]]; then
                                          echo "DEBUG: Failed to restore stash."
                                       fi
                                       return 1
                                    fi
                                     if [[ "$DEBUG_MODE" == "true" ]]; then
                                        echo "DEBUG: Stash popped after cancellation."
                                    fi
                                    return 1
                                elif [ "$branch_num" -gt 0 ] && [ "$branch_num" -le "${#branches[@]}" ]; then
                                    target_branch="${branches[$((branch_num-1))]}"
                                     if [[ "$DEBUG_MODE" == "true" ]]; then
                                        echo "DEBUG: Selected target branch: $target_branch"
                                     fi

                                    # 強制上書きの確認
                                    echo "Warning: This will completely overwrite the remote branch '$target_branch'."
                                    read -p "Are you sure to proceed? This process will execute complete overwrite of the selected branch. (y/N): " force_confirm
                                    if [[ ! $force_confirm =~ ^[Yy]$ ]]; then
                                        echo "Operation cancelled."
                                         if ! git stash pop; then
                                           echo "Error: Failed to restore stash." >&2
                                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                              echo "DEBUG: Failed to restore stash."
                                            fi
                                          return 1
                                        fi
                                       if [[ "$DEBUG_MODE" == "true" ]]; then
                                          echo "DEBUG: Stash popped after cancellation."
                                       fi
                                        return 1
                                    fi
                                     if [[ "$DEBUG_MODE" == "true" ]]; then
                                        echo "DEBUG: User confirmed force overwrite to $target_branch"
                                     fi

                                    # 強制的にブランチを切り替え
                                    if ! git checkout -B "$target_branch"; then
                                        echo "Failed to switch branch." >&2
                                        if ! git stash pop; then
                                           echo "Error: Failed to restore stash." >&2
                                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                              echo "DEBUG: Failed to restore stash."
                                            fi
                                          return 1
                                        fi
                                          if [[ "$DEBUG_MODE" == "true" ]]; then
                                            echo "DEBUG: Stash popped after failed checkout."
                                          fi
                                        return 1
                                    fi
                                      if [[ "$DEBUG_MODE" == "true" ]]; then
                                         echo "DEBUG: git checkout successful. Target branch: $target_branch"
                                      fi
                                    echo "Branch $target_branch has been updated."
                                    break
                                else
                                    echo "Invalid selection. Please try again." >&2
                                      if [[ "$DEBUG_MODE" == "true" ]]; then
                                        echo "DEBUG: Invalid branch selection. Please try again."
                                      fi
                                fi
                            done
                            ;;

                        3)
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: User selected create and commit to new branch."
                             fi
                            read -p "Enter new branch name: " new_branch
                            original_branch="$current_branch"  # 元のブランチ名を保存
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: New branch name: $new_branch"
                            fi

                            # 新規ブランチ作成
                            if ! git checkout -b "$new_branch"; then
                                echo "Failed to create new branch." >&2
                                  if ! git stash pop; then
                                   echo "Error: Failed to restore stash." >&2
                                   if [[ "$DEBUG_MODE" == "true" ]]; then
                                     echo "DEBUG: Failed to restore stash."
                                   fi
                                  return 1
                                fi
                                  if [[ "$DEBUG_MODE" == "true" ]]; then
                                     echo "DEBUG: Stash popped after failed new branch."
                                  fi
                                return 1
                            fi
                            target_branch="$new_branch"
                             if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: git checkout -b $new_branch successful."
                            fi


                            # 変更を復元
                            if ! git stash pop; then
                                echo "Failed to restore changes." >&2
                                git checkout "$original_branch"  # 元のブランチに戻る
                                git branch -D "$new_branch"      # 作成したブランチを削除
                                echo "Rolled back to original state."
                                if [[ "$DEBUG_MODE" == "true" ]]; then
                                     echo "DEBUG: Failed to pop stash and rolled back to original branch."
                                     echo "DEBUG: git checkout $original_branch and git branch -D $new_branch were executed."
                                 fi
                                return 1
                            fi
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: git stash pop successful after creating branch."
                             fi


                            read -p "Proceed with commit? (y/N): " commit_confirm
                            if [[ ! $commit_confirm =~ ^[Yy]$ ]]; then
                                echo "Operation cancelled."
                                git checkout "$original_branch"  # 元のブランチに戻る
                                git branch -D "$new_branch"      # 作成したブランチを削除
                                echo "New branch '$new_branch' has been deleted."
                                echo "Rolled back to original state."
                                if [[ "$DEBUG_MODE" == "true" ]]; then
                                    echo "DEBUG: Operation cancelled after creating branch."
                                    echo "DEBUG: git checkout $original_branch and git branch -D $new_branch were executed."
                                 fi
                                return 1
                            fi
                             if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: User confirmed commit to new branch."
                             fi
                            ;;
                    esac

                    # 選択1,2の場合のstash pop
                    if [ "$branch_choice" != "3" ]; then
                       if ! git stash pop; then
                         echo "Error: Failed to restore stash." >&2
                         if [[ "$DEBUG_MODE" == "true" ]]; then
                             echo "DEBUG: Failed to pop stash after branch selection."
                         fi
                        return 1
                       fi
                       if [[ "$DEBUG_MODE" == "true" ]]; then
                             echo "DEBUG: git stash pop success after branch selection."
                        fi
                    fi
                   if [[ "$DEBUG_MODE" == "true" ]]; then
                     echo "DEBUG: Prepare to add and commit."
                   fi

                    # Add and commit changes
                    if ! git add -A; then
                      echo "Error: Failed to add changes." >&2
                      if [[ "$DEBUG_MODE" == "true" ]]; then
                           echo "DEBUG: Failed to add changes."
                       fi
                      return 1
                    fi
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: git add -A successful."
                     fi
                    commit_message=""
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                          echo "DEBUG: Calling generate_smart_commit_message function"
                       fi
                    generate_smart_commit_message
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                       echo "DEBUG: generate_smart_commit_message return value $?"
                      fi
                    if [ $? -ne 0 ] || [ -z "$commit_message" ]; then
                        while true; do
                            read -p "Enter your commit message: " msg
                            if [ -n "$msg" ]; then
                                if ! git commit -m "$msg"; then
                                  echo "Error: Failed to commit changes." >&2
                                  if [[ "$DEBUG_MODE" == "true" ]]; then
                                       echo "DEBUG: Failed to commit changes."
                                  fi
                                  return 1
                                fi
                                 if [[ "$DEBUG_MODE" == "true" ]]; then
                                      echo "DEBUG: git commit -m \"$msg\" successful"
                                 fi
                                break
                            else
                                echo "Commit message cannot be empty. Please try again." >&2
                                 if [[ "$DEBUG_MODE" == "true" ]]; then
                                    echo "DEBUG: Commit message cannot be empty. Please try again."
                                 fi
                            fi
                        done
                    else
                       if ! git commit -m "$commit_message"; then
                         echo "Error: Failed to commit changes with generated message." >&2
                        if [[ "$DEBUG_MODE" == "true" ]]; then
                           echo "DEBUG: Failed to commit changes with generated message"
                        fi
                       return 1
                       fi
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: git commit -m \"$commit_message\" successful"
                     fi
                    fi

                    read -p "Push changes to $target_branch? (y/N): " push_confirm
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                        echo "DEBUG: User choice for push to $target_branch: $push_confirm"
                      fi
                    if [[ $push_confirm =~ ^[Yy]$ ]]; then
                        if ! git push --force origin "$target_branch"; then
                            echo "Push to $target_branch failed. Check your connection or remote settings." >&2
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: Push to $target_branch failed."
                             fi
                        else
                             if [[ "$DEBUG_MODE" == "true" ]]; then
                                 echo "DEBUG: Push to $target_branch successful."
                             fi
                            echo "Push to $target_branch successful."
                        fi
                    else
                        echo "Push cancelled."
                         if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: Push cancelled by user."
                         fi
                    fi
                    ;;
                4)
                    echo "Operation cancelled."
                      if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: Operation cancelled by user."
                       fi
                    return 1
                    ;;
                *)
                    echo "Invalid choice. Exiting." >&2
                      if [[ "$DEBUG_MODE" == "true" ]]; then
                         echo "DEBUG: Invalid branch choice. Exiting."
                      fi
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Operation cancelled. Changes are not committed."
              if [[ "$DEBUG_MODE" == "true" ]]; then
                 echo "DEBUG: Operation cancelled. Changes are not committed."
               fi
            ;;
    esac

    echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
      if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: gish function finished successfully."
           echo "DEBUG: Current branch is $(git rev-parse --abbrev-ref HEAD)"
       fi
    return 0  # success response
}

# gish()
gish "$@"

if [[ "$DEBUG_MODE" == "true" ]]; then
  echo "--- End of gish debug log ---"
  exec 3>&- 4>&-
fi