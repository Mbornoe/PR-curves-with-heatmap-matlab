function [aucPRC] = generateSinglePlot(gtFilePathname,dtRootFilePath,pascalVar)
%clc;
%clear all;

%gtFilePathname = 'annotations/nightSeq1/';
%dtRootFilePath = 'outputResults/modelDS[20,17]-nOctUp[2]-treeDepth[4]/';
%pascalVar = 0.5;


dtFilePathname = [dtRootFilePath,'workerOut/'];

digitsInDtRootPathname = regexp(dtRootFilePath,['\d+'],'match');
workingModelDsX = digitsInDtRootPathname(1);
workingModelDsY= digitsInDtRootPathname(2);
workingNOctUp = digitsInDtRootPathname(3);
workingTreeDepth = digitsInDtRootPathname(4);



tpNaming = 1;
fpNaming = 0;
fnNaming = 'NaN';
gtFilePathname
gtArray = fetchGT(gtFilePathname);
dtArray = fetchDT(dtFilePathname);

tic
disp('Starting: Frame examination');
numOfFrames = max(gtArray(:,1));

% Setup worker object wrapper
delete('temporaryFiles/*');
delete('temporaryFiles/results/tp/*');
delete('temporaryFiles/results/fp/*');
delete('temporaryFiles/results/fn/*');

fcnTp = @() fopen( sprintf( 'temporaryFiles/results/tp/worker_%d.csv', labindex ), 'wt' );
workerTP = WorkerObjWrapper( fcnTp, {}, @fclose );

fcnFp = @() fopen( sprintf( 'temporaryFiles/results/fp/worker_%d.csv', labindex ), 'wt' );
workerFP = WorkerObjWrapper( fcnFp, {}, @fclose );

fcnFn = @() fopen( sprintf( 'temporaryFiles/results/fn/worker_%d.csv', labindex ), 'wt' );
workerFN = WorkerObjWrapper( fcnFn, {}, @fclose );

parfor currentFrame=0:numOfFrames
    locateAnnosOfInterest = find(gtArray(:,1) == currentFrame);
    locateDetectsOfInterest = find(dtArray(:,1) == currentFrame);
    
    copyOfAnnos = ones(size(locateAnnosOfInterest,1),(size(locateAnnosOfInterest,2)+2)).*(-1);
    copyOfDetections= ones(size(locateDetectsOfInterest,1),(size(locateDetectsOfInterest,2)+1)).*(-1);
    
    for k=1:size(locateDetectsOfInterest,1)
            curDT = dtArray(locateDetectsOfInterest(k),2:6);
        for i=1:size(locateAnnosOfInterest,1)
            curGT = gtArray(locateAnnosOfInterest(i),2:5);
            pascalCalculation = calcPascal(curDT(1:4),curGT,pascalVar);

            if pascalCalculation == true
                if copyOfAnnos(i,2) < curDT(5)
                    copyOfAnnos(i,1) = i;
                    copyOfAnnos(i,2) = curDT(5);
                    copyOfAnnos(i,3) = k;
                    
                    curDTMaxScore = curDT(5);
                    curDTMaxNo = k;
                    curGTMaxNo = i;
                end
            end
        end
    end
    
    for j=1:size(copyOfAnnos,1)
        if copyOfAnnos(j,3) ~= -1
            fprintf( workerTP.Value, '%f,%.0f,%.0f,%.0f\n', dtArray(locateDetectsOfInterest(copyOfAnnos(j,3)),6),tpNaming, dtArray(locateDetectsOfInterest(copyOfAnnos(j,3)),1),locateDetectsOfInterest(copyOfAnnos(j,3)));
            %locateAnnosOfInterest(j,:) = [];
            %locateDetectsOfInterest(copyOfAnnos(j,3)) == [];
            %dtArray(locateDetectsOfInterest(copyOfAnnos(j,3)),:) = [];
        else
            fprintf( workerFN.Value, '%.0f,%.0f,%.0f,%.0f\n', gtArray(locateAnnosOfInterest(j),1),gtArray(locateAnnosOfInterest(j),2), gtArray(locateAnnosOfInterest(j),3),gtArray(locateAnnosOfInterest(j),4));    
        end
    end

    for j=1:size(locateDetectsOfInterest,1)
        if j ~= copyOfAnnos(:,3);
            fprintf( workerFP.Value, '%f,%.0f,%.0f,%.0f\n', dtArray(locateDetectsOfInterest(j),6),fpNaming, dtArray(locateDetectsOfInterest(j),1),locateDetectsOfInterest(j));
        end
    end
   
    if (currentFrame == numOfFrames)
        %Find all additional detections beyond the annotated and mark them
        %as false positives
        detectionsBeyond = find(dtArray(:,1) > numOfFrames);
        for m=1:size(detectionsBeyond,1)
            fprintf( workerFP.Value, '%f,%.0f,%.0f,%.0f\n', dtArray(detectionsBeyond(m),6),fpNaming, dtArray(detectionsBeyond(m),1),detectionsBeyond(m));
        end
    end
end

clear workerTP workerFP workerFN;
if ismac
    system('sh mergeWorkers.sh temporaryFiles/results/fp');
    system('sh mergeWorkers.sh temporaryFiles/results/tp');
    system('sh mergeWorkers.sh temporaryFiles/results/fn');
elseif isunix
    system('sh mergeWorkers.sh temporaryFiles/results/fp');
    system('sh mergeWorkers.sh temporaryFiles/results/tp');
    system('sh mergeWorkers.sh temporaryFiles/results/fn');
elseif ispc
    system('mergeWorkers.sh temporaryFiles/results/fp');
    system('mergeWorkers.sh temporaryFiles/results/tp');
    system('mergeWorkers.sh temporaryFiles/results/fn');
end
totalTPfile = csvread('temporaryFiles/results/tp/merged.csv');
totalNumberOfFn = csvread('temporaryFiles/results/fn/merged.csv');
allFnFile = fopen('temporaryFiles/results/fn/allFn.csv','a');
for i=1:size(totalNumberOfFn,1)
    fprintf(allFnFile,'%s;%.0f\n',fnNaming,tpNaming);
end
fclose(allFnFile);

movefile('temporaryFiles/results/fn/allFn.csv','temporaryFiles/allFn.csv');
movefile('temporaryFiles/results/fp/merged.csv','temporaryFiles/allFp.csv');
movefile('temporaryFiles/results/tp/merged.csv','temporaryFiles/allTp.csv');

aucPRC = generatePRC('temporaryFiles/allTp.csv', 'temporaryFiles/allFp.csv','temporaryFiles/allFn.csv', size(totalTPfile,1), (size(dtArray,1)-size(totalTPfile,1)) ,size(totalNumberOfFn,1),workingModelDsX,workingModelDsY,workingNOctUp,workingTreeDepth );
movefile('PRC-plot.png',[dtRootFilePath,'PRC-plot.png'])
movefile('resultSummary.txt',[dtRootFilePath,'resultSummary.txt'])

currentFrameExaminationTime = toc;
currentFrameExaminationTimestring = sprintf('   Ended: Frame examination (%.4f seconds)', currentFrameExaminationTime);
disp(currentFrameExaminationTimestring);

end
