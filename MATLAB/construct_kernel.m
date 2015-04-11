function [w, non_zeros, grid_origin] = construct_kernel(thetas, theta_cell)

% Inputs:
% - thetas:     3xn matrix with each column representing an "angle-axis"
%               rotation of the camera wrt the 1st orientation
% - theta_cell: 3x1 vector containing the size of the grid cells in the
%               theta space along each of the 3 dimensions

% Output:
% - w:              3-dimensional matrix that constitutes the non-uniform
%                   rotational blur kernel for the examined frame
% - non_zeros:      3xp matrix containing the grid indices of the non-zero
%                   elements of the blur kernel (p <= n)
% - grid_origin:    3x1 vector containing the theta space coordinates of
%                   the (1, 1, 1) cell's outer vertex

% First, determine the dimensions of w by using the extremal values of
% rotation at each dimension

thetas_min = min(thetas, [], 2);
thetas_max = max(thetas, [], 2);
theta_range = thetas_max - thetas_min;

% Divide the range by the cell size to compute the number of cells
intervals = theta_range./theta_cell;

% If cells fit exactly to the range, add one extra cell to avoid placing
% any sample on the border of the grid
num_cells = floor(intervals) + 1;

% Store the origin of the grid
grid_origin = thetas_min - ((num_cells-intervals)/2).*theta_cell;

% Initialize the kernel with zeros
w = zeros(num_cells');

n = size(thetas, 2);
weight = 1/n;

% Iterate over all rotation samples and accumulate using binning and equal
% weights for each sample
for i=1:n
    % Discretizing the rotation sample
    grid_pos = ceil((thetas(:, i) - grid_origin)./theta_cell);
    
    % Accumulating the weight at the appropriate bin
    w(grid_pos(1), grid_pos(2), grid_pos(3)) =...
        w(grid_pos(1), grid_pos(2), grid_pos(3)) + weight;
end

% Determine grid locations of non-zero kernel elements
[I, J, K] = ind2sub(size(w), find(w));
non_zeros = [I'; J'; K'];

end

