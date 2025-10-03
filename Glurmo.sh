#!/bin/bash

get_index () {
    name=$1[@]
    arr=("${!name}")
    element=$2
    for j in "${!arr[@]}"; do
        if [[ "${arr[$j]}" = "$element" ]]; then
            index=$j
            break
        fi
    done

    echo $index
}

source ~/easier_slurm_submissions/hexID.sh

################################################################################
# THIS IS WHERE YOU SPECIFY THE JOBS/TASKS TO RUN
################################################################################

########################################################
################# DEFAULT OPTIONS SET ##################
########################################################
ntasks=24
mem=36
hours=12
jobgroupname="djg"
gpus=0 # No GPUs by default
gpuname="1080ti"
partition="cpu"
totalchunks=1
startingchunk=1
lastchunk=1
########################################################


NoFileFlag=1
NoIDFlag=1

earlyBreak=0

arguments=( "$@" )
for arg in "$@"; do
    case $arg in
        -h|--help)
            printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n'\
                    "-f, --file:           Pass a file to MATLAB file that will run in 'chunks' to several nodes. Not optional must be passed."\
                    "-n, --ntasks:         The number of processors used across all nodes. Default is 24."\
                    "-m, --mem:            The number of gigabytes of RAM reserved for the submission. Default is 36 GB."\
                    "-t, --time:           The number of hours reservered for the submission. Default is 12 hours."\
                    "-g, --gpus:           The number of GPUs to reserve. Default is 0."\
                    "-G, --gpuname:        The name of the type of GPU being requested. Default is 1080ti."\
                    "-p, --partition:      The name of the partition that the job is being sent to. Default is cpu."\
                    "-j, --jobgroupname:       The name of the describing the group of jobs being submitted as shown on squeue. Default is djg."\
                    "-T, --total-chunks:   The total number of chunks that the MATLAB script will be split up into. Defualt is 1."\
                    "-S, --starting-chunk: The index of the first chunk to be run out of the total-chunks. Omits running chunks with indices < starting-chunk. Default is 1."\
                    "-L, --last-chunk:     The index of the last chunk to be run out of the total-chunks. Omits running chunks with indices > last-chunk. Default is 1."\
                    "-I, --groupID:        A mandatory ID to submit with a group of jobs used to track what jobs stem from the same script."
            earlyBreak=1; break
        ;;
        -f|--file)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                runfilename=${option::-2}
                NoFileFlag=0
            fi  
        ;;    
        -n|--ntasks)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                ntasks=$option
            fi
        ;;
        -m|--mem)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                mem=$option
            fi
        ;;
        -t|--time)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                hours=$option
            fi
        ;;
        -j|--jobgroupname)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                jobgroupname="$option"
            fi
        ;;
        -g|--gpus)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                gpus=$option
            fi
        ;;
        -G|--gpuname)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                gpuname=$option
            fi
        ;;
        -p|--partition)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                partition=$option
            fi
        ;;
        -T|--total-chunks)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                totalchunks=$option
            fi
        ;;
        -S|--starting-chunk)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                startingchunk=$option
            fi
        ;;
        -L|--last-chunk)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Submissions have been aborted."
                earlyBreak=1; break
            else
                lastchunk=$option
            fi
        ;;
        -I|--groupID)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                if [[ $totalchunks -ne 1 ]]; then
                    echo "An option must be passed when using $arg. Submissions have been aborted."
                    break
                else
                    groupID=$(hexID)
                    printf '%s%s%s\n' $'You forget to pass a groupID with the options -I or --groupID. Assigning the groupID this moment\'s hex code: \033[1;31m' "$groupID" $'\033[0m'
                    NoIDFlag=0
                fi
            else
                groupID=${option}
                NoIDFlag=0
            fi
    esac
done

if [[ $NoFileFlag -eq 1 ]]; then
    printf '%s\n' $'\033[1;31mNo\033[0m file was passed. Please include a file after the flag --file or -f. Submissions have been aborted.'
fi

if [[ "$lastchunk" -gt "$totalchunks" ]] || [[ "$totalchunks" -lt "$startingchunk" ]] || [[ "$lastchunk" -lt "$startingchunk" ]] || [[ "$totalchunks" -lt 1 ]]; then
    echo "ERROR: Please insure that your 1 <= starting chunk <= last chunk <= total chunks."
    earlyBreak=1
fi

if [[ $NoIDFlag -eq 1 ]] && [[ $totalchunks -ne 1 ]]; then
    printf '%s\n' $'\033[1;31mNo\033[0m groupID was provided. This is a necessary input to determine what jobs are tied together. Please give an ID after passing the flag --groupID or -I. Submissions have been aborted'
    earlyBreak=1
elif [[ $NoIDFlag -eq 1 ]] && [[ $totalchunks -eq 1 ]]; then
    groupID=$(hexID)
    NoGroupIDprefix=$(printf '%s'\
        $'\033[1;31mNo\033[0m groupID was provided, but the variable "\033[1;33mtotalchunks\033[0m" is equal to 1. Assigning it this moment\'s hex code: \033[1;32m'
    )
    printf '%s%s%s\n' "$NoGroupIDprefix" "$groupID" $'\033[0m'
fi

if [ ! -f ~/easier_slurm_submissions/ParpoolPreamble.m ]; then
    echo "ERROR: You need a preamble file for the MATLAB script in your home directory."
    earlyBreak=1
fi

if (( earlyBreak == 0)); then
    LINE="${runfilename}[1-9]*.m"
    FILE='slurm_MATLAB_history.txt'
    
    if [ ! -f ${FILE} ]; then # Writes file name that will be run into a history text file for easy deletion later
        touch "$FILE"
        grep -qxF -- "$LINE" "$FILE" || echo "$LINE" > "$FILE"
    else
        grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
    fi
    
    for ChunkRun in $(seq -f '%03g' $startingchunk $lastchunk); do
        shebangline='#!/bin/bash'
        echo $shebangline > RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        matmodeline='module load matlab/r2025a'
        echo $matmodeline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        commandline='myCommand='
        commandline+="${runfilename}.m"
        echo $commandline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        timestampID=$(date +%s%N)
        cp ./${runfilename}.m ./${runfilename}${timestampID}.m
        copyline='mv ./${myCommand%??}'
        copyline+="${timestampID}.m " 
        copyline+='${myCommand%??}${SLURM_JOBID}.m'
        echo $copyline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        imprintID='sed -i "0,/groupID =.*/s//groupID = \"'
        imprintID+="$groupID"
        imprintID+='\";/" ${myCommand%??}${SLURM_JOBID}.m'
        echo $imprintID >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        totalchunkline='sed -i "0,/totalchunks =.*/s//totalchunks = '
        totalchunkline+="$totalchunks"
        totalchunkline+=';/" ${myCommand%??}${SLURM_JOBID}.m'
        echo $totalchunkline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        chunkrunline='sed -i "0,/ChunkRun =.*/s//ChunkRun = '
        chunkrunline+="$ChunkRun"
        chunkrunline+=';/" ${myCommand%??}${SLURM_JOBID}.m'
        echo $chunkrunline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
    
        preamble='sed -i -e "0r $HOME/easier_slurm_submissions/ParpoolPreamble.m" ${myCommand%??}${SLURM_JOBID}.m'
        echo $preamble >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        outline='myOutfile="MATLAB_outfile_'
        outline+="${ChunkRun}_${jobgroupname}_${groupID}"
        outline+='_${SLURM_JOBID}.txt"'
        echo $outline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        checkdir="if [ ! -d ./matlab_outfiles/ ]; then\n\tmkdir matlab_outfiles\nfi"
        echo -e $checkdir >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh 
        
        wrapperline='matlab -batch "${myCommand%??}${SLURM_JOBID}" > ./matlab_outfiles/$myOutfile'
        echo $wrapperline >> RunOnCluster_${jobgroupname}.${ChunkRun}.sh
        
        runline="WimmyWamWamWozzle -f RunOnCluster_${jobgroupname}.${ChunkRun}.sh -N 1 -n $ntasks -m $mem -t $hours -g $gpus -G $gpuname -j ${jobgroupname}.${ChunkRun}_${groupID}"
        echo "#!/bin/zsh\n" > RunTheRunner.sh
        echo "source ~/easier_slurm_submissions/WimmyWamWamWozzle.sh" >> RunTheRunner.sh
        echo $runline >> RunTheRunner.sh
        . ./RunTheRunner.sh
    done
fi
