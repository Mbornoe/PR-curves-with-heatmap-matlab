function [ Xpr,Ypr,Tpr,AUCpr,newTotalTP,newTotalFP,newTotalFN ] = plotPRCurve( gtFilePath, dtFilePath )
    disp('Starting: Fetch Ground Truth');
    tic
    %annotation = textread('nightClip1/frameAnnotationsBOX.csv','%s', 'delimiter', '\n','whitespace', '');
    annotation = textread(gtFilePath,'%s', 'delimiter', '\n','whitespace', '');
    GTarray(size(annotation,1)-1,5)=0;
    for i=2:size(annotation,1)
        line = strsplit(char(annotation(i,1)),';');
        for j=1:size(line,2)
            if j == 1
                % Convert the nightTraining/nightClip1--00473.png to only 00473
                convertedToString = sprintf('%s',line{1,j});
                [allLineInfo,lineMatches] = strsplit(convertedToString,{'--','.png'},'CollapseDelimiters',true);
                GTarray(i-1,j) = str2double(allLineInfo(1,2));
            elseif (j<7 && j>2)
                %j
                % We need to adjust i as the first line in GT contain syntax
                % We need to adjust j as the second entry in GT contain type
                GTarray(i-1,j-1) = str2double(line(1,j));
                %disp(line(1,:));

            end
        end
        %disp(GTarray(i-1,5));
        if GTarray(i-1,4) == 0
            disp('The score is NULL');
        end
    end
    fetchGTend = toc;

    fetchGTstring = sprintf('Fetching Ground Truth Timing: %.4f seconds', fetchGTend);
    disp(fetchGTstring);

    %% Fetch Detection Results
    disp('Starting: Fetch Detection Results');
    tic 
    %detection = textread('nightClip1/results/mergedSorted.csv','%s', 'delimiter', '\n','whitespace', '');
    detection = textread(dtFilePath,'%s', 'delimiter', '\n','whitespace', '');
    DTarray(size(detection),6) = 0;
    for i = 1:size(detection,1)
        line = (strsplit(char(detection(i,1)),';'));
        for j=1:size(line,2)
            if j==1
                % Convert the nightTraining/nightClip1--00473.png to only 00473
                convertedToString = sprintf('%s',line{1,j});
                [allLineInfo,lineMatches] = strsplit(convertedToString,{'--','.png'},'CollapseDelimiters',true);
                DTarray(i,j) = str2double(allLineInfo(2));
            else
                DTarray(i,j) = str2double(line(1,j));
            end
        end
    end

    fetchDTend = toc;
    fetchDTstring = sprintf('Fetching Detection Results Timing: %.4f seconds', fetchDTend);
    disp(fetchDTstring);

    Find TP
    tic
    totalFrames = 4865;
    thePascalVar = 0.5;

    newTarget = [];
    newScores = [];
    totalTP=0;
    totalFP=0;
    totalFN=0;

    newTotalTP=0;
    newTotalFP=0;
    newTotalFN=0;

    for frameNumber=0:totalFrames-1
        gtBB = [];
        dtBB = [];
        gtBBIterator=1;
        dtBool = false;
        gtBool = false;
        for j=1:size(DTarray,1)
            detectionFrameNumber = DTarray(j,1);
            outDtString = sprintf('Framenumber: %d -- detectionFrameNumber: %d',frameNumber,detectionFrameNumber);
            disp(outDtString);
            if detectionFrameNumber == frameNumber
                dtBB(gtBBIterator,1) = DTarray(j,2); 
                dtBB(gtBBIterator,2) = DTarray(j,3);
                dtBB(gtBBIterator,3) = DTarray(j,4)-DTarray(j,2);
                dtBB(gtBBIterator,4) = DTarray(j,5)-DTarray(j,3);
                dtBB(gtBBIterator,5) = DTarray(j,6);
                gtBBIterator = gtBBIterator + 1;
                dtBool = true;
            end
        end
        gtBBIterator=1;
        for j=1:size(GTarray,1)
            groundTruthFrameNumber = GTarray(j,1);
            if groundTruthFrameNumber == frameNumber
                gtBB(gtBBIterator,1) = GTarray(j,2); 
                gtBB(gtBBIterator,2) = GTarray(j,3);
                gtBB(gtBBIterator,3) = GTarray(j,4)-GTarray(j,2);
                gtBB(gtBBIterator,4) = GTarray(j,5)-GTarray(j,3);
                gtBBIterator = gtBBIterator + 1;

                gtBool = true;
            end
        end
        newGTBB = gtBB;
        newBbs = dtBB;
        newTruePositives = 0;
        detectedTPs = [];
        notFoundGTBB = [];

        for p=1:size(newGTBB,1)
            if p==1
                notFoundGTBB = newGTBB;
            end
            tpFOUND = 0;
            for l = 1 : (size(newBbs,1))
                newIntersectBB  = bbApply('intersect',newBbs(l,:),newGTBB(p,:)); 
                newUnionBB      = bbApply('union',newBbs(l,:),newGTBB(p,:));

                newIntersectArea = bbApply('area',newIntersectBB);
                newUnionArea = bbApply('area',newUnionBB);

                newPascalCrit = newIntersectArea/(newUnionArea-newIntersectArea);            
                if newPascalCrit >= thePascalVar && tpFOUND == 0
                    stringTP = sprintf('%i,%f,%f,%f,%f,%f\n',frameNumber,newBbs(l,1),newBbs(l,2),newBbs(l,3),newBbs(l,4),newBbs(l,5));
                    fprintf(fileTP,stringTP);
                    fprintf(fileALL,'%i,TP,%f,%f,%f,%f,%f\n',frameNumber,newBbs(l,1),newBbs(l,2),newBbs(l,3),newBbs(l,4),newBbs(l,5));
                    disp(stringTP);
                    tpFOUND = l;
                    newTarget(size(newTarget)+1,1) = 0;
                    newScores(size(newScores)+1,1) = newBbs(l,5);
                end
            end
            if tpFOUND ~= 0
                newBbs(tpFOUND,:) = []; % Remove TP from newBbs array.
                detectedTPs(size(detectedTPs,1)+1,1) = p;
                newTruePositives = newTruePositives + 1;
            end
        end
        for l = 1 : (size(newBbs,1))
            stringFP = sprintf('%i,%f,%f,%f,%f,%f\n',frameNumber, newBbs(l,1),newBbs(l,2),newBbs(l,3),newBbs(l,4),newBbs(l,5));
            fprintf(fileFP,stringFP);
            fprintf(fileALL,'%i,FP,%f,%f,%f,%f,%f\n',frameNumber, newBbs(l,1),newBbs(l,2),newBbs(l,3),newBbs(l,4),newBbs(l,5));
            newTarget(size(newTarget)+1,1) = 1;
            newScores(size(newScores)+1,1) = newBbs(l,5);
            disp(stringFP);
        end
        DetetectedTP contain the information of which cell position in the
        original newGTBB array (now: notFoundGTBB). We remove the detected TP
        from notFoundGTBB, so we are left with the FN.
        uniqueDetectedTPS = unique(detectedTPs);
        if size(detectedTPs,1) == size(notFoundGTBB,1)
            notFoundGTBB = [];
        else
            for z = size(unique(detectedTPs),1): -1 : 1
                notFoundGTBB(detectedTPs(z,1),:) = [];
            end
        end
        for l = 1 : (size(notFoundGTBB,1))
            stringFN = sprintf('%i,%f,%f,%f,%f\n',frameNumber,notFoundGTBB(l,1),notFoundGTBB(l,2),notFoundGTBB(l,3),notFoundGTBB(l,4));
            fprintf(fileFN,stringFN);
            fprintf(fileALL,'%i,FN,%f,%f,%f,%f\n',frameNumber,notFoundGTBB(l,1),notFoundGTBB(l,2),notFoundGTBB(l,3),notFoundGTBB(l,4));
            newTarget(size(newTarget)+1,1) = 0;
            newScores(size(newScores)+1,1) = NaN;
            disp(stringFN);
        end
        newTotalTP = newTotalTP + newTruePositives;
        newTotalFP = newTotalFP + size(newBbs,1);
        newTotalFN = newTotalFN + (size(newGTBB,1)-newTruePositives);
        totalOutString = sprintf('TP: %i FP: %i FN: %i',newTruePositives,size(newBbs,1),size(newGTBB,1)-newTruePositives);
        disp(totalOutString);

    end    
    [Xpr,Ypr,Tpr,AUCpr] = perfcurve(newTarget, newScores, 0, 'xCrit', 'reca', 'yCrit', 'prec','ProcessNaN','addtofalse');

end

