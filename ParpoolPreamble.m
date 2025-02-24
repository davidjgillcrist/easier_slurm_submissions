datetime

tic
myCluster = parcluster('local')
max_workers = myCluster.NumWorkers

p = parpool('Processes',max_workers);
p.IdleTimeout = 120
time2start = toc;
fprintf("\nIt took %f seconds for MATLAB to start the parpool.\n",time2start)

addpath("/home/dgillcrist_umassd_edu/MATLAB_custom_functions/")
