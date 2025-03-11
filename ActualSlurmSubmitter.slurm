#!/bin/sh

#SBATCH --output=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.out
#SBATCH --error=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --partition=cpu
#SBATCH --mem=75g
#SBATCH --time=12:00:00
#SBATCH --job-name=uhico.01
#SBATCH --gres=gpu:1080ti:0

. /home/dgillcrist_umassd_edu/opt_exp_des_nD_param_ests/urban_heat_island_5D/RunOnCluster_uhico.01.sh
