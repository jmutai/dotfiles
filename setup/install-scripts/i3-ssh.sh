#!/usr/bin/bash
echo "Installing packages required"
sudo pacman -S x11-ssh-askpass  libx11 libxt keychain --noconfirm

echo ""
echo " Create symbolic link to /usr/lib/ssh/x11-ssh-askpass"
sudo ln -sv /usr/lib/ssh/x11-ssh-askpass /usr/local/bin/SSH_ASKPASS

echo ""
echo "Configuring passphrase file"
echo ""
echo -en "Provide passphrase: "
read pass_phrase

cat >>$HOME/.passfile<<EOF
#!/bin/bash
echo echo "$pass_phrase"
EOF

echo "Make the file executable"
chmod +x $HOME/.passfile

#echo 'cat ~/.ssh/id_rsa | SSH_ASKPASS="$HOME/.passfile" ssh-add - &>/dev/null' >> ~/.zshrc

source  ~/.zshrc

