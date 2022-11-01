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