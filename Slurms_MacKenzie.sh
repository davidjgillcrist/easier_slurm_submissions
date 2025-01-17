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
node=1
ntasks=4
mem=8192 # 8GB of RAM by default
hours=4
jobname="djg-%j"
gpus=0 # No GPUs by default
gpuname="M2050"
partition="cpu"
########################################################

NoFileFlag=1

arguments=( "$@" )
for arg in "$@"; do
    case $arg in
        -h|--help)
        printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n'\
                "-f, --file:      Pass a file to run via Slurm. Not optional must be passed."\
                "-N, --node:      The number of nodes to run on. Default is 1."\
                "-n, --ntasks:    The number of processors used per node. Default is 4."\
                "-m, --mem:       The number of megabytes of RAM reserved for the submission. Default is 8192 MB (8 GB)."\
                "-t, --time:      The number of hours reservered for the submission. Default is 4 hours."\
                "-g, --gpus:      The number of GPUs to reserve. Default is 0."\
                "-G, --gpuname:   The name of the type of GPU being requested. Default is M2050."\
                "-p, --partition: The name of the partition that the job is being sent to. Default is cpu."\
                "-j, --jobname:   The name of the job as shown on squeue. Default is job-%j."
        return
           ;;
        -f|--file)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            file=$option
            NoFileFlag=0
        fi
          ;;
        -N|--node)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            node=$option
        fi
          ;;
        -n|--ntasks)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            ntaks=$option
        fi
          ;;
        -m|--mem)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            mem=$option
        fi
          ;;
        -t|--time)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            hours=$option
        fi
          ;;
        -j|--jobname)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            jobname="${option}"
        fi
          ;;
        -g|--gpus)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            gpus=$option
        fi
            ;;
        -G|--gpuname)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            gpuname=$option
        fi
            ;;
        -p|--partition)
        i=$(($(get_index arguments $arg) + 1))
        option=${arguments[$i]}
        if [[ $option == -* ]] || [[ -z "$option" ]]; then
            echo "An option must be passed when using $arg. Script has been exited."
            return
        else
            partition=$option
        fi
    esac
done

if [[ $NoFileFlag -eq 1 ]]; then
    echo "No file was passed. Please include a file after the flag --file or -f. Script has been exited."
    return
fi

echo -e "#!/bin/sh\n" > ~/ActualSlurmSubmitter.slurm

echo "#SBATCH --output=$HOME/outfiles/slurm-%j.out" >> ~/ActualSlurmSubmitter.slurm
echo -e "#SBATCH --error=$HOME/outfiles/slurm-%j.err\n" >> ~/ActualSlurmSubmitter.slurm

echo "#SBATCH --nodes=$node" >> ~/ActualSlurmSubmitter.slurm
echo "#SBATCH --ntasks-per-node=$ntasks" >> ~/ActualSlurmSubmitter.slurm
echo "#SBATCH --partition=$partition" >> ~/ActualSlurmSubmitter.slurm
echo "#SBATCH --mem=$mem" >> ~/ActualSlurmSubmitter.slurm
echo "#SBATCH --time=${hours}:00:00" >> ~/ActualSlurmSubmitter.slurm
echo "#SBATCH --job-name=$jobname" >> ~/ActualSlurmSubmitter.slurm
echo -e "#SBATCH --gres=gpu:$gpuname:$gpus\n" >> ~/ActualSlurmSubmitter.slurm

echo ". $PWD/$file" >> ~/ActualSlurmSubmitter.slurm

sbatch ~/ActualSlurmSubmitter.slurm
