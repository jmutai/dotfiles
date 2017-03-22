#!/usr/bin/env bash
# By Mutai Josphat
# jmutai.com
set -e

ask() {
  # http://djm.me/ask
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question
    read -p "$1 [$prompt] " REPLY

    # Default?
    if [ -z "$REPLY" ]; then
       REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}

dir=`pwd`
if [ ! -e "${dir}/${0}" ]; then
  echo "Script not called from within repository directory. Aborting."
  exit 2
fi
dir="${dir}/.."

# Create some dirs
mkdir ~/{.ncmpcpp,.mpd} && mkdir ~/.mpd/playlists


ask "Install pacaur?" Y && bash install-scripts/pacaur_install.sh  
ask "Install arch base packages?" Y && bash install-scripts/arch_package_list 
ask "Install icons and themes?" Y && bash install-scripts/icons_and_themes
ask "Install oh-my-zsh setup?"  Y && bash install-scripts/oh-my-zsh 
ask "Install vim packages?"  Y && bash install-scripts/vim-packages
ask "Setup i3 ssh ?"  Y && bash install-scripts/i3-ssh.sh

ask "Install symlinks for tmux?" Y && ln -sfn ${dir}/.tmux.conf ${HOME}/.tmux.conf; ln -sfn ${dir}/.tmux_prompt.sh ${HOME}/.tmux_prompt.sh
ask "Install symlink for .dircolors?" Y && ln -sfn ${dir}/.dircolors ${HOME}/.dircolors

ask "Install symlink for .gitconfig?" Y && ln -sfn ${dir}/.gitconfig ${HOME}/.gitconfig
ask "Install symlink for .zshrc?" Y && ln -sfn ${dir}/.zshrc ${HOME}/.zshrc
ask "Install symlink for .vimrc?" Y && ln -sfn ${dir}/.vimrc ${HOME}/.vimrc
ask "Install symlink for .gvimrc?" Y && ln -sfn ${dir}/.gvimrc  ${HOME}/.gvimrc
ask "Install symlink for .vim?" Y && ln -sfn ${dir}/.vim ${HOME}/.vim
ask "Install symlink for .Xresources?" Y && ln -sfn ${dir}/.Xresources ${HOME}/.Xresources
ask "Install symlink for .xinitrc?" Y && ln -sfn ${dir}/.xinitrc ${HOME}/.xinitrc
ask "Install symlink for .compton.conf?" Y && ln -sfn ${dir}/.compton.conf ${HOME}/.compton.conf
ask "Install symlink for .gtkrc-2.0?" Y && ln -sfn ${dir}/.gtkrc-2.0 ${HOME}/.gtkrc-2.0


ask "Install symlink for .mpd/mpd.conf?" Y && ln -sfn ${dir}/.mpd/mpd.conf ${HOME}/.mpd/mpd.conf 
ask "Install symlink for .ncmpcpp/config ?" Y && ln -sfn ${dir}/.ncmpcpp/config  ${HOME}/.ncmpcpp/config 

# .config subdir
ask "Install symlink for .i3blocks.conf?" Y && ln -sfn ${dir}/.i3blocks.conf ${HOME}/.i3blocks.conf
ask "Install symlink for .config/mpv/?" Y && ln -sfn ${dir}/.config/mpv ${HOME}/.config/mpv
ask "Install symlink for .config/i3/?" Y && ln -sfn ${dir}/.config/i3 ${HOME}/.config/i3
ask "Install symlink for .config/i3/?" Y && ln -sfn ${dir}/.config/i3 ${HOME}/.config/i3
ask "Install symlink for .config/polybar/?" Y && ln -sfn ${dir}/.config/polybar ${HOME}/.config/polybar
ask "Install symlink for .config/ranger/?" Y && ln -sfn ${dir}/.config/ranger ${HOME}/.config/ranger
ask "Install symlink for .config/termite/?" Y && ln -sfn ${dir}/.config/termite ${HOME}/.config/termite
ask "Install symlink for .config/dunst/?" Y && ln -sfn ${dir}/.config/dunst ${HOME}/.config/dunst
ask "Install symlink for .local/share/fonts?" Y && ln -sfn ${dir}/fonts ${HOME}/.local/share/fonts

ask "Install symlink for .mutt/?" Y && ln -sfn ${dir}/.mutt ${HOME}/.mutt
ask "Install symlink for scripts/?" Y && ln -sfn ${dir}/scripts ${HOME}/scripts
ask "Install symlink for cheatsheets/?" Y && ln -sfn ${dir}/cheat-sheets ${HOME}/cheat-sheets
