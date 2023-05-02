#!/bin/bash

# función de enumeración de puertos UDP
function serviceEnumUDP(){
    local port=$1
    local mode=$2
    local service=${3,,}

    if [ ! -n "$service" ]; then
        # obtención de nombre de servicio según puerto
        service="$(serviceNameByPort $port)"

        if [ -n "$service" ]; then
            # creación de directorio de servicio
            directoryCreation $service
            # título de enumeración de puerto UDP
            stageServiceEnumUDPProcessTitle $port $service        
            
            case $port in
                161 | 162) snmpServiceEnumUDP $port $mode $service ;; # SNMP                
            esac
        fi        
    else
        # creación de directorio de servicio
        directoryCreation $service
        # título de enumeración de servicio TCP
        stageServiceEnumTCPProcessTitle $port $service   

        case $service in            
            snmp) snmpServiceEnumUDP $port $mode $service ;;            
        esac
    fi
}

# SNMP 
function snmpServiceEnumUDP(){
    local port=$1
    local mode=$2
    local service=$3

    case $mode in        
        basic)
            sudo nmap -sC -sV -sU -p 161,162 -Pn $target -oN $mainDirectory/$service/nmap-snmp-udp-161-162.txt &> /dev/null &
            spinner "Nmap" 2
            snmp-check -p 161 $target | tee $mainDirectory/$service/snmp-check-udp-161.txt &> /dev/null &
            spinner "snmp-check" 2
        ;;
        full)

        ;;        
    esac
}