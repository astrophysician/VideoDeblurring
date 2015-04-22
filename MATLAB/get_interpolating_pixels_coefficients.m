function [sharp_pixel_coords, coefficients] = get_interpolating_pixels_coefficients(sharp_float_coords)

% Input:
% - sharp_float_coords: 2xm matrix holding the real-valued coordinates of
%                       the projections of blurry pixels on the sharp frame

% Outputs:
% - sharp_pixel_coords: 2xmx4 matrix holding the coordinates of the 4
%                       interpolating sharp pixels
% - coefficients:       1xmx4 matrix holding the interpolation coefficients
%                       for the 4 interpolating pixels

sharp_pixel_coords = cat(3, floor(sharp_float_coords),...
    [floor(sharp_float_coords(1, :)); floor(sharp_float_coords(2, :))+1],...
    [floor(sharp_float_coords(1, :))+1; floor(sharp_float_coords(2, :))],...
    floor(sharp_float_coords)+1);

coefficients = (1 - abs(sharp_pixel_coords(1, :, :) - repmat(sharp_float_coords(1, :), 1, 1, 4)))...
    .*(1 - abs(sharp_pixel_coords(2, :, :) - repmat(sharp_float_coords(2, :), 1, 1, 4)));

end

