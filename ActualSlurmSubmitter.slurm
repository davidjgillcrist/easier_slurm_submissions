#!/bin/bash

#SBATCH --output=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.out
#SBATCH --error=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=cpu
#SBATCH --mem=36g
#SBATCH --time=12:00:00
#SBATCH --job-name=plotTest.001
#SBATCH --gres=gpu:1080ti:0

. /home/dgillcrist_umassd_edu/opt_exp_des_nD_param_ests/rvr2DsrcANDx/RunOnCluster_plotTest.001.sh
