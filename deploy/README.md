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
GitHub ActionsでDiscordにPOST
↕ (WebSocket)
Discord botでメッセージ監視
GitHubからメッセージが来たらデプロイ
```

## 環境

- Kubernetes
- [Skaffold](https://skaffold.dev/)

## 開発

- [Discord Appのポータル](https://discord.com/developers/applications)でアプリケーションを作る
- DiscordからチャンネルのWebhookURLを取得
- 先程のURLの末尾に`/github`を追加したURLに、POSTする [🔗](../.github/workflows/notification.yml)

- クラスタには事前にDiscordのトークンを入れたシークレットを作っておく

```sh
kubectl create secret generic computer-craft-deploy \
    --from-literal=DISCORD_APP_TOKEN=$DISCORD_APP_TOKEN
```

- ホットリロード

```sh
skaffold dev
```

## デプロイ

```sh
skaffold run
```
