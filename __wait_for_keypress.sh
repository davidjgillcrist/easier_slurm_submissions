#!/bin/zsh

__wait_for_keypress () {
    waitTime=$1
    
    shouldBreak=0
    
    if read -rs -k1 -t $waitTime key; then
        case "$key" in
            Q|q)
                shouldBreak=1
                ;;
        esac
    fi
   
    echo "$key"

    return $shouldBreak
}
