#!/bin/bash

# variables
target=''
mode='basic'
modes=(basic vuln full)
service=''
services=(FTP HTTP HTTPS RDP REDIS SMB SMTP SNMP SSH)
udpPortEnumeration=0
elevatedPrivileges=0
port=''
TCPPortsTarget=''
UDPPortsTarget=''
parameterCounter=0
toolName='automatedEnum.sh'
mainSourceCodeDirectory=$(dirname $(readlink -f $0))
mainDirectory='automatedEnum'
vulnDirectory='vulns'
workingDirectory='.working'
version='0.2'
indentation1='   '
indentation2='      '
noCategoriesNmapScript='brute or broadcast or dos or external or fuzzer'

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

# referencias a funciones
source $mainSourceCodeDirectory/src/banner.sh
source $mainSourceCodeDirectory/src/nmap.sh
source $mainSourceCodeDirectory/src/parameters.sh
source $mainSourceCodeDirectory/src/spinner.sh
source $mainSourceCodeDirectory/src/utilities.sh
source $mainSourceCodeDirectory/src/serviceEnumTCP.sh
source $mainSourceCodeDirectory/src/serviceEnumUDP.sh
source $mainSourceCodeDirectory/src/vulnServiceEnumTCP.sh

# parámetros
while getopts ":t:m:s:p:uh" arg; do
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
        p) # port
            port=${OPTARG}
            let parameterCounter+=1
        ;;
        u) # UDP ports
            udpPortEnumeration=1
        ;;                
        h | *) # usage
            usage
        ;;
    esac
done

# principal
main() {    
    # validación de parámetros
    parameterValidation

    # validación de privilegios de root para escaneo y enumeración de puertos UDP
    if [ "$(id -u)" -eq 0 ]; then    
        elevatedPrivileges=1        
    elif [ "$udpPortEnumeration" -eq 1 ]; then
        echo -e "\n${YELLOW}Elevated privileges are required to scan and enumerate UDP ports.\n${NC}"
        if ! sudo true; then
            exit 1
        else
            elevatedPrivileges=1
        fi
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
    if [ -n "$port" ]; then
        TCPPortsTarget=$port
    elif [ -n "$service" ]; then
        portConfByServiceName $service
    else
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
                    serviceEnumTCP $port $mode $service                    
                done
            fi

            # enumeración básica de puertos UDP
            if [ -n "$udpPorts" ]; then
                echo ''; stageProcessTitle "basic enumeration (udp ports)" 1; echo ''
                for port in "${udpPorts[@]}"; do
                    serviceEnumUDP $port $mode $service
                done
            fi
        ;;
        full)            
            # enumeración full de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "full enumeration (tcp ports)" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    serviceEnumTCP $port $mode $service
                done            
            fi

            # enumeración full de puertos UDP
            if [ -n "$udpPorts" ]; then
                echo ''; stageProcessTitle "full enumeration (udp ports)" 1; echo ''
                for port in "${udpPorts[@]}"; do
                    serviceEnumUDP $port $mode $service
                done
            fi            
            
            # enumeración de vulnerabilidades de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "vulnerability enumeration" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    vulnServiceEnumTCP $port $mode $service
                done
            fi
        ;;
        vuln)            
            # enumeración de vulnerabilidades de puertos TCP
            if [ -n "$tcpPorts" ]; then
                echo ''; stageProcessTitle "vulnerability enumeration" 1; echo ''
                for port in "${tcpPorts[@]}"; do
                    vulnServiceEnumTCP $port $mode $service
                done
            fi
        ;;
    esac
}

# inicio de herramienta automatedEnum
main "$@"