function [ DTarray ] = fetchDT( dtFilePathname )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    disp('Starting: Fetching detections');
    tic
    delete('temporaryFiles/dt/*');
    
    if exist([dtFilePathname,'DTarray.mat'], 'file') == 2
        load([dtFilePathname,'DTarray.mat']);
    else
        dtFilePath = [dtFilePathname,'merged.csv'];
        
        % Setup worker object wrapper
        fcn = @() fopen( sprintf( 'temporaryFiles/dt/worker_%d.csv', labindex ), 'wt' );
        w = WorkerObjWrapper( fcn, {}, @fclose );
        
        annotation = textread(dtFilePath,'%s', 'delimiter', '\n','whitespace', '');
        %parfor_progress(size(annotation,1)-1);
        parfor i=1:size(annotation,1) % First line is col definitions
            line = strsplit(char(annotation(i,1)),';');
            findFrameNumber = strsplit(char(line(1)),{'--','.png'});
            fprintf( w.Value, '%.0f,%.0f,%.0f,%.0f,%.0f,%f\n', str2double(findFrameNumber(2)),str2double(line(2)),str2double(line(3)),str2double(line(4)),str2double(line(5)),str2double(line(6)));
        end
        clear w;
        if ismac
            system('sh mergeWorkers.sh temporaryFiles/dt');
        elseif isunix
            system('sh mergeWorkers.sh temporaryFiles/dt');
        elseif ispc
            system('mergeWorkers.sh temporaryFiles/dt');
        end
        DTarray = csvread('temporaryFiles/dt/merged.csv');
        DTarray = sortrows(DTarray,1);
        save([dtFilePathname,'DTarray.mat'],'DTarray');
     end
        fetchGTend = toc;
        fetchGTstring = sprintf('   Ended: Fetching detections (%.4f seconds)', fetchGTend);
        disp(fetchGTstring);
    
    
end

