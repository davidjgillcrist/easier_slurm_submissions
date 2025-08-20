#!/bin/sh

#SBATCH --output=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.out
#SBATCH --error=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --partition=cpu
#SBATCH --mem=72g
#SBATCH --time=4:00:00
#SBATCH --job-name=PERM0Dbeta.GrdEvls.001
#SBATCH --gres=gpu:1080ti:0

. /home/dgillcrist_umassd_edu/opt_exp_des_nD_param_ests/toy_problem_01/RunOnCluster_PERM0Dbeta.GrdEvls.001.sh
