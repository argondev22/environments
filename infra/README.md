# PCの環境

## クイックスタート

前提条件: gitの準備完了しており、このリポジトリをクローン

1. デフォルトのパッケージマネージャーでansibleをインストール
例: 
```sh
apt install ansible
brew install ansible
# など
```

2. 下記のコマンドを実行
```sh
ansible-galaxy collection install community.general && \n
ansible-playbook -i inventory.ini site.yml
```