#!/bin/bash

###### Variables ###### 

# Colours Variables
BOLD='\033[1m'
ENDBOLD='\033[0m'
ENDCOLOR='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
HIGHLIGHT='\033[41m'

#User Varibales
ODOO_VERSION=
SYS_PORT=
DOMAIN_NAME=''
SSL_EMAIL=''
MASTER_PASSWORD=
HASHED_PASSWORD=
ENABLE_ENTERPRISE=false
ENTERPRISE_REPO_USERNAME=
ENTERPRISE_REPO_PASSWPRD=
IsCloud=true

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
    echo -e "${HIGHLIGHT}${LYELLOW}<<<Stand with Gaza, it is under attack for the purpose of genocide>>>$ENDCOLOR"

}
# Check root privilege,the script required root privilege to make all configurations
check_root()
{
    echo -e "$BLUE [ * ] Check root privilege"
    sleep 1

   if [ `id -u` != 0 ];then
      echo -e "$RED [ X ]$BLUE You are not a root user !\n";
      echo -e "$RED Sorry, You must be root user to run this script....";
      exit 0
    else
      echo -e "$GREEN [ ✔ ]$BLUE Your User Is ➜$GREEN Root!\n";
      sleep 1
   fi  
}
#Check RAM Capacity
check_ram() {
  MEM=`grep MemTotal /proc/meminfo | awk '{print $2}'`
  MEM=$((MEM/1000))
  if (( $MEM < 2048 )); then 
     echo -e "$RED Sorry, Your server needs to have (at least) 2G of memory.....";
     exit 0
    else
     echo -e "$GREEN [ ✔ ]$BLUE Your Ram Size Is ➜$GREEN Good!\n";
     sleep 1
  fi
}
#Check CPU Arctecture
check_x64() {
  UNAME=`uname -m`
  if [ "$UNAME" != "x86_64" ]; then 
     echo -e "$RED Sorry, You must run this command on a 64-bit server.....";
     exit 0
    else
     echo -e "$GREEN [ ✔ ]$BLUE Your CPU arctecture Is ➜$GREEN Good!\n";
     sleep 1
  fi
}
#Check OS
check_ubuntu(){
  RELEASE=$(lsb_release -r | sed 's/^[^0-9]*//g')
  if [ "$RELEASE" == "22.10" ] || [ "$RELEASE" == "20.04" ]; then 
     echo -e "$GREEN [ ✔ ]$BLUE Your ubuntu version Is ➜$GREEN Good!\n";
     sleep 1
    else
     echo -e "$RED Sorry, This script support only ubuntu version [20.04 - 22.10]";
     exit 0
  fi
}
#generate script errors
err(){
  echo -e "install-odoo.sh say: $RED $1 $ENDCOLOR"
  exit 1
}
function getOdooVersion(){
  re='^[0-9]+$'
  while [[ -z "$ODOO_VERSION" ]]
  do
    read -p "Choose the odoo version between [15 - 16]: " ODOO_VERSION
    if ! [[ $ODOO_VERSION =~ $re ]] || (( $ODOO_VERSION < 15 )) || (( $ODOO_VERSION > 16 )); then
      echo "Enter a valid number between 15 and 16"
      ODOO_VERSION=""
    fi
  done
}
function getEditionName(){

  echo -e "$LGREEN Do you want to install enterprise edition? (y)es, (n)o :"
  read  -p ' ' INPUT
  case $INPUT in
    [Yy]* ) ENABLE_ENTERPRISE=true;;
    [Nn]* ) ENABLE_ENTERPRISE=false;;
  esac
}
function get_enterprise_username() {

  while true; do
    read -p "Enter the odoo enterprise repository username: " ENTERPRISE_REPO_USERNAME

    if [[ -z "$ENTERPRISE_REPO_USERNAME" ]]; then
      echo "Username access cannot be empty. Please try again."
    fi
  done
}
function get_enterprise_password() {

  while true; do
    read -p "Enter the odoo enterprise repository password: " ENTERPRISE_REPO_PASSWPRD

    if [[ -z "$ENTERPRISE_REPO_PASSWPRD" ]]; then
      echo "Password access cannot be empty. Please try again."
    fi
  done
}
function getPortNumber(){
  re='^[0-9]+$'
  while [[ -z "$SYS_PORT" ]] || ! ((8060 <= SYS_PORT && SYS_PORT <= 8090))
  do
    read -p "Choose the port number between [8060 - 8090]: " SYS_PORT
    if ! [[ $SYS_PORT =~ $re ]] ; then
      echo -e "Error: Not a valid number\n"
    elif ! ((8060 <= SYS_PORT && SYS_PORT <= 8090)); then
      echo -e "Error: Port number is not within range [8060 - 8090]\n"
      SYS_PORT=""
    fi
  done
}
function IsCloud(){

  echo -e "$LGREEN Do you want to install the odoo on cloud server? (y)es, (n)o :"
  read  -p ' ' INPUT
  case $INPUT in
    [Yy]* ) IsCloud=true;;
    [Nn]* ) IsCloud=false;;
  esac
}
function getDomainName() {

  local DOMAIN_REGEX="^([A-Za-z0-9.-]+\.)+[A-Za-z]{2,}$"  # Regular expression to validate domain names with subdomains

  while true; do
    read -p "Enter the domain name (including subdomains, if any): " DOMAIN_NAME

    if [[ -z "$DOMAIN_NAME" ]]; then
      echo "Domain name cannot be empty. Please try again."
    elif ! [[ "$DOMAIN_NAME" =~ $DOMAIN_REGEX ]]; then
      echo "Invalid domain format. The domain must be like 'example.com' or 'sub.example.com'. Please try again."
    else
      break  # Valid domain name, exit the loop
    fi
  done
}
function getSSLEmail() {

  local EMAIL_REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

  while true; do
    read -p "Please enter your email address (e.g. 'user@example.com'): " SSL_EMAIL

    if [[ -z "$SSL_EMAIL" ]]; then
      echo "Email Address cannot be empty. Please try again."
    elif ! [[ "$SSL_EMAIL" =~ $EMAIL_REGEX ]]; then
      echo "Invalid email format. The email must be like 'user@example.com'. Please try again."
    else
      break  # Valid email address, exit the loop
    fi
  done
}
function generateMasterPassword() {

   characters='A-Za-z0-9!@#$%^&*()_+'
   MASTER_PASSWORD=$(tr -dc "$characters" < /dev/urandom | head -c 15)

   # Check if passlib is installed
    if ! pip3 show passlib &> /dev/null; then
        echo "passlib is not installed. Installing passlib..."
        pip3 install passlib
    fi

   HASHED_PASSWORD=$(python3 -c "from passlib.context import CryptContext; print(CryptContext(schemes=['pbkdf2_sha512']).hash('{$MASTER_PASSWORD}'))")
}
function printUserInput(){
  echo -e "$YELLOW ********************************************
        * Port Number Is: $SYS_PORT                         
        * Domain Name Is: $DOMAIN_NAME                      
        * SSL E-Mail Is:  $SSL_EMAIL
        * Enterprise Edition: $ENABLE_ENTERPRISE
        * Master Password: $MASTER_PASSWORD                                                                        
        *******************************************************
        "
  echo -e "$LGREEN Do you want to contenue installation? (y)es, (n)o :"
  read  -p ' ' INPUT
  case $INPUT in
    [Yy]* ) echo -e "installing now";;
    [Nn]* ) exit 0;;
  esac
}
function upgrade_system(){
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
# configure and allow ports in UFW firewall
function configure_ufw(){
  sudo service ufw start
  sudo ufw allow ssh       # allow ssh port
  sudo ufw allow "$SYS_PORT"/tcp # allow odoo port
  sudo ufw allow 8072/tcp  # allow longpolling port
  sudo ufw allow 80/tcp    # allow http port
  sudo ufw allow 443/tcp # allow https port

  echo "y" | sudo ufw enable "$answer"
}
#Install all dependencies
function install_dependencies(){

  declare -a dependencies=("git" "curl" "unzip" "python3-pip" "build-essential" "wget" "libfreetype6-dev" "libxml2-dev" "libzip-dev" "libldap2-dev" "libsasl2-dev"
                           "node-less" "libjpeg-dev" "zlib1g-dev" "libpq-dev" "libxslt1-dev" "libldap2-dev" "libtiff5-dev" "libjpeg8-dev" "libopenjp2-7-dev"
                           "liblcms2-dev" "libwebp-dev" "libharfbuzz-dev" "libfribidi-dev" "libxcb1-dev" "python3-dev" "python3-venv" "python3-wheel" "python3-setuptools"
                           "python3-tk" "python3-gevent" "postgresql" "postgresql-server-dev-all" "nginx" "certbot" "libssl1.1")


 for (( i = 0; i < ${#dependencies[@]} ; i++ )); do
     printf "%s\n $YELLOW **** Basic dependencies installing now: ${dependencies[$i]} ***** $ENDCOLOR \n\n"

     # Run each command in array
     eval "apt-get install ${dependencies[$i]} -y"
 done

  echo -e "\n---- Installing nodeJS NPM and rtlcss for LTR support ----"
  sudo apt-get install nodejs npm -y
  sudo npm install -g rtlcss
}
# Create postgresql user and odoo user
function create_user(){
  #create odoo user
  sudo useradd -m -d /opt/odoo"$ODOO_VERSION" -U -r -s /bin/bash odoo"$ODOO_VERSION"
  sudo adduser odoo"$ODOO_VERSION" sudo
  #create postgresql user
  sudo su - postgres -c "createuser -s odoo$ODOO_VERSION"
}
function install_wkhtmltopdf(){
  wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
  sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb -y
}
function installing_odoo(){
  su -c "git clone https://www.github.com/odoo/odoo --depth 1 --branch $ODOO_VERSION.0 /opt/odoo$ODOO_VERSION/odoo"
  su -c "python3 -m venv odoo-venv" #Create a new Python virtual environment for Odoo:
  su -c "cd /opt/odoo$ODOO_VERSION" odoo"$ODOO_VERSION"
  su -c "source odoo-venv/bin/activate" odoo"$ODOO_VERSION"
  su -c "pip3 install wheel" odoo"$ODOO_VERSION"
  su -c "pip3 install paramiko" odoo"$ODOO_VERSION"
  su -c "pip3 install asn1crypto" odoo"$ODOO_VERSION"
  su -c "pip3 install pandas" odoo"$ODOO_VERSION"
  su -c "pip3 install -r /opt/odoo$ODOO_VERSION/odoo/requirements.txt" odoo"$ODOO_VERSION"

  if [ "$ENABLE_ENTERPRISE" = true ]; then
    su -c "git clone -b $ODOO_VERSION.0 https://${GITHUB_SUPER_ACCESS}@github.com/odoo/enterprise.git /opt/odoo$ODOO_VERSION/enterprise"
  fi

  su -c "deactivate"
  su -c "mkdir /opt/odoo$ODOO_VERSION/custom-addons"
}
function configure_odoo(){
  create_odoo_file
  create_service_file
  configure_logs
  sudo systemctl daemon-reload
  sudo systemctl enable --now odoo"$ODOO_VERSION"
  service odoo"$ODOO_VERSION" start
}
# create Logs Directory
function configure_logs(){
  mkdir /var/log/odoo"$ODOO_VERSION"
  chown odoo"$ODOO_VERSION":odoo"$ODOO_VERSION" /var/log/odoo"$ODOO_VERSION"
}
function create_odoo_file(){
  if [ "$ENABLE_ENTERPRISE" = true ]; then
    addons_path="/opt/odoo$ODOO_VERSION/odoo/addons,/opt/odoo$ODOO_VERSION/enterprise,/opt/odoo$ODOO_VERSION/custom-addons"
  else
    addons_path="/opt/odoo$ODOO_VERSION/odoo/addons,/opt/odoo$ODOO_VERSION/custom-addons"
  fi

  if [ "$IsCloud" = true ]; then
    proxy_value="True"
  else
    proxy_value="False"
  fi
  
  cat > /etc/odoo"$ODOO_VERSION".conf << HERE
[options]
; This is the password that allows database operations:
admin_passwd = $HASHED_PASSWORD
db_host = False
db_port = False
db_user = odoo$ODOO_VERSION
db_password = False
proxy_mode = $proxy_value
xmlrpc_port = $SYS_PORT
addons_path = $addons_path
logfile = /var/log/odoo$ODOO_VERSION/odoo$ODOO_VERSION.log
HERE
}
function create_service_file(){
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
ExecStart=/opt/odoo$ODOO_VERSION/odoo/odoo-bin -c /etc/odoo$ODOO_VERSION.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
HERE
}
function create_domain_file(){
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
   return 301 https://$host$request_uri;
   rewrite ^(.*) https://$host$1 permanent;
}

server {
 listen 443 ssl;
 server_name $DOMAIN_NAME;
 client_max_body_size 500M;
 proxy_read_timeout 720s;
 proxy_connect_timeout 720s;
 proxy_send_timeout 720s;

 # Add Headers for odoo proxy mode
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
 ssl_prefer_server_ciphers on;

 # log
 access_log /var/log/nginx/odoo.access.log;
 error_log /var/log/nginx/odoo.error.log;

 # Redirect longpoll requests to odoo longpolling port
 location /longpolling {
 proxy_pass http://odoochat;
 }

 # Redirect requests to odoo backend server
 location / {
   proxy_redirect off;
   proxy_pass http://odoo;
 }

 # common gzip
 gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;
 gzip on;
 gzip_types text/css application/javascript;
 gzip_min_length 1000; # Set an appropriate threshold length for compression.
 gzip_comp_level 9;    # Compression level (1-9, 1 being the fastest, 9 the best compression).
 gzip_vary on;
}
HERE
}
function link_domain(){
  systemctl stop nginx
  certbot certonly --standalone -d "$DOMAIN_NAME" --preferred-challenges http --agree-tos -n -m "$SSL_EMAIL" --keep-until-expiring
  
  # Define the crontab entry
  CRONTAB_ENTRY="@daily certbot renew --pre-hook 'service nginx stop' --post-hook 'service nginx start'"

  # Add the entry to the crontab
  (crontab -l 2>/dev/null; echo "$CRONTAB_ENTRY") | crontab -
  
  create_domain_file "$DOMAIN_NAME"

  ln -s "/etc/nginx/sites-available/$DOMAIN_NAME" "/etc/nginx/sites-enabled/$DOMAIN_NAME"
  rm /etc/nginx/sites-enabled/default
  systemctl restart nginx
}
function final_resualt(){
  echo -e "$GREEN ********************************************
        * Installation completed successfully
        * odoo  Version: $ODOO_VERSION                         
        * URL: $DOMAIN_NAME
        * Master Password Is: $MASTER_PASSWORD                                                                                          
        ******************************************************
        "
}

Main(){
    banner
    check_root
    check_ram
    check_x64
    check_ubuntu

    getOdooVersion
    getEditionName

    if [ "$ENABLE_ENTERPRISE" = true ]; then
    get_enterprise_username
    get_enterprise_password
    fi

    getPortNumber
    IsCloud

    if [ "$IsCloud" = true ]; then
    getDomainName
    getSSLEmail
    fi

    generateMasterPassword
    printUserInput

    configure_ufw
    install_dependencies
    create_user
    install_wkhtmltopdf
    installing_odoo
    configure_odoo

    if [ "$IsCloud" = true ]; then
    link_domain
    DOMAIN_NAME="https://$DOMAIN_NAME"
    else
    DOMAIN_NAME="http://localhost:$SYS_PORT"
    fi

    final_resualt


}
Main