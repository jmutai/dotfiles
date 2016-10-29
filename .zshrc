# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh
  export PATH=$PATH:~/.lab/bash-scripts:~/opt/foxitsoftware/foxitreader/  
  fpath=(~/.zsh/completion $fpath)
  autoload -Uz compinit && compinit -i
  export EDITOR="vim"



ZSH_THEME="honukai"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh
source ~/mygit/docker/docker_func 

source  ~/mygit/dotfiles/.aliases 
source  ~/mygit/dotfiles/.functions 
source  ~/mygit/dotfiles/.exports 



# Compilation flags

export ARCHFLAGS="-arch x86_64"

setopt HIST_IGNORE_ALL_DUPS



