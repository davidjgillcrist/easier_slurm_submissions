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
mem=8
hours=4
timestamp="$(date "+%M%S")"
jobname="$(echo djg.$timestamp)"
gpus=0 # No GPUs by default
gpuname="1080ti"
partition="cpu"
########################################################

NoFileFlag=1

arguments=( "$@" )
for arg in "$@"; do
    case $arg in
        -h|--help)
            printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n'\
                    "-f, --file:      Pass a file to run via Slurm. Not optional must be passed."\
                    "-N, --node:      The number of nodes to run on. Default is 1."\
                    "-n, --ntasks:    The number of processors used across all nodes. Default is 4."\
                    "-m, --mem:       The number of megabytes of RAM reserved for the submission. Default is 8 GB."\
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
                echo "An option must be passed when using $arg. Script has been returned."
                return
            else
                shfile=$option
                NoFileFlag=0
            fi
            ;;
        -N|--node)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Script has been returned."
                return
            else
                node=$option
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
        -j|--jobname)
            i=$(($(get_index arguments $arg) + 1))
            option=${arguments[$i]}
            if [[ $option == -* ]] || [[ -z "$option" ]]; then
                echo "An option must be passed when using $arg. Script has been returned."
                return
            else
                jobname="${option}"
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
    esac
done

if [[ $NoFileFlag -eq 1 ]]; then
    echo "No file was passed. Please include a file after the flag --file or -f. Script has been returned."
    return
fi

echo -e "#!/bin/sh\n" > ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm

echo "#SBATCH --output=$HOME/outfiles/slurm-%j.out" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo -e "#SBATCH --error=$HOME/outfiles/slurm-%j.err\n" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm

echo "#SBATCH --nodes=$node" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo "#SBATCH --ntasks-per-node=$ntasks" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo "#SBATCH --partition=$partition" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo "#SBATCH --mem=${mem}g" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo "#SBATCH --time=${hours}:00:00" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo "#SBATCH --job-name=$jobname" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm
echo -e "#SBATCH --gres=gpu:$gpuname:$gpus\n" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm

echo ". $PWD/$shfile" >> ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm

sbatch ~/easier_slurm_submissions/ActualSlurmSubmitter.slurm

