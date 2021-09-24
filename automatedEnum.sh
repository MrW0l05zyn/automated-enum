#!/bin/bash

# variables
target=''
mode='basic'
modes=(basic full)
service=''
services=(HTTP HTTPS SMB SMTP SNMP SSH)
TCPPortsTarget=''
UDPPortsTarget=''
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
    echo -e "\t$0 -t <TARGET> [-m <MODE>] [-s <SERVICE>]"

    echo -e "\nOptions:"
    echo -e "\t-t <TARGET>\tTarget/Host IP address"
    echo -e "\t-m <MODE>\tMode: basic|full (default: basic)"
    echo -e "\t-s <SERVICE>\tService name: HTTP|HTTPS|SMB|SMTP|SNMP|SSH"
    echo -e "\t-h \t\tShows instructions on how to use the tool"

    echo -e "\nExamples:"
    echo -e "\t$0 -t X.X.X.X"
    echo -e "\t$0 -t X.X.X.X -m full"
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

# función de validación del parámetro "(-m) mode"
function modeParameterValidation(){
    local validMode=false

    if [ -n "$1" ]; then
        for i in "${modes[@]}"; do
            if [ $i = $mode ]; then
                validMode=true
                break
            fi
        done
        if [ ! $validMode = true ]; then
            echo -e "\n${YELLOW}Invalid mode \"(-m)\" argument.${NC}"
            usage
        fi
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
while getopts ":t:m:s:h" arg; do
    case $arg in
        t) # target
            target=${OPTARG}
            # validación del parámetro "(-t) target"
            targetParameterValidation $target
            let parameterCounter+=1            
            ;;
        m) # mode
            mode=${OPTARG,,}
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
    # validación del parámetro "(-m) mode"
    modeParameterValidation $mode
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
        22) serviceName='ssh' ;;
        25 | 465 | 587) serviceName='smtp' ;;
        80 | 443) serviceName='http' ;;
        139 | 445) serviceName='smb' ;;
        161 | 162) serviceName='snmp' ;;
    esac

    echo "$serviceName"
}

# función que configura puertos TCP/UDP por nombre de servicio
function portConfByServiceName(){

    case $1 in
        SSH) 
            TCPPortsTarget='22'
        ;;
        HTTP) 
            TCPPortsTarget='80'
        ;;
        HTTPS) 
            TCPPortsTarget='443'
        ;;        
        SMTP)
            TCPPortsTarget='25'
        ;;
        SMB)
            TCPPortsTarget='445'
        ;;
        SNMP)
            UDPPortsTarget='161,162'
        ;;
    esac
}

# función de enumeración de puertos TCP
function serviceEnumTCP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName

    case $1 in
        22) # SSH

            ;;
        80 | 443) # HTTP/S
            
            dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-tcp-$1.txt

            if [ $mode = 'full' ]; then
                dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-extension-tcp-$1.txt -e php,aspx,jsp,html,js,txt,bak -f
            fi

            ;;
        25 | 465 | 587) # SMTP/S

            smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-vrfy-top-tcp-$1.txt

            if [ $mode = 'full' ]; then
                smtp-user-enum -M EXPN -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-expn-top-tcp-$1.txt
                smtp-user-enum -M RCPT -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-rcpt-top-tcp-$1.txt
            fi

            ;;
        139 | 445) # NetBIOS y SMB

            smbclient -N -L $target --option='client min protocol=NT1' | tee $mainDirectory/$serviceName/smbclient-tcp-$1.txt
            smbmap -H $target | tee $mainDirectory/$serviceName/smbmap-tcp-$1.txt

            if [ $mode = 'full' ]; then
                smbmap -R -H $target | tee $mainDirectory/$serviceName/smbmap-recursive-tcp-$1.txt
            fi

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

    # enumeracion por servicio
    if [ -n "$service" ]; then
        portConfByServiceName $service
    else
        # Nmap scan
        nmapScan
    fi

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