function x_new = project(H, x)

% Inputs:
% - H:      3x3 matrix representing the applied homography
% - x:      2xm matrix with columns containing vectors to be transformed

% Output:
% - x_new:  2xm matrix with columns containing vectors to which x are
%           mapped under H

x_hom = [x; ones(1, size(x, 2))];
x_new_hom = H*x_hom;

% Normalize and return vector in inhomogeneous coordinates
x_new = x_new_hom(1:2, :)./repmat(x_new_hom(3, :), 2, 1);

end

