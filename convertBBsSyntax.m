function [ convertedBB ] = convertBBsSyntax( BB )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
frameWidth = BB(3)-BB(1);
frameHeight = BB(4)-BB(2);

%frameWidth = BB(3);
%frameHeight = BB(4);

convertedBB = [BB(1), BB(2), frameWidth, frameHeight];
end

