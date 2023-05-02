#!/bin/bash

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

# función de escaneo con Nmap
function nmapScan(){
    local directory='ports'

    # creación de directorio Nmap
    directoryCreation $directory

    # título de etapa en proceso
    echo ''; stageProcessTitle "Port Scan"

    # TCP all port scan
    if [ "$elevatedPrivileges" = true ]; then 
        sudo nmap -sS -p- --open -n --min-rate 5000 -Pn $target -oN $mainDirectory/$directory/all-tcp-ports.txt -oG $mainDirectory/$workingDirectory/tcp-ports &> /dev/null &        
    else
        nmap -p- --open -n --min-rate 5000 -Pn $target -oN $mainDirectory/$directory/all-tcp-ports.txt -oG $mainDirectory/$workingDirectory/tcp-ports &> /dev/null &
    fi    
    echo ''; spinner "[Nmap - TCP all port scan]" 1    

    # extracción de puertos TCP
    nmapPortsExtract 'TCP'

    # muestra puertos TCP encontrados
    if [ -n "$TCPPortsTarget" ]; then
        echo ''; cat $mainDirectory/$directory/all-tcp-ports.txt | grep -v '#' | grep 'PORT\|[0-9]/tcp' | sed "s/.*/$indentation2&/g"
    else
        echo ''; echo -e "$indentation2${YELLOW}TCP ports not found.${NC}"
    fi

    if [ "$udpPortEnumeration" = true ]; then
        # UDP main port scan    
        sudo nmap -sU --top-port 10 -n -Pn $target -oN $mainDirectory/$directory/main-udp-ports.txt -oG $mainDirectory/$workingDirectory/udp-ports &> /dev/null &
        echo ''; spinner "[Nmap - UDP main port scan]" 1

        # extracción de puertos UDP
        nmapPortsExtract 'UDP'

        # muestra puertos UDP encontrados
        if [ -n "$UDPPortsTarget" ]; then
            echo ''; cat $mainDirectory/$directory/main-udp-ports.txt | grep -v '#' | grep 'PORT\|[0-9]/udp' | sed "s/.*/$indentation2&/g"
        else
            echo ''; echo -e "$indentation2${YELLOW}UDP ports not found.${NC}"
        fi
    fi    

    # identificación de servicios TCP
    if [ -n "$TCPPortsTarget" ]; then
        nmap -sC -sV -$threadsNmap -p $TCPPortsTarget -Pn $target -oN $mainDirectory/$directory/tcp-ports-services.txt &> /dev/null &
        echo ''; spinner "[Nmap - Identification of services and versions of TCP ports]" 1
        echo ''; cat $mainDirectory/$directory/tcp-ports-services.txt | grep -v '#' | grep 'PORT\|[0-9]/tcp' | sed "s/.*/$indentation2&/g"
    fi

    # identificación de servicios UDP
    if [ -n "$UDPPortsTarget" ]; then
        sudo nmap -sU -sV -p $UDPPortsTarget -Pn $target -oN $mainDirectory/$directory/udp-ports-services.txt &> /dev/null &
        echo ''; spinner "[Nmap - Identification of services and versions of UDP ports]" 1
        echo ''; cat $mainDirectory/$directory/udp-ports-services.txt | grep -v '#' | grep 'PORT\|[0-9]/udp' | sed "s/.*/$indentation2&/g"
    fi

}