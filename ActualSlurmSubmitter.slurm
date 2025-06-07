#!/bin/sh

#SBATCH --output=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.out
#SBATCH --error=/home/dgillcrist_umassd_edu/outfiles/slurm-%j.err

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --partition=cpu
#SBATCH --mem=75g
#SBATCH --time=24:00:00
#SBATCH --job-name=log_nIso_agg4null.351
#SBATCH --gres=gpu:1080ti:0

. /home/dgillcrist_umassd_edu/opt_exp_des_nD_param_ests/river_source_and_intensity_estimation_3D/RunOnCluster_log_nIso_agg4null.351.sh
