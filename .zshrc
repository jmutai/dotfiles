# Path to your oh-my-zsh installation.

  fpath=(~/.zsh/completion $fpath)
  autoload -Uz compinit && compinit -i

  # Some exports
  export ZSH=~/.oh-my-zsh
  export PATH=$PATH:~/.lab/bash-scripts:~/opt/foxitsoftware/foxitreader/  
  export EDITOR="vim"
  export S_DIR=~/mygit/dotfiles

# zsh theme of choice
ZSH_THEME="honukai"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# Scripts to source
source  $ZSH/oh-my-zsh.sh
source  $S_DIR/../docker/docker_func 
source  $S_DIR/.vm_functions
source  $S_DIR/.aliases 
source  $S_DIR/.functions 
source  $S_DIR/.exports 
source ~/.dig

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Ignoe hostory dups
setopt HIST_IGNORE_ALL_DUPS



