#! /usr/bin/env zsh

cp ~/.zshrc ~/.zshrc.bak

SCRIPT_DIR=$(dirname "$0")
cp ${SCRIPT_DIR}/.zshrc ~/.zshrc