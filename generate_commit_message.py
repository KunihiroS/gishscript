#!/usr/bin/env python3

from openai import OpenAI
import subprocess
import sys
import logging
import os
import json
from pathlib import Path
from dotenv import load_dotenv
import traceback  # スタックトレースを記録するために追加

# スクリプトのディレクトリを取得
SCRIPT_DIR = Path(__file__).parent.absolute()

# ログファイルの設定
LOG_FILE = SCRIPT_DIR / "gish.log"
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.DEBUG,  # デフォルトをDEBUGレベルに変更
    format='%(asctime)s - %(levelname)s - %(message)s'
)


# .envファイルの読み込み（同じディレクトリにある.envを探す）
env_path = SCRIPT_DIR / ".env"
load_dotenv(env_path)

# 環境変数からAPIキーを取得
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    logging.error("OpenAI API key not found.")
    print("Error: OpenAI API key not found. Please set it in the .env file at: " + str(env_path), file=sys.stderr)
    sys.exit(1)

# OpenAI クライアントの初期化
try:
    client = OpenAI(api_key=api_key)
    logging.info("OpenAI client initialized successfully.")
except Exception as e:
    logging.error(f"Failed to initialize OpenAI client: {e}")
    print("Error: Failed to initialize OpenAI client.", file=sys.stderr)
    sys.exit(1)

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
            model="gpt-3.5-turbo",
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
            max_tokens=120,
            timeout=15
        )
        
        logging.debug(f"API Response: {json.dumps(response.model_dump(), indent=2)}")
        
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

        commit_message = generate_commit_message(diff_content)
        print(commit_message)
        logging.info("Successfully generated and output commit message.")

    except Exception as e:
        logging.error(f"Commit message generation failed: {e}\n{traceback.format_exc()}")
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

    logging.info("Main function finished.")

if __name__ == "__main__":
    main()