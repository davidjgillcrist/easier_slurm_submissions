#!/bin/sh

#SBATCH --output=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.out
#SBATCH --error=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --partition=cpu
#SBATCH --mem=16g
#SBATCH --time=2:00:00
#SBATCH --job-name=rvr2Dsrc+xm1.null.coeffs.001
#SBATCH --gres=gpu:1080ti:0

. /home/dgillcrist_umassd_edu/opt_exp_des_nD_param_ests/rvr2DsrcANDx/RunOnCluster_rvr2Dsrc+xm1.null.coeffs.001.sh
