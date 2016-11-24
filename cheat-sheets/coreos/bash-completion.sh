#!/bin/bash

#  It's easy really, use toolbox to install then copy the files into the host:

toolbox dnf -y install bash-completion wget \
    && toolbox wget https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker -O /usr/share/bash-completion/completions/docker \
    && toolbox cp /usr/share/bash-completion /media/root/var/ -R  \
    && source /var/bash-completion/bash_completion

# dereference it and copy it over the link
cp $(readlink .bashrc) .bashrc.new && mv .bashrc.new .bashrc

# Then add bash completion to the resulting file:
echo "source /var/bash-completion/bash_completion" >> ~/.bashrc

