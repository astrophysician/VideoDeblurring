function [I_blurry] =...
    sharp2blurry(I_sharp, weights, H_blurry2sharp, size_blurry)

% Inputs:
% - I_sharp:        3-channel sharp frame estimate
% - weights:        1xp vector with non-zero kernel elements
% - H_blurry2sharp: 3x3xp matrix with homographies that correspond to
%                   elements of w and map the blurry frame to the sharp one
% - size_blurry:    1x2 vector containing desired height and width of
%                   output blurry image

% Outputs:
% - I_blurry:       3-channel blurry frame (possibly with different
%                   dimensions from I_sharp)

% Initialize RGB blurry frame to zero
height_blurry = size_blurry(1);
width_blurry = size_blurry(2);
num_pixels_blurry = height_blurry*width_blurry;
I_blurry = zeros(height_blurry, width_blurry, 3);

% Create pixel coordinates for all pixels of blurry frame;
% pixel_coords is a 2x(height_blurry . width_blurry) matrix containing
% these coordinates in [x; y] format in its columns

% ATTENTION: need to determine Nexus' coordinate system on the frame to
% find correspondence between x/y axes and frame's rows and columns
[Y, X] = meshgrid(1:width_blurry, 1:height_blurry);

pixel_coords = shiftdim(cat(3, X, Y), 2);
pixel_coords = reshape(pixel_coords, 2, []);

p = size(weights, 2);

% Loop over all non-zero kernel weights and accumulate intensities at each
% channel separately
for k=1:p
    H = H_blurry2sharp(:, :, k);
    
    % Project all blurry pixels with current homography and get
    % corresponding coordinates for sharp frame and interpolation
    % coefficients
    proj_coords = project(H, pixel_coords);
    [sharp_pixel_coords, interp_coefficients] =...
        get_interpolating_pixels_coefficients(proj_coords);
    
    for i=1:num_pixels_blurry
        sharp_coords_tmp = sharp_pixel_coords(:, i, :);
        
        % Retrieve sharp frame's pixel values using the obtained
        % coordinates
        sharp_pixels = cat(1,...
            I_sharp(sharp_coords_tmp(1, 1, 1), sharp_coords_tmp(2, 1, 1), :),...
            I_sharp(sharp_coords_tmp(1, 1, 2), sharp_coords_tmp(2, 1, 2), :),...
            I_sharp(sharp_coords_tmp(1, 1, 3), sharp_coords_tmp(2, 1, 3), :),...
            I_sharp(sharp_coords_tmp(1, 1, 4), sharp_coords_tmp(2, 1, 4), :));
        sharp_pixels = shiftdim(sharp_pixels, 2);
        
        % Interpolate to get blur component for current rotation
        blur_component = sharp_pixels*reshape(interp_coefficients(1, i, :), 4, 1);
        
        % Accumulate simulating the blurring process
        [vrt, hrz] = ind2sub([height_blurry, width_blurry], i);
        I_blurry(vrt, hrz, :) = I_blurry(vrt, hrz, :) + weights(k)*blur_component;
    end
end


end

