#!/bin/bash

# variables
target=''
service=''
services=(HTTP SMB SMTP SNMP SSH)
TCPPortsTarget=''
parameterCounter=0
mainDirectory='automatedEnum'
workingDirectory='working'
topUDPPorts='53,67,68,69,111,123,135,137,138,139,161,162,445,500,514,520,631,998,1434,1701,1900,4500,5353,49152,49154'
version='0.1'

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
    echo "                             [ Author : MrW0l05zyn | Version : $version ]                               "
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

# función de validación del parámetro "(-t) target"
function targetParameterValidation(){
    if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "\n${YELLOW}Invalid target \"(-t)\" argument.${NC}"
        usage
    fi
}
# función de validación del parámetro "(-s) service"
function serviceParameterValidation(){
    local validService=false

    if [ -n "$1" ]; then
        for i in "${services[@]}"; do
            if [ $i = $service ]; then
                validService=true
                break
            fi
        done
        if [ ! $validService = true ]; then
            echo -e "\n${YELLOW}Invalid service \"(-s)\" argument.${NC}"
            usage
        fi
    fi
}

# parámetros
while getopts ":t:s:h" arg; do
    case $arg in
        t) # target
            target=${OPTARG}
            # validación del parámetro "(-t) target"
            targetParameterValidation $target
            let parameterCounter+=1            
            ;;
        s) # service
            service=${OPTARG^^}
            let parameterCounter+=1
            ;;
        h | *) # usage
            usage
            ;;
    esac
done

# función de validación del parámetros
function parameterValidation(){
    # validación de cantidad de parámetros
    if [ ! $parameterCounter -ge 1 ]; then
        banner
        usage
    fi
    # validación del parámetro "(-t) target"
    targetParameterValidation $target
    # validación del parámetro "(-s) service"
    serviceParameterValidation $service
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

# función que entrega nombre de servicio según puerto TCP/UDP
function serviceNameByPort(){
    local serviceName=''

    case $1 in        
        22) # SSH
            serviceName='ssh'             
            ;;
        80 | 8080) # HTTP
            serviceName='http'
            ;;
        25 | 465 | 587) # SMTP/S
            serviceName='smtp'
            ;;
        139 | 445) # SMB
            serviceName='smb'
            ;;
        161 | 162) # SNMP
            serviceName='snmp'
            ;;             
    esac

    echo "$serviceName"
}

# función de enumeración de puertos TCP
function serviceEnumTCP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName

    case $1 in
        22) # SSH            
            ;;
        80 | 8080) # HTTP
            dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-tcp-$1.txt 
            #dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-extension-tcp-$1.txt -e php,aspx,jsp,html,js,txt,bak -f
            ;;
        25 | 465 | 587) # SMTP/S
            smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-vrfy-top-tcp-$1.txt
            smtp-user-enum -M EXPN -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-expn-top-tcp-$1.txt
            smtp-user-enum -M RCPT -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-rcpt-top-tcp-$1.txt
            ;;
        139 | 445) # SMB
            ;;                                    
    esac
}

# función de enumeración de puertos UDP
function serviceEnumUDP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName

    case $1 in        
        161 | 162) # SNMP
            sudo nmap -sC -sV -sU -p 161,162 -Pn $target -oN $mainDirectory/$serviceName/nmap-snmp.txt
            ;;                                    
    esac
}

# principal
main() {
    # validación de parámetros
    parameterValidation

    # muestra banner de la herramienta
    banner

    # creación de directorio principal    
    [ ! -d "./$mainDirectory" ] && mkdir "$mainDirectory"

    # creación de directorio de trabajo
    directoryCreation $workingDirectory

    # Nmap scan
    nmapScan

    # enumeración de puertos TCP
    IFS=', ' read -r -a ports <<< "$TCPPortsTarget"
    for port in "${ports[@]}"; do
        serviceEnumTCP $port
    done

    # enumeración de puertos UDP
    IFS=', ' read -r -a ports <<< "$UDPPortsTarget"
    for port in "${ports[@]}"; do
        serviceEnumUDP $port
    done
}

# inicio de herramienta automatedEnum
main "$@"