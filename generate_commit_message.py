from openai import OpenAI
import subprocess
import sys
import logging
import os
import json
from dotenv import load_dotenv

# ログの設定
logging.basicConfig(filename="/home/kunihiros/dev/aider/projects/gishscript/gish.log", level=logging.CRITICAL, format='%(asctime)s - %(levelname)s - %(message)s')

# .envファイルの読み込み
load_dotenv()

# 環境変数からAPIキーとログファイルのパスを取得
api_key = os.getenv("OPENAI_API_KEY")
log_file_path = os.getenv("LOG_FILE_PATH")

if not api_key:
    logging.error("OpenAI API key not found.")
    sys.exit("Error: OpenAI API key not found. Please set it in the .env file.")

# OpenAI クライアントの初期化
client = OpenAI(api_key=api_key)

# Gitの差分を取得
def get_git_diff():
    try:
        result = subprocess.run(["git", "diff", "--cached"], capture_output=True, text=True)
        result.check_returncode()
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error(f"Git diff command failed: {e}")
        sys.exit("Error: Unable to retrieve git diff.")
    except Exception as e:
        logging.error(f"Unexpected error occurred while getting git diff: {e}")
        sys.exit("Error: An unexpected error occurred.")

# OpenAI APIを使用してコミットメッセージを生成
def generate_commit_message(diff_content):
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant for generating Git commit messages."},
                {"role": "user", "content": f"Generate a concise Git commit message for the following diff:\n{diff_content}"}
            ],
            max_tokens=120,
            timeout=15
        )
        
        # デバッグ情報をログに記録
        logging.debug(f"API Response: {json.dumps(response.model_dump(), indent=2)}")
        
        # 新しい方法でメッセージにアクセス
        commit_message = response.choices[0].message.content.strip()
        logging.info(f"Generated commit message: {commit_message}")
        return commit_message
    except Exception as e:
        logging.error(f"Unexpected error occurred while generating commit message: {str(e)}")
        logging.error(f"Error type: {type(e).__name__}")
        logging.error(f"Error details: {e}")
        sys.exit(f"Error: An unexpected error occurred while generating commit message. Details: {str(e)}")

# メイン処理
def main():
    logging.info("Starting commit message generation process.")
    diff_content = get_git_diff()
    if not diff_content:
        logging.info("No changes detected to commit.")
        sys.exit("No changes to commit.")

    try:
        commit_message = generate_commit_message(diff_content)
        print(commit_message)
        logging.info(f"Generated commit message: {commit_message}")
    except Exception as e:
        logging.error(f"Commit message generation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
