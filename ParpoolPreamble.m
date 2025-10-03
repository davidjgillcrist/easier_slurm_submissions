datetime

tic
myCluster = parcluster('local')

max_workers = myCluster.NumWorkers
if max_workers > 1
    tryTime = 60; % In seconds
    for k=1:tryTime
        try
            p = parpool('Processes',max_workers); % <=== Attempt to start up the parpool
            break                    % <================ Avoids the error message if we can load it
        catch ME
            lastErr = ME;
            pause(1); % Wait a single second
        end
        error("%s",lastErr.message)
    end
    p.IdleTimeout = 120
    time2start = toc;
    fprintf("\nIt took %f seconds for MATLAB to start the parpool.\n",time2start)
else
    fprintf("\nOnly a single worker was requested. No parpool will be initiated.\n")
end

fprintf('\n%s\n\n',repelem('=',49))

addpath("/home/dgillcrist_umassd_edu/MATLAB_custom_functions/")

apply_font_defaults_from_file
