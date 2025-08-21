# Ansible + chezmoi + asdf による統一開発環境の自動構築

[![Ansible Test](https://github.com/argon/environments/workflows/Ansible%20Playbook%20Basic%20Test/badge.svg)](https://github.com/argon/environments/actions)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Ubuntu%20%7C%20WSL-blue)](#対応プラットフォーム)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## ✨ 主な機能

- 🔐 **age暗号化**: SSH鍵・API鍵を安全に管理
- 📦 **asdf統合**: 言語バージョンを`.tool-versions`で統一管理
- 🏠 **Homebrew/Linuxbrew**: パッケージ管理の統一
- 🐚 **zsh自動設定**: デフォルトシェル化まで完全自動
- 🔄 **マルチプラットフォーム**: macOS/Ubuntu/WSL対応
- ⚙️ **完全自動化**: 手動作業ゼロのセットアップ

## 🎯 対応プラットフォーム

| OS | アーキテクチャ | ステータス |
|---|---|---|
| macOS | Apple Silicon (M1/M2/M3) | ✅ |
| macOS | Intel x64 | ✅ |
| Ubuntu 20.04+ | x64 | ✅ |
| WSL2 (Ubuntu) | x64 | ✅ |

## 🚀 クイックスタート

### 前提条件

- **Git**: このリポジトリにアクセス可能
- **sudo権限**: システム設定変更用
- **SSH鍵**: GitHubアクセス用（推奨）

### 1. Ansibleのインストール

```bash
# macOS
brew install ansible

# Ubuntu/Debian/WSL
sudo apt update && sudo apt install -y ansible

# Arch Linux
sudo pacman -S ansible
```

### 2. 環境の準備

```bash
# リポジトリクローン
git clone --recurse-submodules git@github.com:argon/environments.git
cd environments/infra
```

### 3. セットアップ実行

```bash
# 事前確認（推奨）
ansible-playbook -i inventory.ini playbook.yml --check --diff --vault-password-file .vault_pass

# 本実行
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
```

## ✅ セットアップ後の確認

```bash
# 環境の読み込み
source ~/.zprofile

# 各ツールの確認
chezmoi status          # dotfiles状態
asdf current           # インストール済み言語
echo $SHELL            # デフォルトシェル
age-keygen -y ~/.config/age/age.key  # age公開鍵
```

## 🛠️ 管理されるツール

### パッケージマネージャー
- **Homebrew** (macOS) / **Linuxbrew** (Linux)

### セキュリティ・設定管理
- **chezmoi**: dotfiles管理・暗号化対応
- **age**: 軽量暗号化ツール

### 開発環境
- **asdf**: ツールバージョン管理
- **zsh**: 高機能シェル

## 🔒 セキュリティ重要事項

### ⚠️ 絶対に守ること

- **age秘密鍵** (`~/.config/age/age.key`): 絶対にGitにコミットしない
- **Vaultパスワード** (`.vault_pass`): 安全に管理・バックアップ
- **権限設定**: `chmod 600` で適切な権限を維持

### 🔐 推奨バックアップ方法

- パスワードマネージャーでの管理
- 暗号化USBでの物理保存
- 複数の安全な場所での分散保存

## 🔧 よくあるトラブルと解決法

### asdf関連
```bash
# バージョンが見つからない場合
asdf list-all nodejs | tail -10
vim ~/.tool-versions  # 利用可能なバージョンに修正

# プラグインインストール失敗
sudo apt install -y unzip curl gnupg  # Ubuntu
brew install unzip gnupg              # macOS
```

### chezmoi関連
```bash
# 初期化失敗
chezmoi doctor  # 設定確認
ls -la ~/.config/age/age.key  # 鍵の存在・権限確認
```

### シェル関連
```bash
# zshに切り替わらない
echo $SHELL
# 新しいターミナルを開く、またはログインし直す
```

## 🎛️ 高度な使用方法

### カスタムツール追加
```bash
# .tool-versionsを編集
echo "terraform 1.10.3" >> ~/.tool-versions
asdf plugin add terraform
asdf install terraform 1.10.3
```

### 暗号化ファイル管理
```bash
# 新しい秘密ファイルを追加
chezmoi add --encrypt ~/.aws/credentials

# 暗号化ファイルを編集
chezmoi edit ~/.env

# 変更を適用
chezmoi apply
```

### 新マシンでの展開
```bash
git clone git@github.com:argon/environments.git
cd environments/infra
# age鍵を安全に転送・配置
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
```

## 🔄 継続的インテグレーション

GitHub Actionsで以下を自動実行：
- **構文チェック**: Ansibleプレイブック検証
- **マルチプラットフォームテスト**: Ubuntu/macOS動作確認
- **セキュリティスキャン**: 潜在的問題の検出

## 📋 便利なMakefile

```makefile
# Makefile
INVENTORY=inventory.ini
VAULT_FILE=.vault_pass

.PHONY: check apply syntax clean

syntax:
	ansible-playbook --syntax-check -i $(INVENTORY) playbook.yml

check:
	ansible-playbook -i $(INVENTORY) playbook.yml --check --diff --vault-password-file $(VAULT_FILE)

apply:
	ansible-playbook -i $(INVENTORY) playbook.yml --vault-password-file $(VAULT_FILE)

debug:
	ansible-playbook -i $(INVENTORY) playbook.yml --check --diff -vvv --vault-password-file $(VAULT_FILE)

clean:
	rm -f .vault_pass
```

**使用例:**
```bash
make syntax    # 構文チェック
make check     # 事前確認
make apply     # 本実行
make debug     # 詳細ログ
```

## 📊 プロジェクト構成

```
environments/
├── infra/
│   ├── playbook.yml              # メインプレイブック
│   ├── inventory.ini             # インベントリ
│   ├── group_vars/all.yml        # 暗号化設定（Vault）
│   └── templates/chezmoi.toml.j2 # chezmoi設定テンプレート
└── .github/workflows/            # CI/CD設定
```
