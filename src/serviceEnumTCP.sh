#!/bin/bash

# función de enumeración de puertos TCP
function serviceEnumTCP(){
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
                21)                     ftpServiceEnumTCP   $port $mode $service ;; # FTP
                22)                     sshServiceEnumTCP   $port $mode $service ;; # SSH
                25 | 465 | 587 | 2525)  smtpServiceEnumTCP  $port $mode $service ;; # SMTP/S
                80 | 8080)              httpServiceEnumTCP  $port $mode $service ;; # HTTP
                443)                    httpsServiceEnumTCP $port $mode $service ;; # HTTPS
                139 | 445)              smbServiceEnumTCP   $port $mode $service ;; # NetBIOS y SMB
                3389)                   rdpServiceEnumTCP   $port $mode $service ;; # RDP
                6379)                   redisServiceEnumTCP $port $mode $service ;; # Redis            
            esac
        fi        
    else
        # creación de directorio de servicio
        directoryCreation $service
        # título de enumeración de servicio TCP
        stageServiceEnumTCPProcessTitle $port $service   

        case $service in
            ftp)   ftpServiceEnumTCP   $port $mode $service ;;
            ssh)   sshServiceEnumTCP   $port $mode $service ;;
            smtp)  smtpServiceEnumTCP  $port $mode $service ;;                
            http)  httpServiceEnumTCP  $port $mode $service ;;
            https) httpsServiceEnumTCP $port $mode $service ;;
            smb)   smbServiceEnumTCP   $port $mode $service ;;
            rdp)   rdpServiceEnumTCP   $port $mode $service ;;
            redis) redisServiceEnumTCP $port $mode $service ;;            
        esac
    fi    
}

# FTP 
function ftpServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,ftp* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
        ;;
        full)

        ;;        
    esac
}

# SSH 
function sshServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,ssh* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
        ;;
        full)
                     
        ;;        
    esac
}

# SMTP
function smtpServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,smtp* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
            smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $port | tee $mainDirectory/$service/smtp-user-enum-vrfy-top-tcp-$port.txt &> /dev/null &
            spinner "smtp-user-enum - VRFY" 2
        ;;
        full)
            smtp-user-enum -M EXPN -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $port | tee $mainDirectory/$serviceName/smtp-user-enum-expn-top-tcp-$port.txt &> /dev/null &
            spinner "smtp-user-enum - EXPN" 2
            smtp-user-enum -M RCPT -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $target -p $port | tee $mainDirectory/$serviceName/smtp-user-enum-rcpt-top-tcp-$port.txt &> /dev/null &
            spinner "smtp-user-enum - RCPT" 2                     
        ;;        
    esac
}

# HTTP 
function httpServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,http* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
            whatweb -v -a 1 http://$target:$port/ 2>/dev/null | tee $mainDirectory/$service/whapweb-tcp-$port.txt &> /dev/null &
            spinner "WhatWeb" 2
            dirsearch -u http://$target:$port/ -o $(pwd)/$mainDirectory/$service/dirsearch-tcp-$port.txt &> /dev/null &
            spinner "dirsearch" 2
        ;;
        full)
            dirsearch -u http://$target:$port/ -o $(pwd)/$mainDirectory/$service/dirsearch-extension-tcp-$port.txt -e php,aspx,jsp,html,js,txt,bak -f &> /dev/null &
            spinner "dirsearch - Extension (php,aspx,jsp,html,js,txt,bak)" 2
            dirsearch -u http://$target:$port/cgi-bin/ -o $(pwd)/$mainDirectory/$service/dirsearch-cgi-bin-tcp-$port.txt -e sh,pl -f &> /dev/null &
            spinner "dirsearch - cgi-bin (sh,pl)" 2             
        ;;        
    esac
}

# HTTPS
function httpsServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,http* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
            whatweb -v -a 1 https://$target:$port/ | tee $mainDirectory/$service/whapweb-tcp-$port.txt &> /dev/null &
            spinner "WhatWeb" 2
            dirsearch -u https://$target:$port/ -o $(pwd)/$mainDirectory/$service/dirsearch-tcp-$port.txt &> /dev/null &
            spinner "dirsearch" 2
        ;;
        full)
            dirsearch -u https://$target:$port/ -o $(pwd)/$mainDirectory/$serviceName/dirsearch-extension-tcp-$port.txt -e php,aspx,jsp,html,js,txt,bak -f &> /dev/null &
            spinner "dirsearch - Extension (php,aspx,jsp,html,js,txt,bak)" 2           
        ;;        
    esac
}

# NetBIOS y SMB
function smbServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    echo $service

    case $mode in        
        basic)
            nmap -sV -p 139,445 --script="banner,smb* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-139-445.txt &> /dev/null &
            spinner "Nmap" 2
            smbclient -N -L $target --option='client min protocol=NT1' 2>/dev/null | tee $mainDirectory/$service/smbclient.txt &> /dev/null &
            spinner "smbclient" 2
            smbmap -H $target | tee $mainDirectory/$service/smbmap.txt &> /dev/null &
            spinner "SMBMap" 2
        ;;
        full)
            smbmap -R -H $target | tee $mainDirectory/$serviceName/smbmap-recursive.txt &> /dev/null &
            spinner "SMBMap - Recursive" 2           
        ;;        
    esac
}

# RDP 
function rdpServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,rdp* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
        ;;
        full)
                     
        ;;        
    esac
}

# Redis 
function redisServiceEnumTCP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            nmap -sV -p $port --script="banner,redis* and not ($noCategoriesNmapScript)" -Pn $target 2>/dev/null | tee $mainDirectory/$service/nmap-tcp-$port.txt &> /dev/null &
            spinner "Nmap" 2
        ;;
        full)
                     
        ;;        
    esac
}