# PCの環境

## クイックスタート

前提条件: gitのセットアップが完了していて、このリポジトリをクローン可能なこと。

1. デフォルトのパッケージマネージャーでansibleをインストール
例: 
```sh
apt install -y ansible
brew install -y ansible
# など
```

2. 下記のコマンドを実行
```sh
ansible-galaxy collection install community.general && \n
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```