#!/bin/bash

# This script will provide guidance on how to automate sys admin tasks.
# It will also provide a list of commands that can be used to automate
# tasks.

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[1;34m"
ENDCOLOR="\e[0m"

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