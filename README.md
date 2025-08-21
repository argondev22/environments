## environments: Ansible + chezmoi + asdf で統一開発環境を自動構築

このリポジトリは、macOS/Ubuntu/WSL を対象に、Ansible で開発環境を自動構築し、chezmoi で dotfiles を配布、asdf で言語ツールチェーンを統一管理するためのプロジェクトです。age による秘密情報の暗号化にも対応しています。

### 対応プラットフォーム

| OS | アーキテクチャ | ステータス |
|---|---|---|
| macOS | Apple Silicon (M1/M2/M3) | ✅ |
| macOS | Intel x64 | ✅ |
| Ubuntu 20.04+ | x64 | ✅ |
| WSL2 (Ubuntu) | x64 | ✅ |

## リポジトリ構成

```text
environments/
├── config/
│   ├── editor/
│   │   ├── cursor/
│   │   └── vscode/
│   │       ├── extensions.json
│   │       └── settings.json
│   └── github/
│       └── restrict-force-push-and-merge.json
├── dotfiles/                 # dotfiles（サブモジュール）
├── infra/
│   ├── group_vars/
│   │   └── all.yml          # Ansible Vault で暗号化
│   ├── inventory.ini
│   ├── Makefile
│   ├── playbook.yml
│   └── templates/
│       └── chezmoi.toml.j2
├── README.md                 # 本ファイル
└── ...
```

## クイックスタート

### 前提条件

- **Git** が利用可能
- **sudo 権限** を持つユーザー
- **インターネット接続**（パッケージ取得）
- （推奨）**SSH 鍵**で GitHub にアクセス

### 1. 取得（サブモジュール込み）

```bash
git clone --recurse-submodules git@github.com:argon/environments.git
cd environments/infra
```

### 2. Ansible をインストール

```bash
# macOS
brew install ansible

# Ubuntu/WSL
sudo apt update && sudo apt install -y ansible
```

### 3. Vault パスワードを配置（手元で安全に保管）

```bash
cd environments/infra
echo "<YourVaultPassword>" > .vault_pass
chmod 600 .vault_pass
```

### 4. セットアップを実行

```bash
# 構文チェック
make syntax

# 事前確認（推奨）
make check

# 本実行
make apply
```

### 5. セットアップ後の確認

```bash
source ~/.zprofile
chezmoi status
asdf current
echo $SHELL
age-keygen -y ~/.config/age/age.key
```

## 秘密情報とセキュリティ

- **Ansible Vault**: `infra/group_vars/all.yml` は暗号化済み。復号には `infra/.vault_pass` を使用。
- **age 鍵**: `~/.config/age/age.key` に秘密鍵を配置（プレイブックが利用）。Git にコミットしないこと。
- **権限設定**: 秘密鍵やパスワードファイルは `chmod 600` を徹底。

## 日常運用（よく使う操作）

- **dotfiles の適用/更新**
  - chezmoi の設定はプレイブックで生成されます。
  - 変更のプレビュー: `chezmoi diff`
  - 適用: `chezmoi apply`

- **asdf ツールの追加**
  - `~/.tool-versions` に追記し、`asdf plugin add <name>` → `asdf install`。

- **Troubleshooting**（例）
  - asdf のプラグイン/依存関係不足: macOS は `brew install unzip gnupg`、Ubuntu は `sudo apt install -y unzip curl gnupg` など。
  - chezmoi の診断: `chezmoi doctor`、age 鍵の存在と権限を確認。

## dotfiles サブモジュールについて

- サブモジュール URL は `.gitmodules` に定義されています。
- dotfiles の内容変更は、原則サブモジュール側リポジトリで行い、このリポジトリでは参照を更新してください。
  - 例: `git submodule update --remote --merge`（必要に応じて）

## 参考ドキュメント

- 詳細なセットアップ手順や Make ターゲットは `infra/README.md` を参照してください。

## 注意事項

- 本 README の構成は実ディレクトリ構成に合わせています（`infra` 以下の CI/CD 設定などは各環境に依存）。
