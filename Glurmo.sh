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

################################################################################
# THIS IS WHERE YOU SPECIFY THE JOBS/TASKS TO RUN
################################################################################

########################################################
################# DEFAULT OPTIONS SET ##################
########################################################
ntasks=24
mem=36
hours=12
jobgroup="djg"
gpus=0 # No GPUs by default
gpuname="1080ti"
partition="cpu"
totalchunks=1
startingchunk=1
lastchunk=1
########################################################


NoFileFlag=1

arguments=( "$@" )
for arg in "$@"; do
    case $arg in
        -h|--help)
        printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n'\
                "-f, --file:           Pass a file to MATLAB file that will run in 'chunks' to several nodes. Not optional must be passed."\
                "-n, --ntasks:         The number of processors used across all nodes. Default is 24."\
                "-m, --mem:            The number of gigabytes of RAM reserved for the submission. Default is 36 GB."\
                "-t, --time:           The number of hours reservered for the submission. Default is 12 hours."\
                "-g, --gpus:           The number of GPUs to reserve. Default is 0."\
                "-G, --gpuname:        The name of the type of GPU being requested. Default is 1080ti."\
                "-p, --partition:      The name of the partition that the job is being sent to. Default is cpu."\
                "-j, --jobgroup:       The name of the describing the group of jobs being submitted as shown on squeue. Default is djg."\
                "-T, --total-chunks:   The total number of chunks that the MATLAB script will be split up into. Defualt is 1."\
                "-S, --starting-chunk: The index of the first chunk to be run out of the total-chunks. Omits running chunks with indices < starting-chunk. Default is 1."\
                "-L, --last-chunk:     The index of the last chunk to be run out of the total-chunks. Omits running chunks with indices > last-chunk. Default is 1."
        return
           ;;
        -f|--file)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            runfilename=${option::-2}
            NoFileFlag=0
        fi  
            ;;
        -n|--ntasks)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            ntasks=$option
        fi
          ;;
        -m|--mem)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            mem=$option
        fi
          ;;
        -t|--time)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            hours=$option
        fi
          ;;
        -j|--jobgroup)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            jobgroup="${option:0:5}"
        fi
          ;;
        -g|--gpus)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            gpus=$option
        fi
            ;;
        -G|--gpuname)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            gpuname=$option
        fi
            ;;
        -p|--partition)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            partition=$option
        fi
            ;;
        -T|--total-chunks)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            totalchunks=$option
        fi
            ;;
        -S|--starting-chunk)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            startingchunk=$option
        fi
            ;;
        -L|--last-chunk)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been returned."
            return
        else
            lastchunk=$option
        fi        
    esac
done

if [[ "$lastchunk" -gt "$totalchunks" ]] || [[ "$totalchunks" -lt "$startingchunk" ]] || [[ "$lastchunk" -lt "$startingchunk" ]]; then
    echo "ERROR: Please insure that your starting chunk <= last chunk <= total chunks."
    return
fi

if [ ! -f ~/easier_slurm_submissions/ParpoolPreamble.m ]; then
    echo "ERROR: You need a preamble file for the MATLAB script in your home directory."
    return
fi

LINE="${runfilename}[1-9]*.m"
FILE='slurm_MATLAB_history.txt'

if [ ! -f ${FILE} ]; then # Writes file name that will be run into a history text file for easy deletion later
    touch "$FILE"
    grep -qxF -- "$LINE" "$FILE" || echo "$LINE" > "$FILE"
else
    grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
fi

for ChunkRun in $(seq -f '%02g' $startingchunk $lastchunk); do
    shebangline='#!/bin/bash'
    echo $shebangline > RunOnCluster_${jobgroup}.${ChunkRun}.sh
    matmodeline='module load matlab/r2024a'
    echo $matmodeline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    commandline='myCommand='
    commandline+="${runfilename}.m"
    echo $commandline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    copyline='cp ./$myCommand ${myCommand%??}${SLURM_JOBID}.m'
    echo $copyline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    totalchunkline='sed -i "s/totalchunks =.*/totalchunks = '
    totalchunkline+="$totalchunks"
    totalchunkline+=';/g" ${myCommand%??}${SLURM_JOBID}.m'
    echo $totalchunkline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    chunkrunline='sed -i "/if ChunkRun/ ! s/ChunkRun =.*/ChunkRun = '
    chunkrunline+="$ChunkRun"
    chunkrunline+=';/g" ${myCommand%??}${SLURM_JOBID}.m'
    echo $chunkrunline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    cp $HOME/easier_slurm_submissions/ParpoolPreamble.m ./
    preamble='sed -i -e "0r ParpoolPreamble.m" ${myCommand%??}${SLURM_JOBID}.m'
    echo $preamble >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    outline='myOutfile="cdf_outfile_'
    outline+="${ChunkRun}_${jobgroup}"
    outline+='_${SLURM_JOBID}.txt"'
    echo $outline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    wrapperline='matlab -nosplash -nodesktop < ${myCommand%??}${SLURM_JOBID}.m > ./matlab_outfiles/$myOutfile'
    echo $wrapperline >> RunOnCluster_${jobgroup}.${ChunkRun}.sh
    runline="WimmyWamWamWozzle -f RunOnCluster_${jobgroup}.${ChunkRun}.sh -N 1 -n $ntasks -m $mem -t $hours -g $gpus -G $gpuname -j ${jobgroup}.${ChunkRun}"
    echo $runline > RunTheRunner.sh
    source RunTheRunner.sh
    
done
