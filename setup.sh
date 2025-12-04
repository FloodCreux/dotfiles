#!/usr/bin/env bash
stow .

ln -sf ~/.config/bash/.bashrc ~/.bashrc

ln -sf ~/.config/git/.gitconfig ~/.gitconfig
ln -sf ~/.config/git/.gitconfig-palantir ~/.gitconfig-palantir
ln -sf ~/.config/git/.gitconfig-personal ~/.gitconfig-personal
ln -sf ~/.config/git/.gitconfig-phare ~/.gitconfig-phare
ln -sf ~/.config/git/.gitconfig-work ~/.gitconfig-work

ln -sf ~/.config/ssh/config ~/.ssh/config

ln -sf ~/.config/vim/.vimrc ~/.vimrc
ln -sf ~/.config/vim/colors ~/.vim/colors

chmod +x ~/.config/tmux/scripts/tmux-sessionizer
chmod -R +x ~/.config/sketchybar/plugins
# Add Logic to build and run nix-darwin
# cd ~/.config/nix-darwi


