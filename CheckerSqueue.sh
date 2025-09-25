#!/bin/zsh

CheckerSqueue () {
    if [ -z "$1" ]; then
        Usqueue
    elif [ -z "$2" ]; then
        local displayLines=$1
        local linesShown=$(( $displayLines + 3 ))
        Usqueue | head -n "$linesShown"
    else
        local refreshTime=$1
        local displayLines=$2
        local headerSize=3 # Full height of the header part of Usqeue
        local fullEscape=0
        local numInQueue=$(( $(Usqueue | wc -l) - headerSize ))
        local infoLines=(" ") # First entry is a blank line to create buffer between Usqueue and infoLines
        infoLines+=("# of uncompleted jobs: $numInQueue")
        local removeUnwantedLine=${#infoLines[@]}
        infoLines+=($'\033[1;33mNOTE\033[0m: Press q or Q to exit.')
        local numInfoLines=${#infoLines[@]}

        if (( numInQueue > 0 )); then
            local linesShown=$(( displayLines + headerSize ))
            local isFirst=1
            local quickTime
            while (( numInQueue > 0 )); do
                if (( isFirst )); then
                    isFirst=0
                else
                    __clear_lines "$(( linesShown + numInfoLines ))"
                    infoLines[$removeUnwantedLine]="# of uncompleted jobs: $numInQueue"
                fi
                if (( linesShown > numInQueue )); then
                    linesShown=$(( numInQueue + headerSize ))
                fi
                Usqueue | head -n "$linesShown"
                printf '%s\n' "${infoLines[@]}"
                printf '%s' "Input: "
                key=$(__wait_for_keypress $refreshTime); fullEscape=$?
                (( fullEscape == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break 
                numInQueue=$(( $(Usqueue | wc -l) - headerSize ))
                while (( numInQueue < 0 )); do
                    quickTime=0.25
                    key=$(__wait_for_keypress $quickTime); fullEscape=$?
                    (( fullEscape == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break
                    numInQueue=$(( $(Usqueue | wc -l) - headerSize ))
                done
                (( fullEscape == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break
            done
        else
            emptyJobs=$'\033[1;33mWarning:\033[0m There are no jobs running on Unity right now. \
                Either your script hasn\'t finished submitting them, they\'ve completed already, \
                or you forgot to submit any.'
        fi
    
        if (( fullEscape == 1 )); then
            # Do Nothing
        else 
            if [[ ! -z $emptyJobs ]]; then
                printf '%s' "$emptyJobs"
            else
                __clear_lines "$(( linesShown + numInfoLines ))"
                local finalOutput=$'All jobs have either \033[1;32mfinished\033[0m running on Unity, \
                    have \033[1;31mfailed\033[0m to be picked up by Slurm, or were \033[1;31m aborted\033[0m \
                    in their execution due to errors. Check your various outfile directories for details.'
                local cols=$(tput cols)
                local wrappedLines=$(echo "$finalOutput" | fold -s -w $cols)
                echo "$wrappedLines" | while IFS= read -r line; do
                    printf '%s\n' "$line"
                done 
            fi 

            local timer=17
            local numRings=3
            local spacingSecs=1.275
            local btwnRings=0.875
            local shouldBreak

            unset "infoLines[$removeUnwantedLine]"
            printf '%s\n' "${infoLines[@]}"
            printf '%s' "Input: "
            while (( timer > 0 )); do
                for i in {1..$numRings}; do
                    printf "\a"
                    key=$(__wait_for_keypress $spacingSecs); shouldBreak=$?
                    (( shouldBreak == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break
                done
                (( shouldBreak == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break
                key=$(__wait_for_keypress $btwnRings); shouldBreak=$?
                (( shouldBreak == 1 )) && __clear_lines 0 && printf '%s\n%s\n' "Input: $key" "Exiting squeue monitoring..." && break
                (( timer-- ))
            done
        fi
    fi
}
