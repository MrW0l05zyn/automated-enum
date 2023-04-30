#!/bin/bash

# función de uso
function usage() {
    echo -e "\nUsage:"
    echo -e "\t$toolName -t <TARGET> [-m <MODE>] [-s <SERVICE>] [-p <PORT>] [-u]"

    echo -e "\nOptions:"
    echo -e "\t-t <TARGET>\tTarget/Host IP address"
    echo -e "\t-m <MODE>\tMode: basic|vuln|full (default: basic)"
    echo -e "\t-s <SERVICE>\tService name: FTP|HTTP|HTTPS|RDP|REDIS|SMB|SMTP|SNMP|SSH"
    echo -e "\t-p <PORT>\tPort number"
    echo -e "\t-u \t\tUDP port scanning and enumeration (default only TCP ports)"
    echo -e "\t-h \t\tShows instructions on how to use the tool"

    echo -e "\nExamples:"
    echo -e "\t$toolName -t X.X.X.X"
    echo -e "\t$toolName -t X.X.X.X -s HTTP"
    echo -e "\t$toolName -t X.X.X.X -s HTTP -p 8080"
    echo -e "\t$toolName -t X.X.X.X -m full"
    echo -e "\t$toolName -t X.X.X.X -m vuln -s SMB"    

    exit 0
}

# función de validación del parámetro "(-t) target"
function targetParameterValidation(){
    regexIP='^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5]))$'
    regexHostname='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'

    # validación de dirección IP y hostname
    if [[ ! $1 =~ $regexIP ]] && [[ ! $1 =~ $regexHostname ]]; then
        echo -e "\n${YELLOW}Invalid target argument \"(-t)\".${NC}"
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
            echo -e "\n${YELLOW}Invalid mode argument \"(-m)\".${NC}"
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
            echo -e "\n${YELLOW}Invalid service argument \"(-s)\".${NC}"
            usage
        fi
    fi
}

# función de validación del parámetro "(-p) port"
function portParameterValidation(){
    local port=$1
    local service=$2

    if [ -n "$port" ] ; then
        if ! [[ $port =~ ^[0-9]+$ && $port -ge 0 && $port -le 65535 ]]; then
            echo -e "\n${YELLOW}Invalid port argument \"(-p)\".${NC}"
            usage
        elif [ ! -n "$service" ]; then
            echo -e "\n${YELLOW}You must specify the service running on the port (argument \"-s\").${NC}"
            usage
        fi
    fi
}

# función de validación del parámetros
function parameterValidation(){
    # validación de cantidad de parámetros
    if [ ! $parameterCounter -ge 1 ]; then
        banner
        usage
    fi
    # validación del parámetro "(-t) target"
    targetParameterValidation $target
    # validación del parámetro "(-m) mode"
    modeParameterValidation $mode    
    # validación del parámetro "(-s) service"
    serviceParameterValidation $service
    # validación del parámetro "(-p) port"
    portParameterValidation $port $service    
}