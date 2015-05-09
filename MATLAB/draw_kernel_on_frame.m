function I_blurry_paths = draw_kernel_on_frame(I_blurry, H_blurry2sharp)

% Inputs:
% - I_blurry:       3-channel blurry frame
% - H_blurry2sharp: 3x3xp matrix with homographies that correspond to
%                   elements of w and map the blurry frame to the sharp one

% Outputs:
% - I_blurry_paths: 3-channel blurry frame with visualized paths of sharp
%                   pixels in red color

% ATTENTION: need to determine Nexus' coordinate system on the frame to
% find correspondence between x/y axes and frame's rows and columns

I_blurry_paths = I_blurry;

height_blurry = size(I_blurry, 1);
width_blurry = size(I_blurry, 2);

% Create pixel coordinates for pixels of blurry frame forming a grid
[X, Y] = meshgrid(100:100:(width_blurry-100), 100:100:(height_blurry-100));

% pixel_coords is a 2xm matrix containing
% these coordinates in [x; y] format in its columns
pixel_coords = shiftdim(cat(3, X, Y), 2);
pixel_coords = reshape(pixel_coords, 2, []);

p = size(H_blurry2sharp, 3);

% Loop over all non-zero kernel weights and accumulate intensities at each
% channel separately
for k=1:p
    H = H_blurry2sharp(:, :, k);
    
    % Project all blurry pixels of the grid with current homography and get
    % corresponding coordinates for sharp frame and interpolation
    % coefficients
    proj_coords = project(H, pixel_coords);
    [sharp_pixel_coords, ~] =...
        get_interpolating_pixels_coefficients(proj_coords);
    
    for i=1:length(pixel_coords)
        sharp_coords_tmp = sharp_pixel_coords(:, i, :);
        
        for j=1:4
            y_coord = sharp_coords_tmp(2, 1, j);
            x_coord = sharp_coords_tmp(1, 1, j);
            
            % If the projected pixel is still inside frame...
            if (y_coord >= 1 && y_coord <= height_blurry &&...
                    x_coord >= 1 && x_coord <= width_blurry)
                % ...paint the pixel red
                I_blurry_paths(y_coord, x_coord, :) =...
                    [1, 0, 0];
            end
        end
        
    end
    
end

end
