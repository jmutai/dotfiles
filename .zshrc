

#
# User configuration sourced by interactive shells
#


# Source zim
#if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
 # source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
#fi

# Path to your oh-my-zsh installation.


  fpath=(~/.zsh/completion $fpath)
  autoload -Uz compinit && compinit -i

  export SCRIPTS_DIR="~/mygit/dotfiles/scripts"
  export S_DIR=~/mygit/dotfiles
  export F_DIR="~/opt/foxitsoftware/foxitreader" 
  export GOPATH=~/go
  export PATH="$PATH:$GOPATH/bin:$F_DIR:$S_DIR:$SCRIPTS_DIR"
  export ZSH=~/.oh-my-zsh
  export EDITOR="vim"

# zsh theme of choice
ZSH_THEME="honukai"

# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)

# Scripts to source
source  $ZSH/oh-my-zsh.sh
source  $S_DIR/.docker_functions 
source  $S_DIR/.vm_functions
source  $S_DIR/.aliases 
source  $S_DIR/.functions 
source  $S_DIR/.exports 

source  ~/.cheat/functions.sh
#source ~/.dig

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Ignoe hostory dups
setopt HIST_IGNORE_ALL_DUPS

cat ~/.ssh/id_rsa | SSH_ASKPASS="$HOME/.passfile" ssh-add - &>/dev/null

#if [[ "$TTY" == "/dev/tty1" ]]; then
#    ssh-agent startx
#fi

#export MPD_HOST=~/.mpd/socket
alias master='tmux new -s master'

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
ssh-agent startx
#exec startx
fi
