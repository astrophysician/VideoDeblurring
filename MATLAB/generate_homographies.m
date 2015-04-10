function [ H ] = generate_homographies(F, Rs, XY)
% This function generates the sequence of homographies using the rotation
% matrices and the calibration matrix generated from focal length and 
% center of camera
% Inputs:
% F - Focal length
% Rs - 3x3xn matrix with a 3x3 rotation matrix in each page
% XY - center of camera (x0,y0)
% Output:
% H: 3x3xn matrix with each 3x3 page as a homography corresponding to the
% rotation matrix

% Generate K
K = [F,0,XY(1);0,F,XY(2);0,0,1];
Kinv = inv(K);

% Initialize H
H = zeros(size(Rs));

% Populate H
for i = 1 : size(Rs,3)
    H(:,:,i) = K*Rs(:,:,i)*Kinv;
end
end