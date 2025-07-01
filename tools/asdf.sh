git clone https://github.com/asdf-vm/asdf.git ~/.asdf

echo -e "\n. ~/.asdf/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
echo -e "\n. fpath(${ASDF_DIR}/completions)" >> ${ZDOTDIR:-~}/.zshrc
