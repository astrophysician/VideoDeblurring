function Rs_corrected = correct_rotation_matrices(Rs)

% Input:
% - Rs:         3x3xn matrix containing in each page a rotation matrix
%               relating the respective sample to the 1st one (an
%               alignment)

% Output:
% - Rs_corrected:   3x3xn matrix containing in each page a rotation matrix
%                   relating the respective sample to the 1st one using the
%                   standard camera coordinate frame as reference (z-axis
%                   pointing to the scene)

% Define rotation matrix from Nexus coordinate frame to standard camera
% coordinate frame
R = [0,-1,0;-1,0,0;0,0,-1];
Rt = R';

Rs_corrected = zeros(size(Rs));

n = size(Rs, 3);

for i=1:n
    % Correct each rotation matrix separately
    Rs_corrected(:, :, i) = R*Rs(:, :, i)*Rt;
end

end

