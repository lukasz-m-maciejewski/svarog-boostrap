#!/bin/bash

SVAROG_BASE_DIR="$(dirname $(readlink -f $0))"
source $SVAROG_BASE_DIR/svarog-base-utils.sh


svarog_init_chezmoi() {
    info "Initializing chezmoi"
    [[ ! -d ~/.local/share/chezmoi/ ]] && chezmoi init git@github.com:lukasz-m-maciejewski/dotfiles-chezmoi.git
    success "Initializing chezmoi succesful"
}

svarog_clone_git_repos() {
    info "Cloning git repos"
    [[ ! -d ~/org ]] && git clone git@github.com:lukasz-m-maciejewski/org.git ~/org
    [[ ! -d ~/.config/doom ]] && git clone git@github.com:lukasz-m-maciejewski/doom-emacs-config.git ~/.config/doom
    [[ ! -d ~/.config/emacs ]] && git clone https://github.com/hlissner/doom-emacs ~/.config/emacs
    success "Cloning git repos successful"
}

svarog_configure_git_basic() {
    info "Configuring git"
    git config --global user.email "lukasz.m.maciejewski@pm.me"
    git config --global user.name "Lukasz Maciejewski"
    success "Configured git"
}

svarog_common_do_all() {
    svarog_init_chezmoi
    svarog_clone_git_repos
    svarog_configure_git_basic
}

svarog_parse_common_arg() {
    case $1 in
        all ) svarog_common_do_all ;;
        chezmoi ) svarog_init_chezmoi ;;
        git_repos ) svarog_clone_git_repos ;;
        git_config ) svarog_configure_git_basic ;;
    esac
}

