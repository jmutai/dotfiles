#!/bin/bash
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
 mkdir -p ~/.mpd/playlists 2>/dev/null && touch ~/.mpd/{mpd.conf,mpd.db,mpd.log,mpd.pid,mpdstate}
 mkdir -p ~/.config/mpv 2>/dev/null
 mkdir ~/.ncmpcpp 2>/dev/null


# Package installation
ask "Install brew tap packages?" Y && cat ./brew_tap_packages.txt | while read i; do brew tap  $i; done 
ask "Install brew packages?" Y && cat ./brew_packages.txt | while read i; do brew install $i; done 
ask "Install brew packages?" Y && cat ./brew_tap_packages.txt | while read i; do brew cask install $i; done 

# Symlinks
ask "Install symlink for ./mpv/mpv.conf?" Y && ln -sfn ${dir}/mpv/mpv.conf ${HOME}/.config/mpv/mpv.conf
ask "Install symlink for .mpd/mpd.conf?" Y && ln -sfn ${dir}/mpd/mpd.conf ${HOME}/.mpd/mpd.conf
ask "Install symlink for .ncmpcpp/config ?" Y && ln -sfn ${dir}/ncmpcpp/config  ${HOME}/.ncmpcpp/config

