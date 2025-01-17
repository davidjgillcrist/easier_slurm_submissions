# Easier Slurm Submissions

## **DISCLAIMER**: The following instructions assumes that your slurm submission system is configured the same way mine is. I do not claim to be any expert in slurm. I just hated having to write individual submission scripts for each job I wanted to run. You may need to "play around" with this script and how it works submitting to your system.

This is a script that allows for a quick-and-easy way to submit jobs that use the job scheduling system called Slurm. All the specifications of your job (e.g. the number of cpus requested, the amount of time needed, etc) are submitted with a preceding "tag" that writes these values into an actual Slurm submission script before that is then submitted via Slurm. 

Download the script `Slurms_MacKenzie.sh` into your home directory, e.g. `~ `. It's also necessary to paste the contents of the file `WimmyWamWamWozzle` into your `.bashrc` file. Make sure to reload you `.bashrc` file again otherwise your system won't recognize the command.

Once both of these things are accomplished, you can run the following from any directory. **NOTE:** 
```diff
- Regarding the following code lines, please do not put astericks around your values/names that follow the tags.
- Those are just there for emphasis. Only write the name/value as it is.
```
```
WimmyWamWamWozzle --file *name of script* --node *num requested nodes* --ntasks *num processors across all nodes* --mem *amount of RAM in MB* --time *num reserved hours* --gpus *num requested GPUs* --gpuname *name of type of GPU requested* --partition *name of partition used* --jobname *name of job being run*
```

This can be also be run using the shortened tags

```
WimmyWamWamWozzle -f *name of script*  -N *num requested nodes* -n *num processors across all nodes* -m *amount of RAM in MB* -t *num reserved hours* -g *num requested GPUs* -G *name of type of GPU requested* -p *name of partition used* -j *name of job being run*
```

The order of the tags doesn't matter, so long as the correct value/name follows it. For instance the above command can equivalently be written as

```
WimmyWamWamWozzle -N *num requested nodes* -f *name of script* -p *name of partition used* -j *name of job being run* -g *num requested GPUs* -t *num reserved hours* -m *amount of RAM in MB* -n *num processors across all nodes* -G *name of type of GPU requested*
```

These values are then written into a file called `ActualSlurmSubmitter.slurm` in the following way:
```
#!/bin/sh\n"

#SBATCH --output=*homedir*/outfiles/slurm-%j.out
#SBATCH --error=*homedir*/outfiles/slurm-%j.err

#SBATCH --nodes=*num requested nodes*
#SBATCH --ntasks-per-node=*num of processors across all nodes*
#SBATCH --partition=*name of partition used* 
#SBATCH --mem=*amount of RAM in MB*
#SBATCH --time=${*num of reserved hours*}:00:00
#SBATCH --job-name=*name of job being run*
#SBATCH --gres=gpu:*name of type of gpu requested*:*num of requested GPUs*

. $PWD/$file
```
The following is then run from your home directory: `sbatch ~/ActualSlurmSubmitter.slurm`

At any point you can also run `WimmyWamWamWozzle -h` and it will print the following:
```
-f, --file:      Pass a file to run via Slurm. Not optional must be passed.
-N, --node:      The number of nodes to run on. Default is 1.
-n, --ntasks:    The number of processors used across all nodes. Default is 4.
-m, --mem:       The number of megabytes of RAM reserved for the submission. Default is 8192 MB (8 GB).
-t, --time:      The number of hours reservered for the submission. Default is 4 hours.
-g, --gpus:      The number of GPUs to reserve. Default is 0.
-G, --gpuname:   The name of the type of GPU being requested. Default is M2050.
-p, --partition: The name of the partition that the job is being sent to. Default is cpu.
-j, --jobname:   The name of the job as shown on squeue. Default is job-%j.
```

### If you're wondering what the significance of the names Slurms MacKenzie and Wimmy Wam Wam Wozzle is, then I would kindly ask you to watch the show Futurama. :)

![slurms_mackenzie](https://github.com/user-attachments/assets/c5e54cf0-4267-47da-8917-701a49067882)



