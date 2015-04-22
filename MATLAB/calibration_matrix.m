function K = calibration_matrix(focal_length, width, height)

% Compute the internal calibration matrix K of the camera given the focal
% length and the image's dimensions

% Take the principal point at the center of the image
x0 = floor(width/2);
y0 = floor(height/2);

K = [focal_length, 0, x0;
     0, focal_length, y0;
     0,            0,  1];

end

