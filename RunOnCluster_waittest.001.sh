#!/bin/bash
module load matlab/r2025a
myCommand=nothing.m
mv ./${myCommand%??}1758759196073527345.m ${myCommand%??}${SLURM_JOBID}.m
sed -i "0,/totalchunks =.*/s//totalchunks = 1;/" ${myCommand%??}${SLURM_JOBID}.m
sed -i "0,/ChunkRun =.*/s//ChunkRun = 001;/" ${myCommand%??}${SLURM_JOBID}.m
sed -i -e "0r ParpoolPreamble.m" ${myCommand%??}${SLURM_JOBID}.m
myOutfile="MATLAB_outfile_001_waittest_${SLURM_JOBID}.txt"
if [ ! -d ./matlab_outfiles/ ]; then
	mkdir matlab_outfiles
fi
matlab -batch "${myCommand%??}${SLURM_JOBID}" > ./matlab_outfiles/$myOutfile
