#!/bin/bash

# función de enumeración de vulnerabilidades de puertos TCP
function vulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=${3,,}

    if [ ! -n "$service" ]; then
        # obtención de nombre de servicio según puerto
        service="$(serviceNameByPort $port)"

        if [ -n "$service" ]; then
            # creación de directorio de servicio
            directoryCreation $service
            # título de enumeración de puerto TCP
            stageServiceEnumTCPProcessTitle $port $service        
            
            case $port in
                21)                     ftpVulnServiceEnumTCP   $port $mode $service ;; # FTP
                22)                     sshVulnServiceEnumTCP   $port $mode $service ;; # SSH
                25 | 465 | 587 | 2525)  smtpVulnServiceEnumTCP  $port $mode $service ;; # SMTP/S
                80 | 8080 | 443)        httpVulnServiceEnumTCP  $port $mode $service ;; # HTTP/S
                139 | 445)              smbVulnServiceEnumTCP   $port $mode $service ;; # NetBIOS y SMB
                3389)                   rdpVulnServiceEnumTCP   $port $mode $service ;; # RDP
                6379)                   redisVulnServiceEnumTCP $port $mode $service ;; # Redis               
            esac
        fi        
    else
        # creación de directorio de servicio
        directoryCreation $service
        # título de enumeración de servicio TCP
        stageServiceEnumTCPProcessTitle $port $service   

        case $service in            
            ftp)   ftpVulnServiceEnumTCP   $port $mode $service ;;
            ssh)   sshVulnServiceEnumTCP   $port $mode $service ;;
            smtp)  smtpVulnServiceEnumTCP  $port $mode $service ;;                
            http)  httpVulnServiceEnumTCP  $port $mode $service ;;
            https) httpVulnServiceEnumTCP  $port $mode $service ;;
            smb)   smbVulnServiceEnumTCP   $port $mode $service ;;
            rdp)   rdpVulnServiceEnumTCP   $port $mode $service ;;
            redis) redisVulnServiceEnumTCP $port $mode $service ;;            
        esac
    fi     
}

# FTP 
function ftpVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}

# SSH 
function sshVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}

# SMTP/S 
function smtpVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}

# HTTP/S 
function httpVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}

# NetBIOS y SMB 
function smbVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p 139,445 --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-139-445.txt &> /dev/null &
    spinner "Nmap" 2
}

# RDP 
function rdpVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}

# Redis 
function redisVulnServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    nmap -$threadsNmap -p $port --script=vuln -Pn $target -oN $mainDirectory/$vulnDirectory/nmap-$service-tcp-$port.txt &> /dev/null &
    spinner "Nmap" 2
}