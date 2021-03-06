#
# User configuration sourced by interactive shells
#


# Source zim
#if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
 # source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
#fi

# Path to your oh-my-zsh installation.

export TERM="xterm-256color"

  fpath=(~/.zsh/completion $fpath)
  autoload -Uz compinit && compinit -i

  export SCRIPTS_DIR="~/dotfiles/scripts"
  export S_DIR=~/dotfiles
  export F_DIR="~/opt/foxitsoftware/foxitreader" 
  export GOPATH=~/go
  export RUBY_PATH="~/.gem/ruby/2.5.0/bin"
  export PATH="$PATH:$GOPATH/bin:$F_DIR:$S_DIR:$SCRIPTS_DIR"
  export ZSH=~/.oh-my-zsh
  export EDITOR="vim"


# zsh theme of choice
#ZSH_THEME="powerlevel10k/powerlevel10k"
#ZSH_THEME="spaceship"

# https://github.com/bhilburn/powerlevel9k
# ZSH_THEME="powerlevel9k/powerlevel9k"


# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
plugins=(
git
vagrant
aws
command-not-found
zsh-autosuggestions
cp
docker
docker-compose
httpie
knife
kitchen
minikube
nmap
node
npm
python
pyenv
sudo
systemadmin
history
systemd
kubectl
terraform
)


# Scripts to source
source  $ZSH/oh-my-zsh.sh
source  $S_DIR/.docker_functions 
source  $S_DIR/.vm_functions
#source  $S_DIR/.aliases 
#source  $S_DIR/.functions 
source  $S_DIR/.exports 

autoload -U promptinit; promptinit
prompt pure

source ~/.cheat/.aliases.sh
source  ~/.cheat/functions.sh

#source ~/.dig

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Ignoe hostory dups
setopt HIST_IGNORE_ALL_DUPS

###cat ~/.ssh/id_rsa | SSH_ASKPASS="$HOME/.passfile" ssh-add - &>/dev/null

#if [[ "$TTY" == "/dev/tty1" ]]; then
#    ssh-agent startx
#fi

#export MPD_HOST=~/.mpd/socket
alias master='tmux new -s master'

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
ssh-agent startx
#exec startx
fi

# Source zsh


#. /usr/share/z/z.sh


# DPI
#export GDK_SCALE=1
#export QT_AUTO_SCREEN_SCALE_FACTOR=1

if [[ $TERM == xterm-termite ]]; then
  . /etc/profile.d/vte.sh
  __vte_osc7
fi

source ~/.cheat/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
#eval "$(chef shell-init zsh)"

source <(awless completion zsh)

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
