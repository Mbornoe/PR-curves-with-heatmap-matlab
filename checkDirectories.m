function checkDirectories( )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if exist('annotations','dir') ~= 7
    mkdir('annotations');
end
if exist('temporaryFiles','dir') ~= 7
    mkdir('outputResults');
end

if exist('temporaryFiles','dir') ~= 7
    mkdir('temporaryFiles');
end
if exist('temporaryFiles/dt','dir') ~= 7
    mkdir('temporaryFiles/dt');
end
if exist('temporaryFiles/gt','dir') ~= 7
    mkdir('temporaryFiles/gt');
end
if exist('temporaryFiles/results','dir') ~= 7
    mkdir('temporaryFiles/results');
end
if exist('temporaryFiles/results/fn','dir') ~= 7
    mkdir('temporaryFiles/results/fn');
end
if exist('temporaryFiles/results/fp','dir') ~= 7
    mkdir('temporaryFiles/results/fp');
end
if exist('temporaryFiles/results/scores','dir') ~= 7
    mkdir('temporaryFiles/results/scores');
end
if exist('temporaryFiles/results/target','dir') ~= 7
    mkdir('temporaryFiles/results/target');
end
if exist('temporaryFiles/results/tp','dir') ~= 7
    mkdir('temporaryFiles/results/tp');
end

end

