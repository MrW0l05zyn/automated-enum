#!/bin/bash

# variables
target=''
mode='basic'
modes=(basic vuln full)
service=''
services=(FTP HTTP HTTPS RDP SMB SMTP SNMP SSH)
TCPPortsTarget=''
UDPPortsTarget=''
parameterCounter=0
mainDirectory='automatedEnum'
vulnDirectory='vulns'
workingDirectory='.working'
topUDPPorts='53,67,68,69,111,123,135,137,138,139,161,162,445,500,514,520,631,998,1434,1701,1900,4500,5353,49152,49154'
version='0.1'
indentation1='   '
indentation2='      '

# colores
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# bold
BGREEN='\033[1;32m'

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

# función de uso
function usage() {
    echo -e "\nUsage:"
    echo -e "\t$0 -t <TARGET> [-m <MODE>] [-s <SERVICE>]"

    echo -e "\nOptions:"
    echo -e "\t-t <TARGET>\tTarget/Host IP address"
    echo -e "\t-m <MODE>\tMode: basic|vuln|full (default: basic)"
    echo -e "\t-s <SERVICE>\tService name: FTP|HTTP|HTTPS|RDP|SMB|SMTP|SNMP|SSH"
    echo -e "\t-h \t\tShows instructions on how to use the tool"

    echo -e "\nExamples:"
    echo -e "\t$0 -t X.X.X.X"
    echo -e "\t$0 -t X.X.X.X -s HTTP"
    echo -e "\t$0 -t X.X.X.X -m full"
    echo -e "\t$0 -t X.X.X.X -m vuln -s SMB"    

    exit 0
}

# función de validación del parámetro "(-t) target"
function targetParameterValidation(){
    regexIP='^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5]))$'
    regexHostname='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'

    # Validación de dirección IP y hostname
    if [[ ! $1 =~ $regexIP ]] && [[ ! $1 =~ $regexHostname ]]; then
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
            if [ -e "./$mainDirectory/$workingDirectory/tcp-ports" ]; then
                TCPPortsTarget="$(cat $mainDirectory/$workingDirectory/tcp-ports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
            fi
        ;;
        UDP)
            if [ -e "./$mainDirectory/$workingDirectory/udp-ports" ]; then
                UDPPortsTarget="$(cat $mainDirectory/$workingDirectory/udp-ports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
            fi
        ;;
    esac    
}

# función de spinner para ejecución de procesos
function spinner(){
    local indentation='';
    local info="$1"
    local pid=$!
    local delay=0.25
    local spinstr='|/-\'

    case $2 in        
        1) indentation=$indentation1;;
        2) indentation=$indentation2;;
    esac

    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf "${PURPLE}$indentation[%c] $info${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        local reset="\b\b\b\b\b\b"
        for ((i=1; i<=$(echo -e "$indentation$info" | wc -c); i++)); do
            reset+="\b"
        done
        printf $reset
    done

    case $2 in        
        2) printf "$indentation[\u2713] $info\n";;
        *) printf "${GREEN}$indentation[\u2713] $info${NC}\n";;        
    esac    
}

# función de título de etapa en proceso
function stageProcessTitle(){
    echo -e "${BGREEN}[${1^^}]${NC}"
}

# función de escaneo con Nmap
function nmapScan(){
    local directory='ports'

    # creación de directorio Nmap
    directoryCreation $directory    

    # título de etapa en proceso
    echo ''; stageProcessTitle "Port Scan"

    # TCP all port scan
    sudo nmap -sS -p- --open -n --min-rate 5000 -Pn $target -oN $mainDirectory/$directory/all-tcp-ports.txt -oG $mainDirectory/$workingDirectory/tcp-ports &> /dev/null &
    echo ''; spinner "[Nmap - TCP all port scan]" 1

    # extracción de puertos TCP
    nmapPortsExtract 'TCP'

    # muestra puertos TCP encontrados
    if [ -n "$TCPPortsTarget" ]; then
        echo ''; cat $mainDirectory/$directory/all-tcp-ports.txt | grep -v '#' | grep 'PORT\|[0-9]/tcp' | sed "s/.*/$indentation2&/g"
    else
        echo ''; echo -e "\t${YELLOW}TCP ports not found.${NC}"
    fi

    # UDP main port scan    
    sudo nmap -sU -p $topUDPPorts --open -n -Pn $target -oN $mainDirectory/$directory/main-udp-ports.txt -oG $mainDirectory/$workingDirectory/udp-ports &> /dev/null &
    echo ''; spinner "[Nmap - UDP main port scan]" 1

    # extracción de puertos UDP
    nmapPortsExtract 'UDP'

    # muestra puertos UDP encontrados
    if [ -n "$UDPPortsTarget" ]; then
        echo ''; cat $mainDirectory/$directory/main-udp-ports.txt | grep -v '#' | grep 'PORT\|[0-9]/udp' | sed "s/.*/$indentation2&/g"
    else
        echo ''; echo -e "\t${YELLOW}UDP ports not found.${NC}"
    fi   

    # identificación de servicios
    if [ -n "$TCPPortsTarget" ]; then
        nmap -sC -sV -p $TCPPortsTarget -Pn $target -oN $mainDirectory/$directory/tcp-ports-services.txt &> /dev/null &
        echo ''; spinner "[Nmap - Identification of services and versions of TCP ports]" 1
        echo ''; cat $mainDirectory/$directory/tcp-ports-services.txt | grep -v '#' | grep 'PORT\|[0-9]/tcp' | sed "s/.*/$indentation2&/g"
    fi    
}

# función que entrega nombre de servicio según puerto TCP/UDP
function serviceNameByPort(){
    local serviceName=''

    case $1 in        
        21)             serviceName='ftp'   ;;
        22)             serviceName='ssh'   ;;
        25 | 465 | 587) serviceName='smtp'  ;;
        80 | 8080)      serviceName='http'  ;;
        443)            serviceName='https' ;;
        139 | 445)      serviceName='smb'   ;;
        161 | 162)      serviceName='snmp'  ;;
        3389)           serviceName='rdp'   ;;
    esac

    echo "$serviceName"
}

# función que configura puertos TCP/UDP por nombre de servicio
function portConfByServiceName(){

    case $1 in
        FTP)   TCPPortsTarget='21'      ;;
        SSH)   TCPPortsTarget='22'      ;;        
        SMTP)  TCPPortsTarget='25'      ;;        
        HTTP)  TCPPortsTarget='80'      ;;
        HTTPS) TCPPortsTarget='443'     ;;
        SMB)   TCPPortsTarget='445'     ;;        
        SNMP)  UDPPortsTarget='161,162' ;;
        RDP)   TCPPortsTarget='3389'    ;;        
    esac
}

# función de enumeración básica de puertos TCP
function basicServiceEnumTCP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName

    case $1 in
        21) # FTP
            
        ;;    
        22) # SSH
            
        ;;
        80 | 8080) # HTTP
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"

            whatweb -v -a 1 http://$target:$1/ | tee $mainDirectory/$serviceName/whapweb-tcp-$1.txt &> /dev/null &
            spinner "[WhatWeb]" 2
            dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-tcp-$1.txt &> /dev/null &
            spinner "[dirsearch]" 2
        ;;
        443) # HTTPS
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"

            whatweb -v -a 1 https://$target:$1/ | tee $mainDirectory/$serviceName/whapweb-tcp-$1.txt &> /dev/null &
            spinner "[WhatWeb]" 2
            dirsearch -u https://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-tcp-$1.txt &> /dev/null &
            spinner "[dirsearch]" 2
        ;;            
        25 | 465 | 587) # SMTP/S
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"

            smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-vrfy-top-tcp-$1.txt &> /dev/null &
            spinner "[smtp-user-enum - VRFY]" 2
        ;;
        139 | 445) # NetBIOS y SMB
            echo -e "${GREEN}$indentation1[139/TCP (NetBIOS), 445/TCP (SMB)]${NC}"

            smbclient -N -L $target --option='client min protocol=NT1' 2>/dev/null | tee $mainDirectory/$serviceName/smbclient.txt &> /dev/null &
            spinner "[smbclient]" 2
            smbmap -H $target | tee $mainDirectory/$serviceName/smbmap.txt &> /dev/null &
            spinner "[SMBMap]" 2
        ;;
    esac
}

# función de enumeración full de puertos TCP
function fullServiceEnumTCP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName

    case $1 in
        21) # FTP

        ;;    
        22) # SSH

        ;;
        80) # HTTP        
            dirsearch -u http://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-extension-tcp-$1.txt -e php,aspx,jsp,html,js,txt,bak -f &> /dev/null &
            spinner "[dirsearch - Extension (php,aspx,jsp,html,js,txt,bak)]" 2
        ;;            
        443) # HTTPS
            dirsearch -u https://$target:$1/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-extension-tcp-$1.txt -e php,aspx,jsp,html,js,txt,bak -f &> /dev/null &
            spinner "[dirsearch - Extension (php,aspx,jsp,html,js,txt,bak)]" 2
        ;;
        25 | 465 | 587) # SMTP/S
            smtp-user-enum -M EXPN -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-expn-top-tcp-$1.txt &> /dev/null &
            spinner "[smtp-user-enum - EXPN]" 2
            smtp-user-enum -M RCPT -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $1 | tee $mainDirectory/$serviceName/smtp-user-enum-rcpt-top-tcp-$1.txt &> /dev/null &
            spinner "[smtp-user-enum - RCPT]" 2
        ;;
        139 | 445) # NetBIOS y SMB
            smbmap -R -H $target | tee $mainDirectory/$serviceName/smbmap-recursive.txt &> /dev/null &
            spinner "[SMBMap - Recursive]" 2
        ;;                                    
    esac
}

# función de enumeración de vulnerabilidades de puertos TCP
function vulnServiceEnumTCP(){
    # obtención de nombre de servicio según puerto TCP
    serviceName="$(serviceNameByPort $1)"

    case $1 in
        21) # FTP
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"            
            nmap -p $1 --script=vuln $target -oN $mainDirectory/$vulnDirectory/nmap-$serviceName-tcp-$1.txt &> /dev/null &
            spinner "[Nmap]" 2
        ;;    
        22) # SSH
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"
            nmap -p $1 --script=vuln $target -oN $mainDirectory/$vulnDirectory/nmap-$serviceName-tcp-$1.txt &> /dev/null &
            spinner "[Nmap]" 2
        ;;
        80 | 8080 | 443) # HTTP/S
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"
            nmap -p $1 --script=vuln $target -oN $mainDirectory/$vulnDirectory/nmap-$serviceName-tcp-$1.txt &> /dev/null &
            spinner "[Nmap]" 2
        ;;
        25 | 465 | 587) # SMTP/S
            echo -e "${GREEN}$indentation1[$1/TCP (${serviceName^^})]${NC}"
            nmap -p $1 --script=vuln $target -oN $mainDirectory/$vulnDirectory/nmap-$serviceName-tcp-$1.txt &> /dev/null &
            spinner "[Nmap]" 2
        ;;
        139 | 445) # NetBIOS y SMB
            echo -e "${GREEN}$indentation1[139/TCP (NetBIOS), 445/TCP (SMB)]${NC}"
            nmap -p 139,445 --script=vuln $target -oN $mainDirectory/$vulnDirectory/nmap-$serviceName.txt &> /dev/null &
            spinner "[Nmap]" 2
        ;;
    esac
}

# función de enumeración básica de puertos UDP
function basicServiceEnumUDP(){
    # obtención de nombre de servicio según puerto UDP
    serviceName="$(serviceNameByPort $1)"
    directoryCreation $serviceName    

    case $1 in        
        161 | 162) # SNMP
            echo -e "${GREEN}$indentation1[161/UDP, 162/UDP (${serviceName^^})]${NC}"

            sudo nmap -sC -sV -sU -p 161,162 -Pn $target -oN $mainDirectory/$serviceName/nmap-snmp-udp-161-162.txt &> /dev/null &
            spinner "[Nmap]" 2
            snmp-check -p 161 $target | tee $mainDirectory/$serviceName/snmp-check-udp-161.txt &> /dev/null &
            spinner "[snmp-check]" 2
        ;;                                    
    esac
}

# principal
main() {    
    # validación de parámetros
    parameterValidation

    # validación de privilegios de root
    if ! sudo true; then
        exit 1
    fi

    # muestra banner de la herramienta
    banner

    # creación de directorio principal    
    [ ! -d "./$mainDirectory" ] && mkdir "$mainDirectory"

    # creación de directorio de trabajo
    directoryCreation $workingDirectory

    # creación de directorio de vulnerabilidades
    if [ $mode = 'full' ] || [ $mode = 'vuln' ]; then
        directoryCreation $vulnDirectory
    fi

    # configuración de puertos a enumerar
    if [ -n "$service" ]; then
        portConfByServiceName $service
    else
        # Nmap scan
        nmapScan
    fi

    IFS=', ' read -r -a tcpPorts <<< "$TCPPortsTarget"
    IFS=', ' read -r -a udpPorts <<< "$UDPPortsTarget"

    case $mode in        
        basic)        
            # enumeración básica de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "basic enumeration (tcp ports)" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    basicServiceEnumTCP $port
                done
            fi

            # enumeración básica de puertos UDP
            if [ -n "$udpPorts" ]; then
                echo ''; stageProcessTitle "basic enumeration (udp ports)" 1; echo ''
                for port in "${udpPorts[@]}"; do
                    basicServiceEnumUDP $port
                done
            fi
        ;;
        full)            
            # enumeración full de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "full enumeration (tcp ports)" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    basicServiceEnumTCP $port
                    fullServiceEnumTCP $port
                done            
            fi
            
            # enumeración de vulnerabilidades de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "vulnerability enumeration" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    vulnServiceEnumTCP $port
                done
            fi
        ;;
        vuln)            
            # enumeración de vulnerabilidades de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "vulnerability enumeration" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    vulnServiceEnumTCP $port
                done
            fi
        ;;
    esac
}

# inicio de herramienta automatedEnum
main "$@"