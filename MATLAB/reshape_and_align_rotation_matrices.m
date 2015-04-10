function Rs = reshape_and_align_rotation_matrices(rot_mats)

% Input:
% - rot_mats:   nx9 matrix with a rotation matrix expanded as a vector in
%               each row

% Output:
% - Rs:         3x3xn matrix containing in each page a rotation matrix
%               relating the respective sample to the 1st one (an
%               alignment)

n = size(rot_mats, 1);
% Reshape rotation matrices to a set of 3x3 pages
Rs = permute(reshape(rot_mats', 3, 3, n), [2 1 3]);

R_1_t = Rs(:, :, 1)';

for i=1:n
    % Align each rotation matrix to the one of the first sample
    Rs(:, :, i) = Rs(:, :, i)*R_1_t;
end
    

end

