# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh
  export PATH=$PATH:~/.lab

ZSH_THEME="honukai"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh
source ~/.lab/aliases
source ~/.lab/func
source ~/.lab/exports


# Compilation flags

export ARCHFLAGS="-arch x86_64"

setopt HIST_IGNORE_ALL_DUPS

alias ypa="youtube-dl -f 22 --write-auto-sub --ignore-errors --no-overwrites --embed-subs --download-archive=downloaded.txt -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"
alias res='ypa -c --download-archive=downloaded.txt https://www.youtube.com/playlist?list=PL2BN1Zd8U_MufmbEcn5cIpsd1LHFKA8S3'

# Single video
alias yv="youtube-dl  --write-auto-sub --ignore-errors --no-overwrites --embed-subs -f 22 -o  '%(title)s.%(ext)s'"


