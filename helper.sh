#!/bin/bash

# This script will provide guidance on how to automate sys admin tasks.
# It will also provide a list of commands that can be used to automate
# tasks.

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[1;34m"
ENDCOLOR="\e[0m"



# create function that checks the directory structure
function checkdir() {
    # if the directory exists, continue
    if [ -d $1 ]; then
        # check if user has tree installed, if not install it
        if [ ! -f /usr/bin/tree ]; then
            echo -e "${RED}Tree is not installed, installing now...${ENDCOLOR}"
            sudo apt-get install tree -y
            wait
        fi
        echo -e "${GREEN}Directory $1 exists...${ENDCOLOR}"
        # so total number of files in the directory but not directories
        echo -e "${BLUE}Total number of files in $1: $(ls -l $1 | grep -v ^d | wc -l)${ENDCOLOR}"
        echo -e "${BLUE}Total number of directories in $1: $(ls -l $1 | grep ^d | wc -l)${ENDCOLOR}"
        #  use tree command to show the directory structure
        find $1 -maxdepth 1 -type d | while read -r dir
        # get the number of files in each directory and print it
        do
            echo -e "   ${BLUE}Total number of files in $dir: $(ls -l $dir | grep -v ^d | wc -l)${ENDCOLOR}"
        done
        # get owner of the directory
        echo -e "${BLUE}Owner of $1 is $(ls -ld $1 | awk '{print $3}')${ENDCOLOR}"
        # get group of the directory
        echo -e "${BLUE}Group of $1 is $(ls -ld $1 | awk '{print $4}')${ENDCOLOR}"
        # get permissions of the directory
        echo -e "${BLUE}Permissions of $1 is $(ls -ld $1 | awk '{print $1}')${ENDCOLOR}"
    else
        echo -e "${RED}Directory $1 does not exist...${ENDCOLOR}"
    fi
}


if [ $# -eq 0 ]; then
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  help - print this help message"
    exit 0
fi

# create help that gives a list of commands
if [ $1 = "help" ]; then
    echo -e "${BLUE}Usage: $1 ${ENDCOLOR}"
    echo -e "${BLUE}Commands ${ENDCOLOR}"
    echo -e "${BLUE}  update-system - update all apt installed resouces and packages${ENDCOLOR}"
    echo -e "${BLUE}  install-wp - installs wordpress${ENDCOLOR}"
    echo -e "${BLUE}  directory-check - installs wordpress${ENDCOLOR}"
    echo -e "${BLUE}  email - takes \{email\} argument ${ENDCOLOR}"
    exit 0
fi

# if the first argument is "update-system", run the update system command
if [ $1 = "update-system" ]; then
    echo -e "${BLUE}Updating System...${ENDCOLOR}"
    sudo apt-get update && sudo apt-get upgrade -y
    wait
    echo -e "${GREEN}System Updated!${ENDCOLOR}"
    exit 0
fi

# if the first argument is "install-wp", run the install wordpress command
if [ $1 = "install-wp" ]; then
    echo -e "${BLUE}Installing Wordpress...${ENDCOLOR}"
    # check if install-wp.sh is executable, if not make it executable
    if [ ! -x install-wp.sh ]; then
        echo -e "${RED}install-wp.sh is not executable, making it executable now...${ENDCOLOR}"
        chmod +x install-wp.sh
        wait
    fi
    # run the install-wp.sh script
    ./install-wp.sh
fi

if [ $1 = "check" ]; then
    # check if $2 is empty
    if [ -z "$2" ]; then
        echo -e "${RED}You must include a directory name (example /var/www/html)${ENDCOLOR}"
        exit 1
    fi
    wait
    checkdir "$2"
    exit 0
fi

if [ $1 = "email" ]; then
    shift
    if [ -z "$2" ]; then
        echo -e "${RED}You must include an email address${ENDCOLOR}"
        exit 1
    fi
    wait
    if [ $(dpkg-query -W -f='${Status}' mailutils 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo -e "${RED}mailutils is not installed${ENDCOLOR}"
        sudo apt install mailutils -y
        exit 1
    fi

    cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t", $(NF-2)}')
    ram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
    disk=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')

    mail -s 'VM Usage' -a From:Admin\<admin@example.com\>
    $2 <<< "CPU: $cpu
    RAM: $ram
    DISK: $disk"

    echo -e "${GREEN}Email Sent!${ENDCOLOR}"

fi