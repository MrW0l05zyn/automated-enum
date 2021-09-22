#!/bin/bash

# variables
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

function usage() { 
    echo -e "\nUsage:"
    echo -e "\t$0 -t <TARGET> [-s <SERVICE>]"

    echo -e "\nOptions:"
    echo -e "\t-t <TARGET>\tTarget/Host IP address"
    echo -e "\t-s <SERVICE>\tService name: HTTP|SMB|SMTP|SNMP|SSH"
    echo -e "\t-h \t\tShows instructions on how to use the tool"

    echo -e "\nExamples:"
    echo -e "\t$0 -t X.X.X.X"
    echo -e "\t$0 -t X.X.X.X -s HTTP"    

    exit 0
}

# función que realiza validación del parámetro "(-t) target"
function targetParameterValidation(){
    if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "\n${YELLOW}Invalid target \"(-t)\" argument.${NC}"
        usage
    fi
}

# parámetros
if [ $# -eq 0 ]; then
    banner
    usage
fi
while getopts ":t:s:h" arg; do
    case $arg in
        t) # target
            target=${OPTARG}
            targetParameterValidation $target
            ;;
        s) # service
            service=${OPTARG}      
            ;;
        h | *) # usage
            usage
            exit 0
            ;;
    esac
done

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

# función de escaneo con Nmap
function nmapScan(){
    local directory='nmap'

    # creación de directorio Nmap
    directoryCreation $directory

    # TCP all port scan
    echo -e "\n${GREEN}[Nmap - TCP all port scan]${NC}\n"
    sudo nmap -sS -p- --open -n --min-rate 5000 -Pn $target -oN $mainDirectory/$directory/all-tcp-ports.txt -oG $mainDirectory/$workingDirectory/tcp-ports
    nmapPortsExtract 'TCP'

    # UDP main port scan
    echo -e "\n${GREEN}[Nmap - UDP main port scan]${NC}\n"
    sudo nmap -sU -p $topUDPPorts --open -n -Pn $target -oN $mainDirectory/$directory/main-udp-ports.txt -oG $mainDirectory/$workingDirectory/udp-ports
    nmapPortsExtract 'UDP'
    
    # identificación de servicios
    if [ -n "$TCPPortsTarget" ]; then
        echo -e "\n${GREEN}[Nmap - Identification of services and versions of TCP ports]${NC}\n"
        nmap -sC -sV -p $TCPPortsTarget -Pn $target -oN $mainDirectory/$directory/tcp-ports-services.txt
    fi        
}

# principal
main() {
    # muestra banner de la herramienta
    banner
    # creación de directorio principal    
    [ ! -d "./$mainDirectory" ] && mkdir "$mainDirectory"
    # creación de directorio de trabajo
    directoryCreation $workingDirectory

    #echo "Target: $target"
    #echo "Service: $service"

    # Nmap scan
    nmapScan
}

# inicio de automatedEnum
main "$@"