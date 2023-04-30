#!/bin/bash

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