#!/bin/bash
#===============================================================================
#
#          FILE: odoo-installation.sh
# 
#         USAGE: ./odoo-installation.sh
# 
#   DESCRIPTION: This interactive Bash script guides the user through the
#                installation of Odoo, supporting both Community and Enterprise
#                editions for versions 15 and 16. It also installs additional
#                required packages, sets up the Nginx web server, and configures
#                Odoo for production use.
# 
#       OPTIONS: You can specify command-line options and their descriptions here.
#       REQUIREMENTS: The script is designed to work on Ubuntu 20.04 or 22.10 and requires the following prerequisites:
#                - Internet access for downloading packages and updates.
#                - Administrative privileges to install software and configure system settings.
#                - A registered domain name pointing to the server's IP address if installing on a cloud server.
#                - Odoo Enterprise username and password if installing the Enterprise edition.
#                Additional dependencies and configurations are automatically handled.

#          BUGS: Describe known issues or bugs, if any.
#         NOTES: Any additional notes or comments about the script.
#        AUTHOR: Sherif Khaled
#       CREATED: 23-10-2023
#      REVISION: 24-10-2023
#
#===============================================================================


###### Variables ###### 

# Colours Variables
ENDCOLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
LBLUE='\033[01;34m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
BLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
BOLDRED='\e[1;91m'
HIGHLIGHT='\033[41m'

#User Varibales
ODOO_VERSION=
SYS_PORT=
DOMAIN_NAME=''
SSL_EMAIL=''
MASTER_PASSWORD=
HASHED_PASSWORD=
IS_ENTERPRISE=false
ENTERPRISE_REPO_USERNAME=
ENTERPRISE_REPO_PASSWPRD=
is_cloud=true

function banner(){
    
    echo -e "$GREEN                __________________________________________________________________________
                   __                                                     ____         
                 /    )                                          /        /   )        
             ---/---------)__-----__-----__---_/_-----__-----__-/--------/__ /---------
               /         /   )  /___)  /   )  /     /___)  /   /        /    )    /   /
             _(____/____/______(___ __(___(__(_ ___(___ __(___/________/____/____(___/_
                                                                                    /  
                                                                                (_ /   
              ________________________________________________________________________
                  __                                  _     _                         
                  / |     /          /           /    /    /            /    ,        
              ---/__|----/__-----__-/-----__----/----/___ /------__----/---------_--_-
                /   |   /   )  /   /    /___)  /    /    /     /   )  /    /    / /  )
              _/____|__(___/__(___/____(___ __/____/____/_____(___(__/____/____/_/__/_
                                                                                      
                                                                                      
                         _________________________________________________
                             _    _    _     _                            
                             /  ,'     /    /            /               /
                         ---/_.'------/___ /------__----/-----__-----__-/-
                           /  \      /    /     /   )  /    /___)  /   /  
                         _/____\____/____/_____(___(__/____(___ __(___/___
                                                                           $ENDCOLOR"
   
    echo -e "                     $LYELLOW sherif.khaleed@gmail.com        $ENDCOLOR"
    echo ""
    echo -e "$YELLOW --------------------------------------------------------------- $ENDCOLOR"
    sleep 1
    echo -e "$RED-----------------------------------------------------------------------$ENDCOLOR"

    echo -e "${HIGHLIGHT}${LYELLOW}<<<Stand with Gaza, it is under attack for the purpose of genocide>>>$ENDCOLOR\n"
    


}

function check_root() {
    # Print a message to indicate that root privilege is being checked
    echo -e "$BLUE [ * ] Check root privilege"
    sleep 1

    # Check if the current user's UID is not equal to 0 (root)
    if [ "$(id -u)" != 0 ]; then
        # Print an error message in case the user is not root
        echo -e "$RED [ X ]$BLUE You are not a root user !"
        echo -e "$RED Sorry, You must be a root user to run this script...."
        exit 1  # Exit the script with an error code
    else
        # Print a success message if the user is root
        echo -e "$GREEN [ ✔ ]$BLUE Your User Is ➜$GREEN Root!"
        sleep 1
    fi
}

#######################################
# Function Name: check_ram
# Description: Check if the system has sufficient RAM (at least 2GB).
# 
# This function checks the total system memory and ensures that it is at least 2GB (2048MB). If the available memory is less
# than 2GB, it displays an error message and exits the script. If the memory is sufficient, it displays a success message.
# 
# Globals:
#   None
# 
# Outputs:
#   - Displays messages indicating the result of the RAM check.
#   - Exits the script with an error code if the RAM is insufficient.
#######################################
function check_ram() {
  # Get the total system memory in KB and convert it to MB
  MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  MEM=$((MEM / 1000))

  # Check if the available memory is less than 2GB (2048MB)
  if (( MEM < 1700 )); then
    # Print an error message if the memory is insufficient
    echo -e "$RED [ X ]$BLUE Insufficient RAM: Your server needs at least 2GB of memory."
    exit 1  # Exit the script with an error code
  else
    # Print a success message if the memory is sufficient
    echo -e "$GREEN [ ✔ ]$BLUE RAM Check: Your system has at least 2GB of memory."
  fi
}

#######################################
# Function Name: check_x64
# Description: This function checks if the system is running on a 64-bit architecture.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Writes a success message to stdout if the architecture is 64-bit.
#   - Writes an error message to stdout and exits with a non-zero status if the architecture is not 64-bit.
#######################################
function check_x64() {
  # Get the machine architecture using `uname -m`
  UNAME=$(uname -m)
  
  # Check if the architecture is "x86_64" (64-bit)
  if [ "$UNAME" != "x86_64" ]; then
    # Print an error message if the architecture is not 64-bit
    echo -e "$RED [ X ]$BLUE This command must be run on a 64-bit server."
    exit 1
  else
    # Print a success message if the architecture is 64-bit
    echo -e "$GREEN [ ✔ ]$BLUE CPU Architecture: Your server is running a 64-bit system."
  fi
}

#######################################
# Function Name: check_ubuntu
# Description: This function checks if the Ubuntu version is supported.
# 
# It uses `lsb_release -r` to retrieve the Ubuntu release version and compares it
# to a list of supported versions. If the version is supported, it prints a success message.
# If the version is not supported, it prints an error message and exits with a status code.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Writes a success message to stdout if the Ubuntu version is supported.
#   - Writes an error message to stdout and exits with a non-zero status if the version is not supported.
#######################################
function check_ubuntu() {
  # Get the Ubuntu release version
  RELEASE=$(lsb_release -r | sed 's/^[^0-9]*//g')
  
  # Check if the Ubuntu version is supported
  if [ "$RELEASE" == "22.10" ] || [ "$RELEASE" == "20.04" ]; then 
     # Print a success message if the version is supported
     echo -e "$GREEN [ ✔ ]$BLUE Your Ubuntu version Is ➜$GREEN Good!\n";
     sleep 1
  else
     # Print an error message and exit if the version is not supported
     echo -e "$RED Sorry, This script supports only Ubuntu versions [20.04 - 22.10].";
     exit 1
  fi
}

#generate script errors
err(){
  echo -e "install-odoo.sh say: $RED $1 $ENDCOLOR"
  exit 1
}

#######################################
# Function Name: get_odoo_version
# Description: This function prompts the user to choose an Odoo version between 15 and 16.
# 
# It uses a while loop to repeatedly prompt the user until a valid version is provided. A valid
# version is an integer between 15 and 16 (inclusive). If an invalid version is entered, the
# function continues to prompt the user for a valid input.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Reads the Odoo version chosen by the user from the standard input and stores it in the
#     variable ODOO_VERSION.
#######################################
function get_odoo_version() {
  re='^[0-9]+$'
  while [[ -z "$ODOO_VERSION" ]]; do
    read -r -p "Choose the Odoo version between [15 - 16]: " ODOO_VERSION
    if ! [[ $ODOO_VERSION =~ $re ]] || ((ODOO_VERSION < 15)) || ((ODOO_VERSION > 16)); then
      echo "Enter a valid number between 15 and 16"
      ODOO_VERSION=""
    fi
  done
}

#######################################
# Function Name: get_edition_name
# Description: Prompt the user to choose whether to install the enterprise edition.
# 
# This function displays a message asking the user if they want to install the enterprise edition.
# The user can choose 'y' for yes or 'n' for no.
# 
# Globals:
#   IS_ENTERPRISE (boolean) - Stores the user's choice (true for 'y' or false for 'n').
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores their choice in IS_ENTERPRISE.
#######################################
function get_edition_name() {
  echo -e "$LGREEN Do you want to install the enterprise edition? (y)es, (n)o :"
  read -r -p ' ' INPUT
  case $INPUT in
    [Yy]* ) IS_ENTERPRISE=true;;
    [Nn]* ) IS_ENTERPRISE=false;;
  esac
}


#######################################
# Function Name: get_enterprise_username
# Description: Prompt the user to enter their Odoo enterprise repository username.
# 
# This function uses a while loop to repeatedly prompt the user until a non-empty
# username is provided. It stores the username in the ENTERPRISE_REPO_USERNAME variable.
# 
# Globals:
#   ENTERPRISE_REPO_USERNAME (string) - Stores the user's Odoo enterprise repository username.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores the username in ENTERPRISE_REPO_USERNAME.
#######################################
function get_enterprise_username() {
  while true; do
    read -r -p "Enter the Odoo enterprise repository username: " ENTERPRISE_REPO_USERNAME

    if [[ -z "$ENTERPRISE_REPO_USERNAME" ]]; then
      echo "Username cannot be empty. Please try again."
    else
      break
    fi
  done
}

#######################################
# Function Name: get_enterprise_password
# Description: Prompt the user to enter their Odoo enterprise repository password.
# 
# This function uses a while loop to repeatedly prompt the user for a password without
# displaying it on the screen (using the -s option). It stores the password in the
# ENTERPRISE_REPO_PASSWORD variable.
# 
# Globals:
#   ENTERPRISE_REPO_PASSWORD (string) - Stores the user's Odoo enterprise repository password.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores the password in ENTERPRISE_REPO_PASSWORD.
#######################################
function get_enterprise_password() {
  while true; do
    read -r -s -p "Enter the Odoo enterprise repository password: " ENTERPRISE_REPO_PASSWORD

    if [[ -z "$ENTERPRISE_REPO_PASSWORD" ]]; then
      echo -e "Password cannot be empty. Please try again.\n"
    else
      break
    fi
  done
  echo
}

#######################################
# Function Name: get_port_number
# Description: Prompt the user to choose a port number between 8060 and 8090.
# 
# This function uses a while loop to repeatedly prompt the user until a valid port
# number is provided. A valid port number is an integer between 8060 and 8090 (inclusive).
# It stores the port number in the SYS_PORT variable.
# 
# Globals:
#   SYS_PORT (integer) - Stores the chosen port number.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores the port number in SYS_PORT.
#######################################
function get_port_number() {
  re='^[0-9]+$'
  while [[ -z "$SYS_PORT" ]] || ! ((8060 <= SYS_PORT && SYS_PORT <= 8090))
  do
    read -r -p "Choose the port number between [8060 - 8090]: " SYS_PORT
    if ! [[ $SYS_PORT =~ $re ]] ; then
      echo -e "Error: Not a valid number\n"
    elif ! ((8060 <= SYS_PORT && SYS_PORT <= 8090)); then
      echo -e "Error: Port number is not within the range [8060 - 8090]\n"
      SYS_PORT=""
    fi
  done
}

#######################################
# Function Name: is_cloud
# Description: Prompt the user to choose whether to install Odoo on a cloud server.
# 
# This function displays a message asking the user if they want to install Odoo on a cloud server.
# The user can choose 'y' for yes or 'n' for no. The function sets the is_cloud variable accordingly.
# 
# Globals:
#   is_cloud (boolean) - Stores the user's choice (true for 'y' or false for 'n').
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores their choice in is_cloud.
#######################################
function is_cloud() {
  echo -e "$LGREEN Do you want to install Odoo on a cloud server? (y)es, (n)o :"
  read -r -p ' ' INPUT
  case $INPUT in
    [Yy]* ) is_cloud=true;;
    [Nn]* ) is_cloud=false;;
  esac
  echo $is_cloud
}

#######################################
# Function Name: get_domain_name
# Description: Prompt the user to enter a valid domain name (including subdomains, if any).
# 
# This function uses a while loop to repeatedly prompt the user until a valid domain name
# is provided. A valid domain name follows the format 'example.com' or 'sub.example.com'. It
# uses a regular expression to validate the format. The domain name is stored in the DOMAIN_NAME variable.
# 
# Globals:
#   DOMAIN_NAME (string) - Stores the user's entered domain name.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores the domain name in DOMAIN_NAME.
#######################################
function get_domain_name() {
  local DOMAIN_REGEX="^([A-Za-z0-9.-]+\.)+[A-Za-z]{2,}$"  # Regular expression to validate domain names with subdomains

  while true; do
    read -r -p "Enter the domain name (including subdomains, if any): " DOMAIN_NAME

    if [[ -z "$DOMAIN_NAME" ]]; then
      echo "Domain name cannot be empty. Please try again."
    elif ! [[ "$DOMAIN_NAME" =~ $DOMAIN_REGEX ]]; then
      echo "Invalid domain format. The domain must be like 'example.com' or 'sub.example.com'. Please try again."
    else
      break  # Valid domain name, exit the loop
    fi
  done
}

#######################################
# Function Name: get_ssl_email
# Description: Prompt the user to enter a valid email address.
# 
# This function uses a while loop to repeatedly prompt the user until a valid email address
# is provided. It uses a regular expression to validate the format. The email address is stored
# in the SSL_EMAIL variable.
# 
# Globals:
#   SSL_EMAIL (string) - Stores the user's entered email address.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Prompts the user for input and stores the email address in SSL_EMAIL.
#######################################
function get_ssl_email() {
  local EMAIL_REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

  while true; do
    read -r -p "Please enter your email address (e.g. 'user@example.com'): " SSL_EMAIL

    if [[ -z "$SSL_EMAIL" ]]; then
      echo "Email Address cannot be empty. Please try again."
    elif ! [[ "$SSL_EMAIL" =~ $EMAIL_REGEX ]]; then
      echo "Invalid email format. The email must be like 'user@example.com'. Please try again."
    else
      break  # Valid email address, exit the loop
    fi
  done
}

#######################################
# Function Name: generate_master_password
# Description: Generate a master password for Odoo.
# 
# This function generates a random master password for Odoo. It uses the characters
# specified in the $characters variable. If the `passlib` library is not installed,
# it installs it. The hashed password is stored in the HASHED_PASSWORD variable.
# 
# Globals:
#   MASTER_PASSWORD (string) - Stores the generated master password.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Generates and stores a master password and its hash.
#######################################
function generate_master_password() {
  characters='A-Za-z0-9!@#$%^&*()_+'
  MASTER_PASSWORD=$(tr -dc "$characters" < /dev/urandom | head -c 15)
}

#######################################
# Function Name: print_user_input
# Description: Display user input before proceeding with installation.
# 
# This function displays the user's input, including the port number, domain name,
# SSL email, choice of enterprise edition, and generated master password. It then prompts
# the user to confirm if they want to continue with the installation.
# 
# Globals:
#   SYS_PORT (integer) - User's chosen port number.
#   DOMAIN_NAME (string) - User's entered domain name, if not cloud then will assign http://localhost.
#   SSL_EMAIL (string) - User's entered email address.
#   IS_ENTERPRISE (boolean) - User's choice of enterprise edition.
#   MASTER_PASSWORD (string) - Generated master password.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Displays user input and prompts the user to confirm the installation.
#######################################
function print_user_input() {
  echo -e "$YELLOW ********************************************
        * Port Number Is: $SYS_PORT                         
        * Domain Name Is: $DOMAIN_NAME                      
        * SSL E-Mail Is:  $SSL_EMAIL
        * Enterprise Edition: $IS_ENTERPRISE
        * Master Password: $MASTER_PASSWORD                                                                        
        *******************************************************
        "
  echo -e "$LGREEN Do you want to continue installation? (y)es, (n)o :"
  read -r -p ' ' INPUT
  case $INPUT in
    [Yy]* ) echo -e "Installing now";;
    [Nn]* ) exit 0;;
  esac
}

#######################################
# Function Name: upgrade_system
# Description: Update system packages, upgrade the system, install Microsoft fonts, and remove unnecessary packages.
# 
# This function updates the package lists, upgrades the system, installs Microsoft fonts, and removes
# unnecessary packages.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Performs system updates and upgrades, installs fonts, and removes unnecessary packages.
#######################################
function upgrade_system() {
  echo -e "\n---- Updating Package Lists ----"
  sudo apt update -y

  echo -e "\n---- Upgrading System ----"
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'

  echo -e "\n---- Installing Microsoft Fonts ----"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ttf-mscorefonts-installer

  echo -e "\n---- Removing Unnecessary Packages ----"
  sudo apt autoremove -y
  sudo apt clean
  sudo apt autoclean
}

#######################################
# Function Name: configure_ufw
# Description: Configure and allow ports in the UFW firewall.
# 
# This function starts the UFW firewall service and allows specific ports for SSH, Odoo, long polling, HTTP, and HTTPS.
# 
# Globals:
#   SYS_PORT (integer) - User's chosen port number for Odoo.
#   answer (string) - User's input for UFW enable (typically 'y' to confirm).
# 
# Arguments:
#   None
# 
# Outputs:
#   - Configures and allows specific ports in the UFW firewall.
#######################################
function configure_ufw() {
  sudo service ufw start
  sudo ufw allow ssh               # Allow SSH port
  sudo ufw allow "$SYS_PORT"/tcp   # Allow Odoo port
  sudo ufw allow 8072/tcp          # Allow long polling port
  sudo ufw allow 80/tcp            # Allow HTTP port
  sudo ufw allow 443/tcp           # Allow HTTPS port
  echo "y" | sudo ufw enable $answer
}

#######################################
# Function Name: install_dependencies
# Description: Install system dependencies required for the Odoo installation.
# 
# This function installs a list of system dependencies that are necessary for the Odoo installation. The dependencies include various tools and libraries needed for different aspects of the Odoo system.
# 
# Dependencies:
#   - git
#   - curl
#   - unzip
#   - python3-pip
#   - build-essential
#   - wget
#   - libfreetype6-dev
#   - libxml2-dev
#   - libzip-dev
#   - libldap2-dev
#   - libsasl2-dev
#   - node-less
#   - libjpeg-dev
#   - zlib1g-dev
#   - libpq-dev
#   - libxslt1-dev
#   - libldap2-dev
#   - libtiff5-dev
#   - libjpeg8-dev
#   - libopenjp2-7-dev
#   - liblcms2-dev
#   - libwebp-dev
#   - libharfbuzz-dev
#   - libfribidi-dev
#   - libxcb1-dev
#   - python3-dev
#   - python3-venv
#   - python3-wheel
#   - python3-setuptools
#   - python3-tk
#   - python3-gevent
#   - postgresql
#   - postgresql-server-dev-all
#   - nginx
#   - certbot
#   - libssl1.1
# 
# This function iterates through the list of dependencies and installs each one using the apt-get install command. It also installs Node.js, NPM, and rtlcss for LTR (Left-to-Right) support.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Installs system dependencies and additional tools for Odoo installation.
#######################################
function install_dependencies(){
  declare -a dependencies=(
    "git" "curl" "unzip" "python3-pip" "build-essential" "wget" "libfreetype6-dev" "libxml2-dev" "libzip-dev" "libldap2-dev" "libsasl2-dev"
    "node-less" "libjpeg-dev" "zlib1g-dev" "libpq-dev" "libxslt1-dev" "libldap2-dev" "libtiff5-dev" "libjpeg8-dev" "libopenjp2-7-dev"
    "liblcms2-dev" "libwebp-dev" "libharfbuzz-dev" "libfribidi-dev" "libxcb1-dev" "python3-dev" "python3-venv" "python3-wheel" "python3-setuptools"
    "python3-tk" "python3-gevent" "postgresql" "postgresql-server-dev-all" "nginx" "certbot" "libssl1.1"
  )

   for dependency in "${dependencies[@]}"; do
    echo -e "\n$YELLOW **** Installing dependency: $dependency **** $ENDCOLOR\n"
    apt-get install "$dependency" -y
   done

  echo -e "\n---- Installing Node.js, NPM, and rtlcss for LTR support ----"
  apt-get install nodejs npm -y
  npm install -g rtlcss
}

#######################################
# Function Name: create_user
# Description: Create system and PostgreSQL users for Odoo.
# 
# This function creates a system user for Odoo and a corresponding PostgreSQL user with superuser privileges.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version used to create user-specific names.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Creates a system user for Odoo with sudo privileges.
#   - Creates a PostgreSQL user with superuser privileges.
#######################################
function create_user() {
  # Create system user for Odoo
  sudo useradd -m -d "/opt/odoo$ODOO_VERSION" -U -r -s /bin/bash "odoo$ODOO_VERSION"
  sudo adduser "odoo$ODOO_VERSION" sudo

  # Create PostgreSQL user with superuser privileges
  sudo su - postgres -c "createuser -s 'odoo$ODOO_VERSION'"
}

#######################################
# Function Name: install_wkhtmltopdf
# Description: Install wkhtmltopdf for Odoo.
# 
# This function downloads the wkhtmltopdf package from a specific release and installs it.
# 
# Globals:
#   None
# 
# Arguments:
#   None
# 
# Outputs:
#   - Downloads and installs wkhtmltopdf.
#######################################
function install_wkhtmltopdf() {
  # Download wkhtmltopdf package
  wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb

  # Install wkhtmltopdf
  sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb -y
}

#######################################
# Function Name: installing_odoo
# Description: Install and configure Odoo with virtual environment.
# 
# This function installs Odoo, sets up a Python virtual environment for it, and installs necessary Python packages.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
#   IS_ENTERPRISE (boolean) - Indicates whether to enable Odoo Enterprise edition.
#   ENTERPRISE_REPO_USERNAME (string) - Username for the Odoo Enterprise repository.
#   ENTERPRISE_REPO_PASSWPRD (string) - Password for the Odoo Enterprise repository.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Installs and configures Odoo with a virtual environment and necessary Python packages.
#######################################
function installing_odoo() {
  su -c "cd /opt/odoo$ODOO_VERSION" odoo$ODOO_VERSION
  su -c "git clone https://www.github.com/odoo/odoo --depth 1 --branch $ODOO_VERSION.0 /opt/odoo$ODOO_VERSION/odoo"
  su -c "python3 -m venv odoo-venv" # Create a new Python virtual environment for Odoo
  su -c "source odoo-venv/bin/activate && pip3 install wheel paramiko pandas passlib" odoo$ODOO_VERSION

  su -c "pip3 install -r /opt/odoo$ODOO_VERSION/odoo/requirements.txt" odoo$ODOO_VERSION

  if [ "$IS_ENTERPRISE" = "true" ]; then
    su -c "git clone -b $ODOO_VERSION.0 https://${ENTERPRISE_REPO_USERNAME}:${ENTERPRISE_REPO_PASSWPRD}@github.com/odoo/enterprise.git /opt/odoo$ODOO_VERSION/enterprise"
  fi

  su -c "deactivate"
  su -c "mkdir /opt/odoo$ODOO_VERSION/custom-addons"
}

#######################################
# Function Name: configure_odoo
# Description: Configure and start the Odoo service.
# 
# This function configures the Odoo service, including creating configuration files and systemd service files, enabling and starting the service, and setting up logs.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Configures and starts the Odoo service.
#######################################
function configure_odoo() {
  create_odoo_file
  create_service_file
  configure_logs
  sudo systemctl daemon-reload
  sudo systemctl enable --now "odoo$ODOO_VERSION"
  service "odoo$ODOO_VERSION" start
}

#######################################
# Function Name: configure_logs
# Description: Configure log directory for Odoo.
# 
# This function creates a directory for Odoo logs and sets the appropriate ownership.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Creates a log directory for Odoo and sets its ownership.
#######################################
function configure_logs() {
  mkdir -p /var/log/odoo"$ODOO_VERSION"
  chown odoo"$ODOO_VERSION":odoo"$ODOO_VERSION" /var/log/odoo"$ODOO_VERSION"
}

#######################################
# Function Name: create_odoo_file
# Description: Create Odoo configuration file.
# 
# This function generates an Odoo configuration file based on various settings, including enabling Odoo Enterprise, cloud deployment, and dynamic paths.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
#   IS_ENTERPRISE (boolean) - Indicates whether to enable Odoo Enterprise edition.
#   HASHED_PASSWORD (string) - A hashed password for database operations.
#   is_cloud (boolean) - Indicates whether it's a cloud deployment.
#   SYS_PORT (integer) - The port number for XML-RPC communication.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Creates an Odoo configuration file with dynamic settings.
#######################################
function create_odoo_file() {
  if [ "$IS_ENTERPRISE" = true ]; then
    addons_path="/opt/odoo$ODOO_VERSION/odoo/addons,/opt/odoo$ODOO_VERSION/enterprise,/opt/odoo$ODOO_VERSION/custom-addons"
  else
    addons_path="/opt/odoo$ODOO_VERSION/odoo/addons,/opt/odoo$ODOO_VERSION/custom-addons"
  fi

  if [ "$is_cloud" = true ]; then
    proxy_value="True"
  else
    proxy_value="False"
  fi
  

  HASHED_PASSWORD=$(python3 -c "from passlib.context import CryptContext; print(CryptContext(schemes=['pbkdf2_sha512']).hash('{$MASTER_PASSWORD}'))")
  
  # Use a heredoc to create the Odoo configuration file
  cat << EOF > /etc/odoo"$ODOO_VERSION".conf
[options]
admin_passwd = $HASHED_PASSWORD
db_host = False
db_port = False
db_user = odoo$ODOO_VERSION
db_password = False
proxy_mode = $proxy_value
xmlrpc_port = $SYS_PORT
addons_path = $addons_path
logfile = /var/log/odoo$ODOO_VERSION/odoo$ODOO_VERSION.log
EOF
}

#######################################
# Function Name: create_service_file
# Description: Create a systemd service file for Odoo.
# 
# This function generates a systemd service file for Odoo, specifying its unit, dependencies, and execution details.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
# 
# Arguments:
#   None
# 
# Outputs:
#   - Creates a systemd service file for Odoo.
#######################################
function create_service_file() {
  cat > /etc/systemd/system/odoo"$ODOO_VERSION".service << HERE
[Unit]
Description=Odoo$ODOO_VERSION
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo$ODOO_VERSION
PermissionsStartOnly=true
User=odoo$ODOO_VERSION
Group=odoo$ODOO_VERSION
ExecStart=/opt/$ODOO_VERSION/odoo-venv/bin/python3 /opt/odoo$ODOO_VERSION/odoo/odoo-bin -c /etc/odoo$ODOO_VERSION.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
HERE
}

#######################################
# Function Name: create_domain_file
# Description: Create an Nginx configuration file for a domain.
# 
# This function generates an Nginx configuration file for a specific domain, including SSL settings and proxy configurations for Odoo.
# 
# Globals:
#   SYS_PORT (integer) - The port number for Odoo.
# 
# Arguments:
#   $1 (string) - The domain name.
# 
# Outputs:
#   - Creates an Nginx configuration file for the specified domain.
#######################################
function create_domain_file() {
  local DOMAIN_NAME="$1"
  
  cat > "/etc/nginx/sites-available/$DOMAIN_NAME" << HERE
#odoo server
upstream odoo {
 server 127.0.0.1:$SYS_PORT;
}
upstream odoochat {
 server 127.0.0.1:8072;
}

# http -> https
server {
   listen 80;
   server_name $DOMAIN_NAME;
   return 301 https://\$host\$request_uri;
   rewrite ^(.*) https://\$host\$1 permanent;
}

server {
 listen 443 ssl;
 server_name $DOMAIN_NAME;
 client_max_body_size 500M;
 proxy_read_timeout 720s;
 proxy_connect_timeout 720s;
 proxy_send_timeout 720s;

 # Add Headers for Odoo proxy mode
 proxy_set_header X-Forwarded-Host \$host;
 proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
 proxy_set_header X-Forwarded-Proto \$scheme;
 proxy_set_header X-Real-IP \$remote_addr;

 # SSL parameters
 ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
 ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
 ssl_session_timeout 30m;
 ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
 ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
 # (rest of the SSL settings)

 # log
 access_log /var/log/nginx/odoo.access.log;
 error_log /var/log/nginx/odoo.error.log;

 # Redirect longpoll requests to Odoo longpolling port
 location /longpolling {
 proxy_pass http://odoochat;
 }

 # Redirect requests to Odoo backend server
 location / {
   proxy_redirect off;
   proxy_pass http://odoo;
 }

 # common gzip
 gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;
 gzip on;
 gzip_types text/css application/javascript;
 gzip_min_length 1000;
 gzip_comp_level 9;
 gzip_vary on;
}
HERE
}

#######################################
# Function Name: link_domain
# Description: Link a domain, obtain SSL certificate, and set up a crontab for certificate renewal.
# 
# This function stops Nginx, obtains an SSL certificate using Certbot, sets up a crontab for automatic certificate renewal,
# creates an Nginx configuration file for the domain, and enables the site by creating a symbolic link in sites-enabled.
# 
# Globals:
#   DOMAIN_NAME (string) - The domain name.
#   SSL_EMAIL (string) - The email address for SSL certificate notifications.
# 
# Outputs:
#   - Configures Nginx, obtains SSL certificate, and sets up a crontab for certificate renewal.
#######################################
function link_domain() {
  systemctl stop nginx
  
  # Obtain SSL certificate using Certbot
  certbot certonly --standalone -d "$DOMAIN_NAME" --preferred-challenges http --agree-tos -n -m "$SSL_EMAIL" --keep-until-expiring
  
  # Define the crontab entry for automatic certificate renewal
  CRONTAB_ENTRY="@daily certbot renew --pre-hook 'systemctl stop nginx' --post-hook 'systemctl start nginx'"

  # Add the entry to the crontab
  (crontab -l 2>/dev/null; echo "$CRONTAB_ENTRY") | crontab -
  
  # Create Nginx configuration file for the domain
  create_domain_file "$DOMAIN_NAME"

  # Enable the site by creating a symbolic link in sites-enabled
  ln -s "/etc/nginx/sites-available/$DOMAIN_NAME" "/etc/nginx/sites-enabled/$DOMAIN_NAME"
  rm /etc/nginx/sites-enabled/default
  
  # Restart Nginx to apply the changes
  systemctl restart nginx
}

#######################################
# Function Name: final_result
# Description: Display the installation result and Odoo configuration details.
# 
# This function displays the installation completion message, including Odoo version, URL, master password,
# Odoo configuration file path, Odoo installation path, and custom-addons path.
# 
# Globals:
#   ODOO_VERSION (integer) - The Odoo version.
#   DOMAIN_NAME (string) - The domain name.
#   MASTER_PASSWORD (string) - The generated master password.
# 
# Outputs:
#   - Displays the installation completion message with Odoo configuration details.
#######################################
function final_result() {
  local ODOO_CONF_PATH="/etc/odoo$ODOO_VERSION.conf"
  local ODOO_INSTALL_PATH="/opt/odoo$ODOO_VERSION"
  local CUSTOM_ADDONS_PATH="/opt/odoo$ODOO_VERSION/custom-addons"

  echo -e "$GREEN ********************************************
        * Installation completed successfully
        * Odoo Version: $ODOO_VERSION                         
        * URL: $DOMAIN_NAME
        * Master Password Is: $MASTER_PASSWORD
        * Odoo Config File: $ODOO_CONF_PATH
        * Odoo Installation Path: $ODOO_INSTALL_PATH
        * Custom-Addons Path: $CUSTOM_ADDONS_PATH
        ******************************************************
        "
}

# Main function: Orchestrates the Odoo installation process
Main(){
    banner
    
    check_root
    check_ram
    check_x64
    check_ubuntu

    get_odoo_version
    get_edition_name

    if [ "$IS_ENTERPRISE" = true ]; then
    get_enterprise_username
    get_enterprise_password
    fi

    get_port_number
    is_cloud

    if [ "$is_cloud" = true ]; then
    get_domain_name
    get_ssl_email
    fi

    generate_master_password
    print_user_input

    configure_ufw
    install_dependencies
    create_user
    install_wkhtmltopdf
    installing_odoo
    configure_odoo

    if [ "$is_cloud" = true ]; then
    link_domain
    DOMAIN_NAME="https://$DOMAIN_NAME"
    else
    DOMAIN_NAME="http://localhost:$SYS_PORT"
    fi

    final_result

}
Main