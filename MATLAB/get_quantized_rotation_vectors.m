function [quant_thetas, weights] =...
    get_quantized_rotation_vectors(w, non_zeros, grid_origin, theta_cell)

% Inputs:
% - w:              3-dimensional matrix that constitutes the non-uniform
%                   rotational blur kernel for the examined frame
% - non_zeros:      3xp matrix containing the grid indices of the non-zero
%                   elements of the blur kernel
% - grid_origin:    3x1 vector containing the theta space coordinates of
%                   the (1, 1, 1) cell's outer vertex
% - theta_cell:     3x1 vector containing the size of the grid cells in the
%                   theta space along each of the 3 dimensions

% Output:
% - quant_thetas:   3xp matrix with each column representing a quantized
%                   "angle-axis" rotation of the camera wrt the 1st
%                   orientation
% - weights:        1xp vector containing the corresponding kernel weights
%                   for the set of quantized rotations

p = size(non_zeros, 2);

theta_cell_rep = repmat(theta_cell, 1, p);

% Add the offset corresponding to the origin of the grid and center the
% rotations in the middle of the corresponding grid cell
quant_thetas =...
    non_zeros.*theta_cell_rep + repmat(grid_origin, 1, p) - theta_cell_rep/2;

% Retrieve the set of non-zero kernel weights by indexing 3D kernel w
% properly
weights = w(sub2ind(size(w), non_zeros(1, :), non_zeros(2, :), non_zeros(3, :)));

end

