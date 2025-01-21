# Project Summary

## Directory Structure

- .aider.chat.history.md (file contents omitted as per ignore directive)
- .aider.input.history (file contents omitted as per ignore directive)
- .aider.tags.cache.v3 (directory inside omitted for simplicity)
- .git (directory inside omitted for simplicity)
- .gitignore (file contents omitted as per ignore directive)
- .summaryignore (file contents omitted as per ignore directive)
- LICENSE (file contents omitted as per ignore directive)
- README.md
- docs
- docs/Development_loadmap_gish.txt
- generate_commit_message.py
- gish.sh
- log

## File Contents

### README.md
```
# Gish - Git Command Helper

直感的なコマンドとインタラクティブなプロンプトで、一般的な Git 操作を簡素化し、ワークフローを強化する、強力で使いやすい Bash スクリプトです。

## バージョン

ソースコードを参照してください。

## 最近のトピック

- `gish --p` で Pull したあとターゲットのブランチに移動
- `gish --p` および `gish` で existing branch を選んだ際にリストされるブランチの一覧から、現在のブランチを除外

## 機能

### --s オプションによる Stash 管理

`--s` オプションに続けて stash 名を指定することで、現在の作業ディレクトリとインデックスの状態を stash に保存し、すぐに再適用できます。これにより、stash を頻繁に使用するユーザーのワークフローが簡素化されます。

例: `gish --s my_stash_name` は、現在の状態を my_stash_name として保存し、再適用して、更新された stash リストを表示します。stash 名にスペースは使用できません。名前が空の場合、名前は "yyyymmddhhmmss" になります。

### --l オプションによる Stash へのロールバック

`--l` オプションを使用すると、stash@{0} にロールバックし、その stash 以降に行われたすべての変更を破棄できます。これは、以前の状態にすばやく戻す場合に便利です。

例: `gish --l` は、確認を求められた後、作業ディレクトリを stash@{0} に戻します。

### --p オプションによるリモートからの簡単プル

`--p` オプションは、リモートブランチから最新の変更をプルし、ローカルの変更をすべて破棄する簡単な方法を提供します。

例: `gish --p` は、すべてのブランチをフェッチし、1 つを選択できるようにし、ローカルブランチを選択したリモートブランチにリセットします。

### OpenAI による自動コミットメッセージ生成

Gish は、OpenAI の API を使用してコミットメッセージを自動的に生成します。メッセージを生成した後、それが受け入れられるかどうかを確認するプロンプトが表示されます。コミットする前に、必要に応じてメッセージを編集できます。

スクリプトには OpenAI API キーが必要で、git diff に基づいて簡潔で関連性の高いコミットメッセージを生成するために使用されます。

### ユーザーフレンドリーなメッセージング

`--s`、`--l`、`--p` オプションを使用する際のメッセージがより明確になりました。スクリプトは、破壊的な操作の可能性のある操作をユーザーにガイドするために、詳細なプロンプトと警告を提供します。

### ヘルプオプション (--help)

`--help` オプションは、gish スクリプトの詳細な使用ガイドを表示し、新規ユーザーがスクリプトを効果的に理解して使用できるようにします。

## 改善点

### エラー処理

スクリプト全体でエラー処理が改善されました。無効なオプション、引数の欠落、その他のエラーが発生した場合、有益なエラーメッセージが表示され、予期しないスクリプトの動作を防ぎます。

たとえば、stash 名を引用符で囲まない `gish --s mini update` は、エラーを正しくトリガーするようになりました。

### コードの改善

- コードの可読性と構造が全体的に改善され、よりスムーズな操作と将来のメンテナンスが容易になりました。
- マイナーな問題を修正し、より明確にするために出力形式を改善しました。

## 使用方法

### 概要

Gish は、Git 操作を合理化し、安全に実行するように設計された Bash スクリプトです。コミット、ブランチの切り替え、プッシュ、stash の管理など、一連の Git タスクをインタラクティブに実行できます。

### 機能

- 未コミットの変更を管理
- コミットを作成
- ブランチを選択して切り替え
- 新しいブランチを作成
- リモートリポジトリにプッシュ
- 単一のコマンドで Git stash を保存および適用 (`--s` オプション)
- 単一のコマンドで特定の stash にロールバック (`--l` オプション)
- ローカルの変更を破棄してリモートから簡単にプル (`--p` オプション)
- 使用方法の説明付きのヘルプガイドにアクセス (`--help` オプション)
- OpenAI を使用してコミットメッセージを自動的に生成

### インストール手順

1. スクリプトを `gish` として次の場所に保存します: `~/.local/bin/gish` (注: `~` はホームディレクトリを表します)
2. スクリプトに実行権限を付与します:
```bash
chmod +x ~/.local/bin/gish
```

3. `.bashrc` または `.zshrc` に次の行を追加します:
```bash
export PATH="$HOME/.local/bin:$PATH"
alias gish='~/.local/bin/gish "$@"'
```

4. シェルを再起動するか、次のコマンドを実行して変更を適用します:
```bash
source ~/.bashrc  # または source ~/.zshrc
```

これで Git リポジトリ内で `gish` コマンドを実行できます。

### 操作手順

以下は、メイン機能（オプションなしの `gish`）の操作手順です：

1. `gish` コマンドを実行すると、現在のブランチが表示されます。未コミットの変更がある場合は、次のオプションが表示されます：
   - 変更をコミット
   - 変更を stash
   - 未コミットの変更を続行
   - 操作をキャンセル

2. 変更がステージングされ、`git status` の結果が表示されます。

3. コミットするかどうかを選択します：
   - はいの場合、コミットメッセージが生成され、変更したい場合はコミットメッセージを入力するように求められます。
   - いいえの場合、操作はキャンセルされます。

4. ターゲットブランチを選択します：
   - 現在のブランチ
   - 既存のブランチ
   - 新しいブランチ

5. 選択に応じて、ブランチが切り替えられるか、作成されます。

6. 最後に、選択したブランチにプッシュするかどうかを尋ねられます。

操作が完了すると、現在のブランチが表示されます。

### 注意事項

- コミットメッセージは空にできません。
- 未コミットの変更がある状態でブランチを切り替える場合は注意してください。
- プッシュ操作は、ネットワーク接続の状態に依存します。
- 操作がキャンセルされた場合、ステージングされた変更はリセットされません。

## 環境設定

### 環境変数

`.env` ファイルを `generate_commit_message.py` と同じディレクトリに配置します。このファイルには、OpenAI API キーを `OPENAI_API_KEY` として含める必要があります。

`.env` ファイルのコンテンツの例:
```
OPENAI_API_KEY=your_openai_api_key_here
```

### Python スクリプトのパス

Python スクリプト (`generate_commit_message.py`) が別のディレクトリにある場合は、gish スクリプトのパスを更新します:

```bash
commit_message=$("$VENV_PYTHON" "$COMMIT_MESSAGE_SCRIPT" 2>&1)
```

このパスがスクリプトを正しく指していることを確認して、実行エラーを回避してください。

### 必要なパッケージ

requirements.txt の内容:
```
openai>=1.0.0
python-dotenv>=0.19.0
```

### 仮想環境

Python スクリプトの実行には、仮想環境を使用します。以下の手順で設定してください：

1. 仮想環境を作成：
```bash
cd ~/.local/bin/gish-tools
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

注: gish スクリプトは内部で `activate_virtual_env()` を呼び出すため、通常の使用時には仮想環境を意識する必要はありません。コマンド実行時にのみ自動的に仮想環境が有効化されます。

### ファイル構成

```
~/.local/bin/
└── gish                    # メインのシェルスクリプト
~/.local/bin/gish-tools/    # gish関連のツール用ディレクトリ
    ├── generate_commit_message.py
    ├── requirements.txt
    ├── .env
    └── venv/              # Python 仮想環境
```

## トラブルシューティング

- スクリプトを実行できない場合:
  スクリプトファイルに実行権限があることを確認してください。
  ```bash
  chmod +x ~/.local/bin/gish
  ```

- ブランチの切り替えに失敗した場合:
  未コミットの変更がないか確認してください。競合がないことを確認してください。

- プッシュに失敗した場合:
  インターネット接続を確認してください。リモートリポジトリへのアクセス権があることを確認してください。

## カスタマイズ

スクリプトを編集することで、次のカスタマイズが可能です：

- デフォルトのブランチ名の変更
- 追加の Git コマンドの実行
- エラーメッセージのカスタマイズ

## サポート

問題が発生した場合や改善のための提案がある場合は、リポジトリの Issue トラッカーを通じて報告してください。
```

### docs/Development_loadmap_gish.txt
```
# gish script 機能開発展望
ver: 1.2.4

1. インテリジェントなコミットメッセージ生成
概要: 自然言語処理（NLP）を利用して、gitのコミットメッセージを自動生成する機能です。変更内容を解析し、適切なコミットメッセージを提案します。
詳細: Pythonスクリプトでファイルの差分（git diff）を解析し、その内容に基づいてOpenAI APIを使ってコミットメッセージを生成します。ユーザーは生成されたメッセージを確認し、採用するか編集するかを選べます。
使用例: gish --smart-commit

2. コードレビューアシスタント
概要: Pythonスクリプトを使って、変更されたコードの簡単なレビューを行い、改善点やバグの可能性を指摘する機能です。
詳細: AIベースのコード解析ツール（例えば、OpenAIのコードモデル）を利用して、変更内容をレビューし、潜在的な問題を指摘します。また、リファクタリングの提案も行うことができます。
使用例: gish --code-review

3. 自動ドキュメンテーション生成
概要: コードのコメントや変更履歴から、自動的にドキュメンテーションを生成する機能です。
詳細: Pythonスクリプトで、コード内のコメントや関数の定義を解析し、Markdown形式のドキュメントを自動生成します。さらに、変更履歴からリリースノートを作成することも可能です。
使用例: gish --generate-docs

4. プロジェクトの健康状態レポート
概要: プロジェクトの全体的な健康状態（未解決のバグ、テストカバレッジ、コミット頻度など）を自動的にレポートする機能です。
詳細: Pythonスクリプトで、gitリポジトリのデータを収集し、プロジェクトの状況を視覚化したレポートを生成します。これには、テストカバレッジの統計、未解決のバグリスト、最近のコミットの分析などが含まれます。
使用例: gish --health-report

5. 依存関係のセキュリティスキャン
概要: プロジェクトの依存関係（requirements.txtやpackage.jsonなど）をスキャンし、既知の脆弱性がないかチェックする機能です。
詳細: Pythonスクリプトを使って、プロジェクトの依存関係を分析し、脆弱性データベースと照合して潜在的なリスクを報告します。外部のセキュリティAPIと連携することで、最新の脆弱性情報を取得します。
使用例: gish --security-scan

6. インタラクティブなリリースノート生成
概要: 最新のリリースに含まれる変更を元に、インタラクティブにリリースノートを作成する機能です。
詳細: コミットメッセージやプルリクエストの内容を解析し、リリースノートのベースとなる情報を自動生成します。その後、ユーザーがインタラクティブに内容を編集し、最終的なリリースノートを完成させます。
使用例: gish --release-notes

7. インテリジェントなマージコンフリクト解決
概要: マージコンフリクトが発生した際に、AIを活用してコンフリクト解決の提案を行う機能です。
詳細: Pythonスクリプトで、コンフリクト箇所を解析し、最も合理的な解決策を提示します。場合によっては、解決方法の選択肢を複数提示し、ユーザーに選ばせることもできます。
使用例: gish --resolve-conflict

8. チームメンバーへの自動通知
概要: プロジェクトに重要な変更があった場合に、チームメンバーに自動通知を送る機能です。
詳細: gitのフック（例えば、ポストコミットフック）と連携して、特定の条件が満たされた場合に、Pythonスクリプトを介してSlackやメールで通知を送る機能を提供します。
使用例: gish --notify-team

9. 依存関係の自動更新
概要: プロジェクトの依存関係を自動的に更新し、互換性をチェックする機能です。
詳細: Pythonスクリプトでrequirements.txtやpackage.jsonの依存関係を自動的に最新バージョンに更新し、その後にテストを実行して互換性を確認します。
使用例: gish --update-deps

/* 完全自動ブランチmerge機能を検討したが、危険すぎるのでひとまず却下
10. ブランチの自動整理
概要: 古くなったブランチを自動的に整理（削除またはアーカイブ）する機能です。
詳細: Pythonスクリプトを使って、一定期間更新のないブランチを自動的に検出し、削除やアーカイブのアクションを行います。削除前には確認メッセージを表示することで誤削除を防ぎます。
使用例: gish --cleanup-branches
*/
```

### generate_commit_message.py
```
#!/usr/bin/env python3

from openai import OpenAI
import subprocess
import sys
import logging
import os
import json
from pathlib import Path
from dotenv import load_dotenv
import traceback

# スクリプトのディレクトリを取得
SCRIPT_DIR = Path(__file__).parent.absolute()

# ログファイルの設定
LOG_FILE = SCRIPT_DIR / "gish.log"
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# .envファイルの読み込み
env_path = SCRIPT_DIR / ".env"
load_dotenv(env_path)

# 環境変数からAPIキーを取得
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    logging.error("OpenAI API key not found.")
    print(f"Error: OpenAI API key not found. Please set it in the .env file at: {env_path}", file=sys.stderr)
    sys.exit(1)

# OpenAI クライアントの初期化
try:
    client = OpenAI(api_key=api_key)
    logging.info("OpenAI client initialized successfully.")
except Exception as e:
    logging.error(f"Failed to initialize OpenAI client: {e}")
    print("Error: Failed to initialize OpenAI client.", file=sys.stderr)
    sys.exit(1)

def filter_git_diff(diff_content):
    """
    Git差分から不要な変更を除外するためのフィルタリングロジック。
    以下の条件に合致するファイルは差分から除外されます。
    - ビルド生成物: dist/ や build/ ディレクトリ内のファイル
    - 開発環境関連: node_modules/ 内のファイル
    - 最小化済みファイル: *.min.js
    - キャッシュ・ログ: __pycache__, *.log
    
    Args:
        diff_content (str): Git差分の内容
    Returns:
        str: フィルタリング後の差分
    """
    logging.info("Starting filter_git_diff function.")
    
    excluded_patterns = [
    # ビルド生成物
    "dist/",        # ビルド成果物
    "build/",       # ビルド生成物
    "*.min.js",     # 最小化済みファイル

    # 開発環境固有のノイズ
    "node_modules/", # パッケージキャッシュ
    "__pycache__/",  # Pythonキャッシュ
    "*.log",         # ログファイル

    # OS固有ファイル
    ".DS_Store",     # macOSで生成されるシステムファイル
    "Thumbs.db",     # Windowsで生成されるシステムファイル

    # 中間生成物
    "*.tar",         # 圧縮ファイル（中間生成物）
    "*.tmp",         # 一時ファイル

    # IDE固有ファイル
    ".vscode/",      # Visual Studio Code
    ".idea/"         # JetBrains製IDE
    ]
    
    filtered_diff = [
        line for line in diff_content.split("\n")
        if not any(pattern in line for pattern in excluded_patterns)
    ]
    logging.debug(f"Filtered diff content: {filtered_diff}")
    return "\n".join(filtered_diff)

def get_git_diff():
    """Gitの差分を取得する"""
    logging.info("Starting get_git_diff function.")
    try:
        result = subprocess.run(
            ["git", "diff", "--cached"],
            capture_output=True,
            text=True,
            check=True
        )
        logging.debug(f"Git diff output:\n{result.stdout}")
        logging.info("Successfully retrieved git diff.")
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error(f"Git diff command failed: {e}")
        print("Error: Unable to retrieve git diff.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected error occurred while getting git diff: {e}\n{traceback.format_exc()}")
        print("Error: An unexpected error occurred while getting git diff.", file=sys.stderr)
        sys.exit(1)

def generate_commit_message(diff_content):
    """OpenAI APIを使用してコミットメッセージを生成する"""
    logging.info("Starting generate_commit_message function.")
    if not diff_content.strip():
        logging.warning("Empty diff content")
        print("No changes detected to generate commit message for.", file=sys.stderr)
        sys.exit(1)

    try:
        logging.debug("Calling OpenAI API...")
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful assistant for generating Git commit messages. "
                               "Generate clear, concise, and descriptive messages."
                },
                {
                    "role": "user",
                    "content": f"Generate a concise Git commit message for the following diff:\n{diff_content}"
                }
            ],
            max_tokens=256,
            timeout=30
        )
        commit_message = response.choices[0].message.content.strip()
        logging.info(f"Generated commit message: {commit_message}")
        return commit_message

    except Exception as e:
        logging.error(f"Failed to generate commit message: {e}\n{traceback.format_exc()}")
        print(f"Error: Failed to generate commit message: {str(e)}", file=sys.stderr)
        sys.exit(1)

def main():
    """メイン処理"""
    logging.info("Starting main function.")
    try:
        diff_content = get_git_diff()
        if not diff_content:
            logging.info("No changes detected to commit.")
            print("No changes to commit.")
            sys.exit(1)

        filtered_diff = filter_git_diff(diff_content)
        if not filtered_diff.strip():
            logging.info("No relevant changes to commit after filtering.")
            print("No relevant changes to commit.")
            sys.exit(1)

        commit_message = generate_commit_message(filtered_diff)
        print(commit_message)
        logging.info("Successfully generated and output commit message.")

    except Exception as e:
        logging.error(f"Commit message generation failed: {e}\n{traceback.format_exc()}")
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

    logging.info("Main function finished.")

if __name__ == "__main__":
    main()

```

### gish.sh
```
#!/bin/bash
# Help list
show_help() {
    echo "gish - A Git automation script"
    echo "ver: 1.4.0"
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
      echo "DEBUG: stash save successful. Stash name: $stash_name"
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
    read -p "Easy pull from remote repo anyway? *CAUTION: All local changes will be discarded and you will be synced with the remote branch. [y/N] " confirm
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

                read -p "Final confirmation - This will DISCARD ALL LOCAL CHANGES and switch to branch '$branch'. Continue? [y/N] " final_confirm
                if [[ $final_confirm =~ ^[Yy]$ ]]; then
                     if [[ "$DEBUG_MODE" == "true" ]]; then
                      echo "DEBUG: User confirmed to proceed with pull to branch: $branch."
                    fi
                    echo "Discarding local changes..."
                    if ! git reset --hard HEAD; then
                        echo "Error: Failed to discard local changes." >&2
                        if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: Failed to discard local changes."
                        fi
                        exit 1
                    fi
                    if [[ "$DEBUG_MODE" == "true" ]]; then
                        echo "DEBUG: Successfully discarded local changes."
                    fi

                    echo "Switching to remote branch '$branch'..."

                    # ローカルブランチの存在を確認
                    if git rev-parse --verify "$branch" >/dev/null 2>&1; then
                        # すでにローカルブランチがあるので checkout
                        if ! git checkout "$branch"; then
                            echo "Error: Failed to checkout local branch '$branch'" >&2
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                                echo "DEBUG: Failed to checkout local branch '$branch'."
                            fi
                            exit 1
                        fi
                        if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: Successfully checked out existing local branch '$branch'."
                        fi
                    else
                        # ローカルブランチがなければ新規作成
                        if ! git checkout -b "$branch" --track "origin/$branch"; then
                            echo "Error: Failed to create branch '$branch'" >&2
                            if [[ "$DEBUG_MODE" == "true" ]]; then
                              echo "DEBUG: Failed to create branch '$branch'."
                            fi
                            exit 1
                        fi
                        if [[ "$DEBUG_MODE" == "true" ]]; then
                            echo "DEBUG: Created new branch '$branch' from remote."
                         fi
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
ACTION="" # 実行するアクションを格納する変数
stash_name="" # stash名を格納する変数を追加

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --s)
        ACTION="stash_and_apply"
        shift
        if [ -n "$1" ] && [[ "$1" != -* ]]; then # 次の引数が存在し、オプションでない場合
            stash_name="$1"
            shift
        fi
        ;;
    --l)
        ACTION="apply_stash_rollback"
        shift
        ;;
    --p)
        ACTION="easy_pull"
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

case "$ACTION" in
    "stash_and_apply")
        stash_and_apply "$stash_name"
        ;;
    "apply_stash_rollback")
        apply_stash_rollback
        ;;
    "easy_pull")
        easy_pull
        ;;
    "")
        # 引数なしの場合のみ gish 関数を実行
        gish
        ;;
    *)
        if [[ "$DEBUG_MODE" == "true" ]]; then
           echo "DEBUG: No action matched: $ACTION"
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
```


## Log of commit message

### .gitignore

- f6d1272 - Your Name, Fri Nov 8 14:16:37 2024 +0900 : aider added in gitignore
- f172f14 - KunihiroS, Thu Aug 29 19:41:52 2024 +0900 : initial release
- 8dff496 - KunihiroS, Thu Aug 29 19:20:21 2024 +0900 : Initial commit

### .summaryignore

- 234c03a - KunihiroS, Sun Dec 29 23:15:50 2024 +0900 : Refine .summaryignore and gishscript_project_summary to improve ignored file patterns and update documentation
- 5cfc78e - KunihiroS, Fri Dec 27 17:14:00 2024 +0900 : update to add debug code.

### LICENSE

- 8dff496 - KunihiroS, Thu Aug 29 19:20:21 2024 +0900 : Initial commit

### README.md

- d4dd40f - Your Name, Tue Jan 7 17:04:55 2025 +0900 : Update README and gish script for version 1.4.0, enhancing user messaging and refining command options.
- df57dc9 - KunihiroS, Mon Jan 6 15:21:16 2025 +0900 : 更新されたREADME.mdにフォーマットの改善を行い、不要なファイルを削除してファイル構成を整理しました。
- 69186b5 - KunihiroS, Sat Dec 21 17:05:41 2024 +0900 : Refactor branch update commands and improve branch selection process
- dfafdb7 - KunihiroS, Thu Dec 19 00:04:12 2024 +0900 : Refactor README.md to improve the virtual environment setup and requirements handling with clear instructions.
- 2d3e60a - KunihiroS, Mon Dec 16 02:07:18 2024 +0900 : **Commit message:**
- 4b335a9 - KunihiroS, Sun Dec 15 22:19:58 2024 +0900 : modify the process order.
- 450ff55 - KunihiroS, Tue Sep 3 13:06:28 2024 +0900 : ℹ️ Update version to 1.2.8 in README.md and gish.sh, add recent topic section in README.md, optimize stash_and_apply check for local changes.
- 5d5b35b - KunihiroS, Tue Sep 3 10:54:36 2024 +0900 : ℹ️ Update version to 1.2.7 and allow --s option with an empty name to be "yyyymmddhhmmss"
- 5eee022 - KunihiroS, Tue Sep 3 01:31:27 2024 +0900 : Refactored Gishscript to version 1.2.6, integrating OpenAI for automatic commit message generation and addressing unexpected error during executions.
- 6e933f2 - KunihiroS, Tue Sep 3 01:01:10 2024 +0900 : Refactor README.md to address incomplete detailed info and unexpected error issue.
- 36e36c5 - KunihiroS, Tue Sep 3 00:39:14 2024 +0900 : Increment version to 1.2.5 and add auto-generated commit message by OpenAI.
- a66f99b - KunihiroS, Mon Sep 2 15:27:59 2024 +0900 : 1.2.4
- 6454be1 - KunihiroS, Mon Sep 2 15:08:08 2024 +0900 : minor
- 384d8a1 - KunihiroS, Mon Sep 2 14:49:43 2024 +0900 : 1.2.2
- d796bb0 - KunihiroS, Mon Sep 2 14:27:34 2024 +0900 : 1.2.1
- c09a774 - KunihiroS, Mon Sep 2 13:44:19 2024 +0900 : 1.2.0 release
- 87016a4 - KunihiroS, Sun Sep 1 15:33:06 2024 +0900 : 1.1.0 release
- 878120f - KunihiroS, Thu Aug 29 19:43:44 2024 +0900 : Readme updated
- 8dff496 - KunihiroS, Thu Aug 29 19:20:21 2024 +0900 : Initial commit

### docs/Development_loadmap_gish.txt

- 7b3efda - KunihiroS, Tue Sep 3 00:35:07 2024 +0900 : Commit: Add automatic generation of Git commit messages using OpenAI
- 522b0d0 - KunihiroS, Mon Sep 2 16:20:48 2024 +0900 : docs added

### generate_commit_message.py

- b641789 - KunihiroS, Sun Dec 29 16:30:27 2024 +0900 : Add filtering logic for Git diff to exclude unnecessary changes and improve error message formatting in `generate_commit_message.py`.
- 5cfc78e - KunihiroS, Fri Dec 27 17:14:00 2024 +0900 : update to add debug code.
- 2d3e60a - KunihiroS, Mon Dec 16 02:07:18 2024 +0900 : **Commit message:**
- 5d5b35b - KunihiroS, Tue Sep 3 10:54:36 2024 +0900 : ℹ️ Update version to 1.2.7 and allow --s option with an empty name to be "yyyymmddhhmmss"
- e6a49ef - KunihiroS, Tue Sep 3 01:00:25 2024 +0900 : Refactor commit message handling in generate_commit_message.py
- 7b3efda - KunihiroS, Tue Sep 3 00:35:07 2024 +0900 : Commit: Add automatic generation of Git commit messages using OpenAI

### gish.sh

- d4dd40f - Your Name, Tue Jan 7 17:04:55 2025 +0900 : Update README and gish script for version 1.4.0, enhancing user messaging and refining command options.
- 5cfc78e - KunihiroS, Fri Dec 27 17:14:00 2024 +0900 : update to add debug code.
- aa899b8 - KunihiroS, Sun Dec 22 20:20:09 2024 +0900 : Refactor gish.sh: Update version to 1.3.8, improve branch handling logic, and enhance push confirmation process
- c19e166 - KunihiroS, Sun Dec 22 19:36:24 2024 +0900 : Refactor: Improve `easy_pull` function for easier remote branch selection and safer branch switching
- 31b8ceb - KunihiroS, Sat Dec 21 17:02:58 2024 +0900 : Refactor script to exclude current branch from branch list
- d344114 - KunihiroS, Sat Dec 21 16:48:52 2024 +0900 : Update version to 1.3.5, enhance --p option to pull from remote, discard local changes, and move to targeted branch. Fix rollback functionality in easy_pull function.
- e3d07dd - KunihiroS, Fri Dec 20 01:21:37 2024 +0900 : Refactor: Update version to 1.3.4 and activate virtual environment if available.
- b95ffd9 - KunihiroS, Mon Dec 16 00:56:24 2024 +0900 : fixing smart commit message function.
- 4b335a9 - KunihiroS, Sun Dec 15 22:19:58 2024 +0900 : modify the process order.
- aef29bb - Your Name (aider), Tue Nov 5 17:28:00 2024 +0900 : fix: Ensure valid branch selection with feedback in gish command
- 22e48c3 - Your Name (aider), Tue Nov 5 17:22:30 2024 +0900 : fix: Resolve branch selection issue in gish command by using git branch --list
- 450ff55 - KunihiroS, Tue Sep 3 13:06:28 2024 +0900 : ℹ️ Update version to 1.2.8 in README.md and gish.sh, add recent topic section in README.md, optimize stash_and_apply check for local changes.
- 743d43b - KunihiroS, Tue Sep 3 12:37:08 2024 +0900 : Refactor branch selection logic in easy_pull() function
- 93dd817 - KunihiroS, Tue Sep 3 12:22:52 2024 +0900 : arg checker update
- 5467125 - KunihiroS, Tue Sep 3 11:13:22 2024 +0900 : Refactor error check in gish.sh
- 5d5b35b - KunihiroS, Tue Sep 3 10:54:36 2024 +0900 : ℹ️ Update version to 1.2.7 and allow --s option with an empty name to be "yyyymmddhhmmss"
- e6a49ef - KunihiroS, Tue Sep 3 01:00:25 2024 +0900 : Refactor commit message handling in generate_commit_message.py
- 7b3efda - KunihiroS, Tue Sep 3 00:35:07 2024 +0900 : Commit: Add automatic generation of Git commit messages using OpenAI
- a66f99b - KunihiroS, Mon Sep 2 15:27:59 2024 +0900 : 1.2.4
- 1ed6537 - KunihiroS, Mon Sep 2 15:14:47 2024 +0900 : 1.2.3
- 6454be1 - KunihiroS, Mon Sep 2 15:08:08 2024 +0900 : minor
- 384d8a1 - KunihiroS, Mon Sep 2 14:49:43 2024 +0900 : 1.2.2
- f1cc0a3 - KunihiroS, Mon Sep 2 14:31:20 2024 +0900 : small update
- d796bb0 - KunihiroS, Mon Sep 2 14:27:34 2024 +0900 : 1.2.1
- cd21b51 - KunihiroS, Mon Sep 2 13:51:51 2024 +0900 : mini modify
- 159af2f - KunihiroS, Mon Sep 2 13:49:44 2024 +0900 : test
- c09a774 - KunihiroS, Mon Sep 2 13:44:19 2024 +0900 : 1.2.0 release
- 87016a4 - KunihiroS, Sun Sep 1 15:33:06 2024 +0900 : 1.1.0 release
- a7a2074 - KunihiroS, Thu Aug 29 19:50:58 2024 +0900 : minor change
- f172f14 - KunihiroS, Thu Aug 29 19:41:52 2024 +0900 : initial release
