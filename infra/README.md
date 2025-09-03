# Ansible + chezmoi + asdf による統一開発環境の自動構築

## 主なコンポーネント

- **Ansible**: 構成管理
- **Homebrew/Linuxbrew**: パッケージ管理の統一
- **asdf**: 各ツールおよびバージョンを統一管理
- **chezmoi**: dotfileの管理
- **zsh**: デフォルトシェル
- **age**: 機密性の高いdotfilesを暗号化して安全に管理

## 対応プラットフォーム

| OS | アーキテクチャ | ステータス |
|---|---|---|
| macOS | Apple Silicon (M1/M2/M3) | ✅ |
| macOS | Intel x64 | ✅ |
| Ubuntu 20.04+ | x64 | ✅ |
| WSL2 (Ubuntu) | x64 | ✅ |

## 初回セットアップ

### 前提条件

- gitをインストールしていること。
- Githubとの接続設定が完了していること。

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

### 3. `.vault_pass`ファイルの配置

```bash
echo "your-vault-pass" > .vault_pass
```

※ `.vault_pass`は`./group_vars/all.yml`の Ansible Vault を復号するためのパスワード

### 4. セットアップ実行

```bash
# 事前確認（推奨）
ansible-playbook -i inventory.ini playbook.yml --check --diff --vault-password-file .vault_pass

# 本実行
## sudoパスワードなし環境
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
## sudoパスワードあり環境（実行時にパスワードを入力）
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass --ask-become-pass
```

## 5. セットアップ後の確認

```bash
# 環境の読み込み
source ~/.zprofile

# 各ツールの確認
chezmoi status          # dotfiles状態
asdf current           # インストール済みパッケージ/ツール
echo $SHELL            # デフォルトシェル
age-keygen -y ~/.config/age/age.key  # age公開鍵
```

## 運用ルール

### 管理対象

- パッケージ/ツール
- dotfiles

### 管理方針

#### パッケージ/ツール

- 原則 asdf で管理
- asdf　で管理できないパッケージ/ツールは homebrew(Linuxbrew) で管理
- 上記で対応できない場合は、bin/ にカスタムのインストールスクリプトを作成

**概略図**:

```text
(デフォルトのパッケージマネージャー)
└── ansible

brew
├── asdf
|	└── .tool-versions # 原則ここで管理
└── ... # asdf が対応していないパッケージは brew で管理

(カスタムスクリプト) # 上記で対応できない場合は、カスタムスクリプトを作成
```

#### dotfiles

- chezmoi で全て管理

### 運用フロー

#### asdf

1. `dot_tool-versions` を編集する

```sh
chezmoi edit .tool-versions # あるいは ~/.local/share/chezmoi 配下の dot_tool-versions を編集
```

2. ローカルマシンに反映させる

```sh
## sudoパスワードなし環境
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
## sudoパスワードあり環境（実行時にパスワードを入力）
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass --ask-become-pass
```

3. 変更をリモートリポジトリにプッシュ

```sh
chezmoi git add .
chezmoi git commit -m "コミットメッセージ"
chezmoi git push origin main
```

4. 別のマシンでも反映させる

```sh
chezmoi update

## sudoパスワードなし環境
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
## sudoパスワードあり環境（実行時にパスワードを入力）
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass --ask-become-pass
```

#### Homebrew (macOS) / Linuxbrew

1. ローカルマシンにパッケージをインストール

```sh
brew install <package-name>
```

2. playbook.yml を編集し、パッケージを追加する

3. 変更をリモートリポジトリにプッシュ

```sh
git add .
git commit -m "コミットメッセージ"
git push origin main
```

4. 別のマシンでも反映させる
```sh
git pull origin main

## sudoパスワードなし環境
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
## sudoパスワードあり環境（実行時にパスワードを入力）
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass --ask-become-pass
```

#### chezmoi

1. `dot_your-dotfiles` を編集する

```sh
chezmoi edit .your-dotfiles # あるいは ~/.local/share/chezmoi 配下の dot_your-dotfiles を編集
```

2. ローカルマシンに反映させる

```sh
chezmoi apply
```

3. 変更をリモートリポジトリにプッシュ

```sh
chezmoi git add .
chezmoi git commit -m "コミットメッセージ"
chezmoi git push origin main
```

4. 別のマシンでも反映させる

```sh
chezmoi update
```

## 注意事項

- ホームディレクトリ配下の dotfiles を直接修正しない。dotfiles を修正する際は必ず ~/.local/share/chezmoi/ 配下を修正し、`chezmoi apply` コマンドで反映させる。
- 機密情報を平文のままリモートリポジトリにプッシュしない。
- playbook.yml の追加実装や修正を行う際は、`make check` コマンドでテスト・デバッグを行いながら進める（いきなり `make apply` を行わない）。

## トラブルシューティング

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

## 高度な使用方法

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
