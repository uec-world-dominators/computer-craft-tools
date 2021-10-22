# スクリプトファイルのデプロイ

## 概要

ComputerCraftのスクリプトをGitHubから継続的デプロイしたい

## 機能

GitHubの`master`にpushするとサーバ上で、ディレクトリを持つすべてのComputerのルートディレクトリに[`scripts/`](../scripts/)のファイルをデプロイする。
Computerを作ったりlabelを付けただけではディレクトリは作られないので、何らかのファイルを少なくとも一つ作成する必要がある。

## 動機

- GitHubへの頻繁なpullはやめたい
- GitHun Webhookでイベントドリブンに
- Webhookだとサーバがいるが、この程度のツールでエンドポイント用意するのはだるい
- [Discord bot](https://discord.com/developers/applications)はDiscordのイベントを取得できるがclient型。Discord側とコネクション張ってて、サーバ用意しなくても、ここからイベントを受け取れる
- Discordを経由すればサーバーレスになる

## アーキテクチャ

```
GitHub masterへpush
↓
GitHub WebhookでDiscordに通知
↕ (常時コネクション)
Discord botでメッセージ監視
GitHubからメッセージが来たら
git fetch, checkout, rsyncでデプロイ
```

## 環境

- Kubernetes
- [Skaffold](https://skaffold.dev/)

## 開発

- [Discord Appのポータル](https://discord.com/developers/applications)でアプリケーションを作る
- DiscordからチャンネルのWebhookURLを取得
- GitHubのWebhookに、先程のURLの末尾に`/github`を追加したものを作成

- クラスタには先にDiscordのトークンを入れたシークレットを作っておく

```sh
kubectl create secret generic computer-craft-deploy \
    --from-literal=DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN
```

- ホットリロード

```sh
skaffold dev
```

## デプロイ

```sh
skaffold run
```
