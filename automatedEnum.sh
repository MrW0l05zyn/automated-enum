#!/bin/bash

# variables
target=$1
mainDirectory='automatedEnum'
workingDirectory='working'
topUDPPorts='53,67,68,69,111,123,135,137,138,139,161,162,445,500,514,520,631,998,1434,1701,1900,4500,5353,49152,49154'

# colores
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# función de banner
function banner(){ 
    echo '                 _____                        _____     __________________                         '
    echo '   ______ ____  ___  /_____________ _________ __  /___________  /__  ____/__________  ________ ___ '
    echo '   _  __ `/  / / /  __/  __ \_  __ `__ \  __ `/  __/  _ \  __  /__  __/  __  __ \  / / /_  __ `__ \'
    echo '   / /_/ // /_/ // /_ / /_/ /  / / / / / /_/ // /_ /  __/ /_/ / _  /___  _  / / / /_/ /_  / / / / /'
    echo '   \__,_/ \__,_/ \__/ \____//_/ /_/ /_/\__,_/ \__/ \___/\__,_/  /_____/  /_/ /_/\__,_/ /_/ /_/ /_/ '
    echo '                                                                                                   '
    echo '                             [ Author : MrW0l05zyn | Version : 0.1 ]                               '
}

# función de escaneo con Nmap
function nmapScan(){
    local directory='nmap'

    # creación de directorio Nmap
    directoryCreation $directory

    # TCP all port scan
    echo -e "\n$GREEN[Nmap - TCP all port scan]$NC\n"
    sudo nmap -sS -p- --open -n --min-rate 5000 -Pn $target -oN $mainDirectory/$directory/all-tcp-ports.txt -oG $mainDirectory/$workingDirectory/tcp-ports
    nmapPortsExtract 'TCP'

    # UDP main port scan
    echo -e "\n$GREEN[Nmap - UDP main port scan]$NC\n"
    sudo nmap -sU -p $topUDPPorts --open -n -Pn $target -oN $mainDirectory/$directory/main-udp-ports.txt -oG $mainDirectory/$workingDirectory/udp-ports
    nmapPortsExtract 'UDP'
    
    # identificación de servicios
    if [ -n "$TCPPortsTarget" ]; then
        echo -e "\n$GREEN[Nmap - Identification of services and versions of TCP ports]$NC\n"
        nmap -sC -sV -p $TCPPortsTarget -Pn $target -oN $mainDirectory/$directory/tcp-ports-services.txt
    fi        
}

# función de creación de directorios
function directoryCreation(){
    [ ! -d "./$mainDirectory/$1" ] && mkdir "./$mainDirectory/$1"
}

# función de extracción de puertos TCP y UDP de Nmap
function nmapPortsExtract(){
    case $1 in
        TCP)
            TCPPortsTarget="$(cat $mainDirectory/$workingDirectory/tcp-ports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
            ;;
        UDP)
            UDPPortsTarget="$(cat $mainDirectory/$workingDirectory/udp-ports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
            ;;
    esac    
}

# principal
main() {
    # muestra banner de herramienta
    banner
    # creación de directorio principal    
    [ ! -d "./$mainDirectory" ] && mkdir "$mainDirectory"
    # creación de directorio de trabajo
    directoryCreation $workingDirectory

    # Nmap scan
    nmapScan
}

# inicio de automatedEnum
main "$@"