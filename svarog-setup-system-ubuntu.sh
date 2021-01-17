#/bin/bash
set -e

SVAROG_BASE_DIR="$(dirname $(readlink -f $0))"

source $SVAROG_BASE_DIR/svarog-setup-system-common.sh
source $SVAROG_BASE_DIR/svarog-base-utils.sh

svarog_general_install() {
info "Ensuring general packages ..."
sudo apt-get install -y \
  zsh zsh-doc \
  rofi \
  terminator ripgrep fd-find \
  git neovim build-essential \
  cmake cmake-doc curl \
  libmpfr-dev libmpc-dev libgmp-dev \
  libmpfr-doc \
  gmp-doc libgmp10-doc \
  e2fsprogs ninja-build \
  tmux \
  binutils binutils-doc \
  autoconf autoconf-archive autoconf-doc \
  automake libtool flex flex-doc libtool-doc \
  bison bison-doc \
  gnu-standards gettext \
  libstdc++-10-doc \
  m4-doc make-doc samba vde2 sharutils-doc \
  qemu-kvm qemu qemu-system-x86 qemu-utils \
  gcc-10 gcc-10-multilib gcc-10-doc gcc-10-locales \
  g++-10 g++-10-multilib \
  manpages-dev \
  gcc-9-multilib gcc-9-locales glibc-doc \
  g++-multilib g++-9-multilib gcc-9-doc gcc-doc gcc-multilib \
  dconf-editor 

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10
success "Ensuring general packages done"
return 0;
}

svarog_snaps_install() {
  sudo snap install chezmoi --classic
  sudo snap install ccls --classic
}

svarog_emacsbuild() {
  echo Ensuring Emacs build deps...
  sudo apt-get install -y libtiff-dev
  sudo apt-get install -y \
    libjansson-dev libjansson-doc \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libtiff5-dev \
    libgif-dev \
    libjpeg-dev \
    libpng-dev \
    libxpm-dev \
    libncurses-dev \
    libxpm-dev \
    libgnutls28-dev \
    libtiff-dev \
    libacl1-dev \
    librsvg2-dev \
    libmagickcore-dev \
    libmagick++-dev \
    libgpm-dev \
    libselinux1-dev \
    libm17n-dev \
    libotf-dev \
    libsystemd-dev

  echo Ensuring Emacs build deps done.

  echo Building Emacs ...
  mkdir -p ~/src/
  cd ~/src/
  rm -rf emacs-27.1
  [[ ! -f emacs-27.1.tar.gz ]]     && wget http://ftp.download-by.net/gnu/gnu/emacs/emacs-27.1.tar.gz
  [[ ! -f emacs-27.1.tar.gz.sig ]] && wget http://ftp.download-by.net/gnu/gnu/emacs/emacs-27.1.tar.gz.sig
  tar -zxvf emacs-27.1.tar.gz
  cd ./emacs-27.1
  ./configure --with-gnutls=ifavailable \
    --disable-silent-rules --with-modules \
    --with-file-notification=inotify \
    --with-mailutils \
    --with-x=yes \
    --with-x-toolkit=gtk3 \
    --with-xwidgets \
    --with-lcms2 \
    --with-imagemagick
  make -j`nproc`
  sudo make install

  echo "Building Emacs done."
  return 0
}

svarog_cleanup_keys() {
  echo Cleaning up hotkeys...

  for i in `seq 10`
  do
    gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-$i "[]"
    gsettings set org.gnome.shell.extensions.dash-to-dock app-ctrl-hotkey-$i "[]"
    gsettings set org.gnome.shell.extensions.dash-to-dock app-hotkey-$i "[]"
  done

  for i in `seq 9`
  do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
  done

  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
  gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
  gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-overlay false

  for i in `seq 8`
  do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
  done

  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "[]"

  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last "[]"

  gsettings set org.gnome.desktop.wm.keybindings close "['<Super><Shift>q','<Alt>F4']"

  echo done!
}

svarog_install_docker() {
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}
}

svarog_fetch_nerdfont() {
wget https://github.com/ryanoasis/nerd-fonts/releases/download/$1/$2.zip
unzip $2.zip -d ~/.local/share/fonts/
}

svarog_install_nerdfonts() {
  echo "Installing NerdFonts..."
  mkdir -p ~/.local/share/fonts/
  TMPDIR=`mktemp -d /tmp/fonts.XXXXXXXXXX`
  cd $TMPDIR
  svarog_fetch_nerdfont "v2.1.0" "Terminus"
  svarog_fetch_nerdfont "v2.1.0" "SpaceMono"
  svarog_fetch_nerdfont "v2.1.0" "Monoid"
  svarog_fetch_nerdfont "v2.1.0" "Iosevka"
  fc-cache -fv
  echo "Installing NerdFonts done!";
}

svarog_do_all() {
  svarog_general_install
  svarog_snaps_install
  svarog_emacsbuild
  svarog_cleanup_keys
  svarog_install_docker
  svarog_install_nerdfonts

  svarog_common_do_all
  return 0;
}

if [[ $# -gt 0 ]]; then
   case $1 in
     all ) svarog_do_all ;;
     packages ) svarog_general_install ;;
     snaps ) svarog_snaps_install ;;
     emacs ) svarog_emacsbuild ;;
     keys ) svarog_cleanup_keys ;;
     docker ) svarog_install_docker ;;
     nerdfonts ) svarog_install_nerdfonts ;;
     * ) svarog_parse_common_arg $1 ;;
   esac
   exit 0
fi

while true; do
    read -p "Do you wish to install packages? " yn
    case $yn in
        [Yy]* ) svarog_general_install; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to install snaps? " yn
    case $yn in
        [Yy]* ) svarog_snaps_install; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to install Emacs? " yn
    case $yn in
        [Yy]* ) svarog_emacsbuild; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to cleanup dock? " yn
    case $yn in
        [Yy]* ) svarog_cleanup_dock; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to install docker? " yn
    case $yn in
        [Yy]* ) svarog_install_docker; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to install nerdfonts? " yn
    case $yn in
        [Yy]* ) svarog_install_nerdfonts; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
