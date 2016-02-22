function AUCpr = generatePRC( tpPath, fpPath, fnPath, tpStats, fpStats, fnStats,modelDsX,modelDsY,nOctUp,treeDepth )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
newTarget = 0;
newScores = 0;

tpFile = textread(tpPath,'%s', 'delimiter', '\n','whitespace', '');
fpFile = textread(fpPath,'%s', 'delimiter', '\n','whitespace', '');
fnFile = textread(fnPath,'%s', 'delimiter', '\n','whitespace', '');

fcnTarget = @() fopen( sprintf( 'temporaryFiles/results/target/worker_%d.csv', labindex ), 'wt' );
workerTarget = WorkerObjWrapper( fcnTarget, {}, @fclose );

fcnScores = @() fopen( sprintf( 'temporaryFiles/results/scores/worker_%d.csv', labindex ), 'wt' );
workerScores = WorkerObjWrapper( fcnScores, {}, @fclose );

parfor i=1:size(tpFile,1)
    line = strsplit(char(tpFile(i,1)),';');
    %line = strsplit(tpFile,';')
    fprintf( workerTarget.Value, '%.0f\n', 0);
    fprintf( workerScores.Value, '%f\n', str2double(line(1)));
    %newTarget(size(newTarget)+1,1) = 0;
    %newScores(size(newScores)+1,1) = str2double(line(1));
end

parfor i=1:size(fpFile,1)
    line = strsplit(char(fpFile(i,1)),';');
    fprintf( workerTarget.Value, '%.0f\n', 1);
    fprintf( workerScores.Value, '%f\n', str2double(line(1)));
    %newTarget(size(newTarget)+1,1) = 1;
    %newScores(size(newScores)+1,1) = str2double(line(1));
end

parfor i=1:size(fnFile,1)
    fprintf( workerTarget.Value, '%.0f\n', 0);
    fprintf( workerScores.Value, '%s\n', 'NaN');
    %newTarget(size(newTarget)+1,1) = 0;
    %newScores(size(newScores)+1,1) = NaN;
end
clear workerTarget workerScores;
if ismac
    system('sh mergeWorkers.sh temporaryFiles/results/target/');
    system('sh mergeWorkers.sh temporaryFiles/results/scores/');
elseif isunix
    system('sh mergeWorkers.sh temporaryFiles/results/target/');
    system('sh mergeWorkers.sh temporaryFiles/results/scores/');
elseif ispc
    system('mergeWorkers.sh temporaryFiles/results/target/');
    system('mergeWorkers.sh temporaryFiles/results/scores/');
end

movefile('temporaryFiles/results/target/merged.csv','temporaryFiles/target.csv');

movefile('temporaryFiles/results/scores/merged.csv','temporaryFiles/scores.csv');

newTarget = csvread('temporaryFiles/target.csv');

newScores = csvread('temporaryFiles/scores.csv');

% Do the plot
plotX = 100;
plotY = 100;
plotWidth = 1280;
plotHeight = 480;
pixelPerInch = 50;

%figure;
set(gcf,'Color','white','Position',[plotX plotY plotWidth plotHeight],'PaperUnits', 'inches', 'PaperPosition', [0 0 plotWidth plotHeight]/pixelPerInch);
[Xpr,Ypr,Tpr,AUCpr] = perfcurve(newTarget, newScores, 0, 'xCrit', 'reca', 'yCrit', 'prec','ProcessNaN','addtofalse');

Xpr(size(Xpr)+1,1) = Xpr(size(Xpr),1);
Ypr(size(Ypr)+1,1) = 0;

plot(Xpr,Ypr,'LineWidth',2)
set(gca,'FontSize',40,'fontWeight','bold')

set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold')
legend(['AFC(',modelDsX{1},',', modelDsY{1},')-',nOctUp{1}, '-', treeDepth{1},' (AUC: ', num2str(AUCpr), ')']);
%legend( sprintf('lambda = %.0f', modelDsX{1} )  );

%legend(['AFC[(',modelDsX{1},',', modelDsY{1},')-',num2str(nOctUp{1}), '-', num2str(treeDepth{1}),'] (AUC: ', num2str(AUCpr{1}), ')']);
axis([0 1 0 1])
xlabel('Recall'); ylabel('Precision')
title(['Precision-Recall curve'])

saveas(gcf, 'PRC-plot.png');
close all;

resultSummary = fopen('resultSummary.txt','w');
%   fprintf(resultSummary, ['The results summary for ModelDS[',num2str(modelDsX),',',num2str(modelDsY),'] with nOctup: ', num2str(nOctUp), ' and treeDepth: ',num2str(treeDepth),'\n']);
fprintf(resultSummary,['AUC: ', num2str(AUCpr),'\n']);
fprintf(resultSummary,['TP: ', num2str(tpStats),'\n']);
fprintf(resultSummary,['FP: ', num2str(fpStats) ,'\n']);
fprintf(resultSummary,['FN: ', num2str(fnStats),'\n']);

fclose(resultSummary);


end

