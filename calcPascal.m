function [ pascalCritHit ] = calcPascal( curDT, curGT,pascalVar )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Convert curDT and curGT to bbapply syntax:  [x y w h]
convertedCurDT = convertBBsSyntax(curDT);
convertedCurGT = convertBBsSyntax(curGT);

intersectBB = bbApply('intersect',convertedCurDT,convertedCurGT);
unionBB = bbApply('union',convertedCurDT,convertedCurGT);

intersectArea = bbApply('area',intersectBB);
unionArea = bbApply('area',unionBB);

pascalCritVar = intersectArea/(unionArea-intersectArea);
%pascalCritVar = intersectArea/(unionArea);

if pascalCritVar >= pascalVar
    pascalCritHit = true;
else
    pascalCritHit = false;
end

end

