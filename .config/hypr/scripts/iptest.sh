#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

print_ip() {
    IP=$(curl -s "$1" | tr -d '\n')
    printf "%s%s%s\n" "$IP" "${GREEN} ✓" "${RESET}"
}

echo -e "\033[1;32m
██╗   ██╗ ██████╗ ██╗   ██╗██████╗     ██╗██████╗    
╚██╗ ██╔╝██╔═══██╗██║   ██║██╔══██╗    ██║██╔══██╗██╗
 ╚████╔╝ ██║   ██║██║   ██║██████╔╝    ██║██████╔╝╚═╝
  ╚██╔╝  ██║   ██║██║   ██║██╔══██╗    ██║██╔═══╝ ██╗
   ██║   ╚██████╔╝╚██████╔╝██║  ██║    ██║██║     ╚═╝
   ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═╝╚═╝
\033[0m"

print_ip "api.ipify.org"
print_ip "icanhazip.com"
print_ip "ipinfo.io/ip"

