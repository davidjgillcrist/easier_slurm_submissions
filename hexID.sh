#!/bin/zsh

# Print this moments unique Hex ID
hexID () {
   momentID=$(printf '%s\n' "$(( $(date +%s%N | cut -b1-16) ))" | awk \
       '{n=$1; s=""; while(n>0){d=n%36; if(d<10){c=sprintf("%d",d)}else{c=sprintf("%c",87+d)}; s=c s; n=int(n/36)} print s}')
   echo "$momentID" | tr '[:lower:]' '[:upper:]'
}
