#!/bin/bash
# A menu driven shell script sample template from mt 6
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'



# function to display menus
show_menus() {
  clear
  echo "----------------------------------------------------------------------------------"
  echo -e "                      ${RED}M A I N - M E N U${STD}"
  echo "----------------------------------------------------------------------------------"
  echo "1. Run apt-get update"
  echo "2. Install zsh"
  echo "3. Install zsh theme and zsh-autosuggestions"
  echo "4. Install Nginx"
  echo "quit.  Exit
  "
}


aptgetupdate() {
	echo -n -e "Running apt-get-update"
  apt-get update
}

zsh(){
  echo -n -e "Install zsh and "
  apt install zsh

  echo -n -e "Install oh-my-zsh"
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

zsh_theme() {
	
  echo -n -e "Install zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  echo -n -e "Install zsh-powerlevel9k"
  git clone https://github.com/bhilburn/powerlevel9k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel9k
  # Change theme to powerlevel9k
  sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel9k\/powerlevel9k\"/g' ~/.zshrc
  # Add zsh-autosuggestions
  sed -i 's/  git /  git zsh-autosuggestions/g' ~/.zshrc
  echo "
	POWERLEVEL9K_PROMPT_ON_NEWLINE=true
	POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time php_version ip)
	POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs )
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
	DISABLE_AUTO_TITLE="true"
  " >> ~/.zshrc
}

install_nginx(){
  echo -n -e "Install nginx"
  add-apt-repository -y ppa:nginx/development && apt-get update
  apt-get -y install nginx
}

# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
  local choice
  echo " "
  read -p "Enter choice:" choice
  case $choice in
    1) aptgetupdate ;;
    2) zsh ;;
    3) zsh_theme ;;
    4) install_nginx ;;
    quit)clear && exit 0;;
    *) echo -e "${RED}Can not match with any selected${STD}" && sleep 1
  esac
}

# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP

# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
  show_menus
  read_options
