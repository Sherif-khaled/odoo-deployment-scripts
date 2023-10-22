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
ODOO_VERSION=16
SYS_PORT=8077
DOMAIN_NAME=''
SSL_EMAIL=''
MASTER_PASSWORD=
ENABLE_ENTERPRISE=false
REBO_TOKEN=
GETHUB_USERNAME=
GITHUB_SUPER_ACCESS=
REPO_NAME=''

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




Main(){
    banner
    check_root
    check_ram
    check_x64
    check_ubuntu
}
Main