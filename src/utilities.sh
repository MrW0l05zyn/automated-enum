#!/bin/bash

# función de título de etapa en proceso
function stageProcessTitle(){
    local title=${1^^}

    echo -e "${BGREEN}[ $title ]${NC}"
}

# función de título de enumeración de puerto / servicio TCP en proceso
function stageServiceEnumTCPProcessTitle(){
    local port=$1
    local service=${2^^}

    if [ ! -n "$service" ]; then
        case $port in            
            139 | 445) # NetBIOS y SMB
                echo -e "${GREEN}$indentation1[139/TCP (NetBIOS), 445/TCP (SMB)]${NC}"
            ;;
            *)
                echo -e "${GREEN}$indentation1[$port/TCP ($service)]${NC}"
            ;;            
        esac
    else
        case $service in            
            smb) # NetBIOS y SMB
                echo -e "${GREEN}$indentation1[139/TCP (NetBIOS), 445/TCP (SMB)]${NC}"    
            ;;
            *)
                echo -e "${GREEN}$indentation1[$port/TCP ($service)]${NC}"
            ;;            
        esac
    fi   
}

# función de título de enumeración de puerto / servicio UDP en proceso
function stageServiceEnumUDPProcessTitle(){
    local port=$1
    local service=${2^^}

    if [ ! -n "$service" ]; then
        case $port in            
            161 | 162) # SNMP
                echo -e "${GREEN}$indentation1[161/UDP, 162/UDP ($service)]${NC}"
            ;;
            *)
                echo -e "${GREEN}$indentation1[$port/UDP ($service)]${NC}"
            ;;            
        esac
    else
        case $service in            
            snmp)
                echo -e "${GREEN}$indentation1[161/UDP, 162/UDP ($service)]${NC}" 
            ;;
            *)
                echo -e "${GREEN}$indentation1[$port/UDP ($service)]${NC}"
            ;;            
        esac
    fi
}

# función de creación de directorios
function directoryCreation(){
    [ ! -d "./$mainDirectory/$1" ] && mkdir "./$mainDirectory/$1"
}

# función que entrega nombre de servicio según puerto TCP/UDP
function serviceNameByPort(){
    local serviceName=''

    case $1 in        
        21)                     serviceName='ftp'   ;;
        22)                     serviceName='ssh'   ;;
        25 | 465 | 587 | 2525)  serviceName='smtp'  ;;
        80 | 8080)              serviceName='http'  ;;
        443)                    serviceName='https' ;;
        139 | 445)              serviceName='smb'   ;;
        161 | 162)              serviceName='snmp'  ;;
        3389)                   serviceName='rdp'   ;;
        6379)                   serviceName='redis' ;;        
    esac

    echo "$serviceName"
}

# función que configura puertos TCP/UDP por nombre de servicio
function portConfByServiceName(){

    case $1 in
        FTP)   TCPPortsTarget='21'         ;;
        SSH)   TCPPortsTarget='22'         ;;
        SMTP)  TCPPortsTarget='25,465,587' ;;
        HTTP)  TCPPortsTarget='80'         ;;
        HTTPS) TCPPortsTarget='443'        ;;
        SMB)   TCPPortsTarget='139,445'    ;;
        SNMP)  UDPPortsTarget='161,162'    ;;
        RDP)   TCPPortsTarget='3389'       ;;
        REDIS) TCPPortsTarget='6379'       ;;
    esac
}