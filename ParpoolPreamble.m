datetime

tic
myCluster = parcluster('local')
% delete(myCluster.Jobs)
max_workers = myCluster.NumWorkers
if max_workers > 1
    p = parpool('Processes',max_workers);
    p.IdleTimeout = 120
    time2start = toc;
    fprintf("\nIt took %f seconds for MATLAB to start the parpool.\n",time2start)
else
    fprintf("\nOnly a single worker was requested. No parpool will be initiated.\n")
end

fprintf('\n%s\n\n',repelem('=',50))

addpath("/home/dgillcrist_umassd_edu/MATLAB_custom_functions/")

apply_font_defaults_from_file
