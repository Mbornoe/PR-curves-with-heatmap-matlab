outputResultsPath = 'outputResults/';
listing = dir(outputResultsPath);
gtFilePath = 'annotations/nightClip5/';

pascalVar = 0.5;
system('python findDirsOfInterest.py');
checkDirectories();
warning('off','MATLAB:DELETE:DirectoryDeletion');
if exist('aucPRC.mat','file') == 2
    load('aucPRC.mat')
    disp('Reading in previous aucPRC.mat');
else
    aucPRC = ones(size(listing,1),5).*-1;
end


for i=1:size(listing,1)
    if listing(i).name(1) ~= ['.','..','.DS_Store']
        if aucPRC(i,1) == -1
            save('aucPRC.mat','aucPRC');
            detectionFilePath = [outputResultsPath,listing(i).name,'/'];
            disp(detectionFilePath);
            digitsInDtRootPathname = regexp(detectionFilePath,['\d+'],'match');
            workingModelDsX = digitsInDtRootPathname(1);
            workingModelDsY= digitsInDtRootPathname(2);
            workingNOctUp = digitsInDtRootPathname(3);
            workingTreeDepth = digitsInDtRootPathname(4);
            
            workingAUCPRC = generateSinglePlot(gtFilePath,detectionFilePath,pascalVar);
            aucPRC(i,1) = str2double(workingModelDsX{1});
            aucPRC(i,2) = str2double(workingModelDsY{1});
            aucPRC(i,3) = str2double(workingNOctUp{1});
            aucPRC(i,4) = str2double(workingTreeDepth{1});
            aucPRC(i,5) = workingAUCPRC;
        end
    end
end
combinedAuc = fopen('combinedAUC.csv','w');
fprintf(combinedAuc, 'ModelDsX;ModelDsY;AUC\n');
for i=1:size(aucPRC,1)
    if (aucPRC(i,1) ~= -1)
        fprintf(combinedAuc, '%.0f;%.0f;%f\n',aucPRC(i,1),aucPRC(i,2),aucPRC(i,5));
    end
end
fclose(combinedAuc);

if ismac
    generateHeatmapString = ['run folowing command in terminal>>> python generateHeatmap.py -in "combinedAUC.csv" -t "AUC Heatmap of Varying Model Dimensions fixed with nOctup ', workingNOctUp{1},' and treeDepth ', workingTreeDepth{1} ,'"' ];
    disp(generateHeatmapString);
end
