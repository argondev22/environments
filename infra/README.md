# PCの環境

1. デフォルトのパッケージマネージャーでansibleをインストール
例: 
```sh
brew install ansible
```

2. 下記のコマンドを実行
```sh
ansible-galaxy collection install community.general && \n
ansible-playbook -i inventory.ini site.yml
```