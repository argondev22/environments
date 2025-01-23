#####################
# プラグイン
#####################

source ~/.zplug/init.zsh

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zdharma-continuum/fast-syntax-highlighting"
zplug "zdharma-continuum/history-search-multi-word"
zplug "themes/pmcgee", from:oh-my-zsh, hook-load:"RPROMPT=''"

zplug load

#####################
# エイリアス
#####################

alias mkdir='mkdir -p'
alias rm='rm -i'
alias grep='grep --color'
alias ll='ls -la'

alias cdSd='cd ~/Source/dev'
alias cdSl='cd ~/Source/lecture'
alias cdSw='cd ~/Source/work'
alias cdDC='cd ~/Documents'
alias cdDL='cd ~/Downloads'


#####################
# 補完
#####################

# 補完候補の上にカテゴリを表示する
zstyle ':completion:*' format "%B%F{blue}[ Completing %d ]%f%b"
zstyle ':completion:*' group-name '' # 空文字にしておくとタグ名が自動的に設定される

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ls --color=auto で表示される色を指定
# 色設定を生成するツール
# https://geoff.greer.fm/lscolors/
#
# macOSの場合 LSCOLORS コメントを外してください
export LSCOLORS='GxFxcxdxBxegedabagacad' # macOS(BSD)用
export LS_COLORS='di=1;36:ln=1;35:so=32:pi=33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43' # UbuntuなどのLinuxDistro(GNU)用

# 補完リストの色を設定
#
# 例:
# zstyle ':completion:*' list-colors di=34 ex=31 ln=35
# 上記の意味:
# di = ディレクトリ, 34=blue
# ex = 実行可能ファイル, 31=red
# ln = シンボリックリンク, 35=magenta
#
# ${(s.:.)LS_COLORS} の書き方については以下の「s:string:」の項目を参照
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# menu: 補完を選ぶときに色がつく（背景色） menu true にすると1度タブを押すだけで補完される
# select: 指定した候補以上になると選択(背景色が変わる)
zstyle ':completion:*' menu select=2

# _complete 通常の補完機能
# _approximate 入力途中ので近似値補完
# _correct 入力を終えたとみなし、綴り修正
# _prefix カーソル以降を無視して補完
# 他の機能はこちらを参照
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Control-Functions
zstyle ':completion:*' completer _complete _approximate _correct _prefix
setopt COMPLETE_IN_WORD # _prefix を使うときは必要なOption

# Shift-Tab で自動補完のカーソルを戻す
bindkey "^[[Z" reverse-menu-complete

# 補完機能の関数(compinit)を利用できるようにする
# -U 設定されているエイリアスを無視して実行
# -z zshモードで実行
autoload -Uz compinit
# 補完のための関数を実行
compinit

#####################
# ヒストリ
#####################

# 履歴保存ファイルの場所(インタラクティブシェル終了時に保存)
HISTFILE="${HOME}/.zsh_history"

# 内部履歴リスト(メモリ内)に保存されるイベントの最大数
HISTSIZE=10000

# 履歴ファイルに保存する履歴イベントの最大数
SAVEHIST=50000

# 同時に起動したzshの間でヒストリを共有
#   & 入力したコマンドを都度ヒストリファイルに書き込む
# setopt SHARE_HISTORY

# ヒストリに保存するときに余分なスペースを削除
setopt HIST_REDUCE_BLANKS

# 直前と同じコマンドはヒストリに保存しない
setopt HIST_IGNORE_DUPS

# ヒストリに保存するとき重複したコマンドがあったら古い方を削除
setopt HIST_SAVE_NO_DUPS

####################
# ASDF
#####################

. $HOME/.asdf/asdf.sh

# asdf の補完を zsh で有効にする
if command -v asdf &>/dev/null; then
  fpath=("${ASDF_DIR}/completions" $fpath)
  autoload -U bashcompinit
  bashcompinit
  source "$HOME/.asdf/completions/asdf.bash"
fi
