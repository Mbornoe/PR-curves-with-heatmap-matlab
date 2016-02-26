function [ GTarray ] = fetchGT( gtFilePathname )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    disp('Starting: Fetching Ground Truth');
    tic
    delete('temporaryFiles/gt/*');
    if exist([gtFilePathname,'GTarray.mat'], 'file') == 2
        load([gtFilePathname,'GTarray.mat']);
    else
        gtFilePath = [gtFilePathname,'frameAnnotationsBULB.csv'];
        % Setup worker object wrapper
        fcn = @() fopen( sprintf( 'temporaryFiles/gt/worker_%d.csv', labindex ), 'wt' );
        w = WorkerObjWrapper( fcn, {}, @fclose );
        
        annotation = textread(gtFilePath,'%s', 'delimiter', '\n','whitespace', '');
        %parfor_progress(size(annotation,1)-1);
        parfor i=2:size(annotation,1) % First line is col definitions
            line = strsplit(char(annotation(i,1)),';');
            
            fprintf( w.Value, '%.0f,%.0f,%.0f,%.0f,%.0f\n', str2double(line(8)),str2double(line(3)),str2double(line(4)),str2double(line(5)),str2double(line(6)) );
        end
        
        clear w;
        if ismac
            system('sh mergeWorkers.sh temporaryFiles/gt');
        elseif isunix
            system('sh mergeWorkers.sh temporaryFiles/gt');
        elseif ispc
            system('mergeWorkers.sh temporaryFiles/gt');
        end
        GTarray = csvread('temporaryFiles/gt/merged.csv');
        GTarray = sortrows(GTarray,1);
        save([gtFilePathname,'GTarray.mat'],'GTarray');
    end
    fetchGTend = toc;
    fetchGTstring = sprintf('   Ended: Fetching Ground Truth (%.4f seconds)', fetchGTend);
    disp(fetchGTstring);
    
end

