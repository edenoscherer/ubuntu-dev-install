#!/bin/bash

SYSTEM
echo "=> ⏳ Configuring general system behavior"
echo "--> ⬇ Update System"
sudo apt update
sudo apt upgrade -y
sudo apt install git curl wget vim fonts-firacode build-essential -y
git config --global user.name "Edeno Scherer"
git config --global user.email edenoscherer@gmail.com
git config --global credential.helper 'store'

# SPOTIFY
# echo "=> ⏳ Installing [SPOTIFY (flatpak)]..."
# flatpak install flathub com.spotify.Client
# echo "> 🎵 [SPOTIFY (flatpak)] instaled."


echo ""
echo "--------------------"
echo ""

# ZSH
echo "=> ⏳ Installing [ZSH]..."
sudo apt install zsh -y
sudo chsh -s $(which zsh)
echo "> 👾 [ZSH] instaled."

echo ""
echo "--------------------"
echo ""


# Powerlevel10k
echo "=> ⏳ Installing [Powerlevel10k]..."
echo "--> Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "--> Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
	${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/marlonrichert/zsh-autocomplete.git \
	${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete
echo "--> Copy Oh My Zsh configs..."
cp .zshrc ~/.zshrc
echo "--> Installing p10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "--> Copy p10k configs for root..."
cp .p10k.zsh ~/.p10k.zsh
source ~/.zshrc
echo "> 🖌 [Powerlevel10k] instaled."

echo ""
echo "--------------------"
echo ""

echo "=> ⏳ Installing [nvm,goenv,phpenv]..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts

git clone https://github.com/go-nv/goenv.git ~/.goenv
goenv install 1.12.0
goenv global 1.12.0

git clone https://github.com/phpenv/phpenv.git ~/.phpenv

curl https://pyenv.run | bash
pyenv install 3.10
pyenv global 3.10

git clone https://github.com/jenv/jenv.git ~/.jenv

echo "> [nvm,goenv,phpenv] instaled."

echo ""
echo "--------------------"
echo ""


echo "=> ⏳ Installing [awscli]..."
cd $HOME/Downloads
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "> [awscli] instaled."

echo "=> ⏳ Installing [aws-sam]..."
cd $HOME/Downloads
curl "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "aws-sam-cli-linux-x86_64.zip"
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
echo "> [aws-sam] instaled."

echo ""
echo "--------------------"
echo ""


# # Docker
# echo "=> ⏳ Installing [Docker]..."
# sudo apt install ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc
# echo \
# 	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
# 	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
# sudo apt update
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# sudo systemctl enable /usr/lib/systemd/system/docker.service
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker
# echo "> 🐋 [Docker] instaled."

# echo ""
# echo "--------------------"
# echo ""


# echo "=> ⏳ Installing [vscode]..."
# sudo apt-get install wget gpg
# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
# sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
# rm -f packages.microsoft.gpg
# sudo apt install apt-transport-https
# sudo apt update
# sudo apt install code # or code-insiders

# echo ""
# echo "--------------------"
# echo ""

echo "~ The End ~"

