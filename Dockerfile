# ベースとなるDockerイメージを指定
FROM mcr.microsoft.com/playwright:focal

# ワーキングディレクトリを設定
WORKDIR /app

# 必要なパッケージをインストール
RUN npm init -y
RUN npm install playwright typescript ts-node

# スクリプトをコピー
COPY script.ts /app/script.ts

# コンテナ起動時に実行するコマンドを設定
CMD ["npx", "ts-node", "script.ts"]
