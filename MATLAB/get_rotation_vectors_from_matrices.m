function thetas = get_rotation_vectors_from_matrices(Rs)

% Input:
% - Rs:     - 3x3xn matrix with a 3x3 rotation matrix in each page

% Output:
% - thetas: - 3xn matrix with a 3x1 vector representing "angle-axis"
%             rotation in each column corresponding to the respective 
%             rotation matrix

n = size(Rs, 3);

% Initialize matrix with thetas in 3x3 cross-product form
thetas_x = zeros(size(Rs));

% Loop over all rotation matrices and compute theta_x as matrix logarithm
for i=1:n
    thetas_x(:, :, i) = logm(Rs(:, :, i));
end

% Construct thetas by selecting the appropriate elements of thetas_x
thetas(1, :) = thetas_x(3, 2, :);
thetas(2, :) = thetas_x(1, 3, :);
thetas(3, :) = thetas_x(2, 1, :);


end

