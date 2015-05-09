function [ H ] = generate_homographies(Rs, K)
% This function generates the sequence of homographies using the rotation
% matrices and the calibration matrix generated from focal length and 
% center of camera
% Inputs:
% Rs - 3x3xn matrix with a 3x3 rotation matrix in each page
% K - calibration matrix of camera
% Output:
% H: 3x3xn matrix with each 3x3 page as a homography corresponding to the
% rotation matrix

% Initialize H
H = zeros(size(Rs));

% Populate H
for i = 1 : size(Rs,3)
    H(:,:,i) = K*Rs(:,:,i)/K;
end
end