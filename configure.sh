#!/bin/bash

# Update pkg lists
echo "Updating package lists..."
sudo apt-get update

# zsh install
which zsh > /dev/null 2>&1
if [[ $? -eq 0 ]] ; then
echo ''
echo "zsh already installed..."
else
echo "zsh not found, now installing zsh..."
echo ''
sudo apt install zsh -y
fi

# Installing git completion
echo ''
echo "Now installing git and bash-completion..."
sudo apt-get install git bash-completion -y

echo ''
echo "Now configuring git-completion..."
GIT_VERSION=`git --version | awk '{print $3}'`
URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
echo ''
echo "Downloading git-completion for git version: $GIT_VERSION..."
if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
	echo "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
fi

# oh-my-zsh install
if [ -d ~/.oh-my-zsh/ ] ; then
echo ''
echo "oh-my-zsh is already installed..."
read -p "Would you like to update oh-my-zsh now?" -n 1 -r
echo ''
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
    cd ~/.oh-my-zsh && git pull
        if [[ $? -eq 0 ]]
        then
            echo "Update complete..." && cd
        else
            echo "Update not complete..." >&2 cd
        fi
    fi
else
echo "oh-my-zsh not found, now installing oh-my-zsh..."
echo ''
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# oh-my-zsh plugin install
echo ''
echo "Now installing oh-my-zsh plugins..."
echo ''

# zsh z
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-z

# zsh completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

# auto suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# syntax highlight
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# powerlevel9k install
echo ''
echo "Now installing powerlevel9k..."
echo ''
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# powerlevel 10k install
echo ''
echo "Now installing powerlevel10k..."
echo ''
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# vimrc vundle install
echo ''
echo "Now installing vundle..."
echo ''
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Pathogen install
echo ''
echo "Now installing Pathogen..."
echo ''
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Nerdtree for vim install
echo ''
echo "Now installing Nerdtree for Vim..."
echo ''
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

# Vim color scheme install
echo ''
echo "Now installing vim wombat color scheme..."
echo ''
git clone https://github.com/sheerun/vim-wombat-scheme.git ~/.vim/colors/wombat 
mv ~/.vim/colors/wombat/colors/* ~/.vim/colors/

# Midnight commander install
echo ''
echo "Now installing Midnight commander..."
echo ''
sudo apt-get install mc -y

# Speedtest-cli, pip and jq install
echo ''
echo "Now installing Speedtest-cli, pip, tmux and jq..."
echo ''
sudo apt-get install jq tmux python-pip -y
sudo pip install --upgrade pip
sudo pip install speedtest-cli

# Bash color scheme
echo ''
echo "Now installing solarized dark WSL color scheme..."
echo ''
wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark
mv dircolors.256dark .dircolors

# Pull down personal dotfiles
echo ''
read -p "Do you want to use rdbishop19's dotfiles? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ''
	echo "Now pulling down rdbishop19 dotfiles..."
	git clone https://github.com/rdbishop19/dotfiles.git ~/.dotfiles
	echo ''
	cd $HOME/.dotfiles && echo "switched to .dotfiles dir..."
	echo ''
	echo "Checking out wsl branch..." && git checkout wsl
	echo ''
	echo "Now configuring symlinks..." && $HOME/.dotfiles/script/bootstrap
    if [[ $? -eq 0 ]]
    then
        echo "Successfully configured your environment with rdbishop19's dotfiles..."
    else
        echo "rdbishop19's dotfiles were not applied successfully..." >&2
fi
else 
	echo ''
    echo "You chose not to apply rdbishop19's dotfiles. You will need to configure your environment manually..."
	echo ''
	echo "Setting defaults for .zshrc and .bashrc..."
	echo ''
	echo "source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc && echo "added zsh-syntax-highlighting to .zshrc..."
	echo ''
	echo "source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc && echo "added zsh-autosuggestions to .zshrc..."
	echo ''
	echo "source $HOME/.git-completion.bash" >> ${ZDOTDIR:-$HOME}/.bashrc && echo "added git-completion to .bashrc..."
	
fi

# Setup and configure az cli
echo ''
read -p "Do you want to install Azure CLI? y/n (This will take some time...)" -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Now installing az cli..."
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
     sudo tee /etc/apt/sources.list.d/azure-cli.list

    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
    sudo curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https
    sudo apt-get update && sudo apt-get install azure-cli
	
    if [[ $? -eq 0 ]]
    then
        echo "Successfully installed Azure CLI 2.0."
    else
        echo "Azure CLI not installed successfully." >&2
    fi
    else 
    echo "You chose not to install Azure CLI. Exiting now."
    fi

# Set default shell to zsh
echo ''
read -p "Do you want to change your default shell? y/n" -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Now setting default shell..."
    chsh -s $(which zsh)
    if [[ $? -eq 0 ]]
    then
        echo "Successfully set your default shell to zsh..."
    else
        echo "Default shell not set successfully..." >&2
fi
else 
    echo "You chose not to set your default shell to zsh. Exiting now..."
fi

echo ''
echo '	Badass WSL terminal installed! Please reboot your computer for changes to be made.'