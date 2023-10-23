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
ENABLE_ENTERPRISE=false
REBO_TOKEN=
GETHUB_USERNAME=
GITHUB_SUPER_ACCESS=
REPO_NAME=''
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
function getDomainName(){

  while [[ -z "$DOMAIN_NAME" ]]
  do
    read -p "Enter the domain name: " DOMAIN_NAME
  done
}

Main(){
    banner
    #check_root
    #check_ram
    #check_x64
    #check_ubuntu

    #getOdooVersion
    #getEditionName
    #getPortNumber
    #IsCloud
    getDomainName


}
Main