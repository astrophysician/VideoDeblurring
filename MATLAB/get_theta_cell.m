function theta_cell = get_theta_cell(focal_length, width, height, pixels_per_theta_cell)

% Compute the cell size of the theta grid based on Whyte's approach

% Take the principal point at the center of the image
x0 = width/2;
y0 = height/2;

% Maximum distances of principal point from any image edge and any image
% pixel
max_vertical = max(width/2, height/2);
max_diagonal = sqrt(width^2 + height^2)/2;

% Different grid resolution for z-axis than for x and y-axis
theta_cell = zeros(3, 1);
theta_cell(1) = pixels_per_theta_cell*(focal_length/(focal_length^2 + max_vertical^2));
theta_cell(2) = pixels_per_theta_cell*(focal_length/(focal_length^2 + max_vertical^2));
theta_cell(3) = pixels_per_theta_cell/max_diagonal;

end

