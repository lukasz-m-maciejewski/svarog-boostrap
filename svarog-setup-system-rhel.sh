#!/usr/bin/env bash

SVAROG_BASE_DIR="$(dirname $(readlink -f $0))"
source $SVAROG_BASE_DIR/svarog-base-utils.sh

svarog_install_emacs_devel_prerequisites() {
    info "Installing devel packages for compiling emacs from source"
    sudo dnf install -y texinfo libX11-devel Xaw3d-devel libjpeg-devel\
        libpng-devel giflib-devel libtiff-devel ncurses-devel systemd-devel\
        jansson-devel gnutls-devel dbus-devel gtk3-devel GConf2-devel\
        ImageMagick-devel librsvg2-devel
}

svarog_install_useful_packages() {
    sudo dnf install -y\
        cmake\
        tmux\
        tree\
        htop

}
