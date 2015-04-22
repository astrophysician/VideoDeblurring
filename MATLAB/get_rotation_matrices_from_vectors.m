function Rs = get_rotation_matrices_from_vectors(thetas)

% Input:
% - thetas: - 3xn matrix with a 3x1 vector representing "angle-axis"
%             rotation in each column

% Output:
% - Rs:     - 3x3xn matrix with a 3x3 rotation matrix in each page
%             corresponding to the respective rotation vector

n = size(thetas, 2);

% Initialize matrices
thetas_x = zeros(3, 3, n);
Rs = zeros(3, 3, n);

% Loop over all rotation vectors, compute thetas_x as cross matrices and
% Rs by taking the exponentials of the pages of thetas_x
for i=1:n
    thetas_x(:, :, i) = cross_matrix(thetas(:, i));
    Rs(:, :, i) = expm(thetas_x(:, :, i));
end


end

