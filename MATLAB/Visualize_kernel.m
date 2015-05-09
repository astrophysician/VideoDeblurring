%% Visualize blurring process for a single frame

close all;
clear all;

%% Load registered sensor data and video

file_name = 'VID_20150503_200430';

%load(strcat('data/', file_name, strcat('_registered',num2str(i)), '.mat'));
load(strcat('data/', file_name, '_registered.mat'));

vid = VideoReader(strcat('data/', file_name, '.mp4'));

%% Select sample blurry frame, perform the kernel estimation 

frame_number = 53;
I_blurry = im2double(read(vid, frame_number));

% Compute the rotation sequence for the examined frame
Rs = reshape_and_align_rotation_matrices(samples_per_frame{frame_number}.rot_mats);
Rs_corrected = correct_rotation_matrices(Rs);
thetas = get_rotation_vectors_from_matrices(Rs_corrected);

% Hard-code the focal length expressed in pixel coordinates using the
% information for the pixel size of the used phone's (LG Nexus 5) sensor
pixel_size = 0.0014;
focal_length = F/pixel_size;

width = get(vid, 'Width');
height = get(vid, 'Height');
K = calibration_matrix(focal_length, width, height);

% Compute the cell size of the theta grid based on Whyte's approach
pixels_per_theta_cell = 1;
theta_cell = get_theta_cell(focal_length, width, height, pixels_per_theta_cell);

% Calculate the blur kernel using the rotation sequence and the cell size
% for the grid in rotation space
[w, non_zeros, grid_origin] = construct_kernel(thetas, theta_cell);

% Re-determine the locations of rotation samples after quantization
[quant_thetas, weights] = get_quantized_rotation_vectors(w, non_zeros, grid_origin, theta_cell);

% Create the corresponding "quantized" rotation matrices
quant_Rs = get_rotation_matrices_from_vectors(quant_thetas);

% Transpose the above rot. matrices so that the direction of the
% homographies is from the blurry to the sharp frame
quant_Rs_inverse = zeros(size(quant_Rs));

for s=1:size(quant_Rs_inverse, 3)
    quant_Rs_inverse(:, :, s) = quant_Rs(:, :, s)';
end

% Sequence of homographies from blurry to sharp frame
H_blurry2sharp = generate_homographies(quant_Rs_inverse, K);

% Draw the sharp pixels' paths during camera shake on the blurry frame
I_blurry_paths = draw_kernel_on_frame(I_blurry, H_blurry2sharp);

%% Visualize the results

% Plot the resulting kernel
figure;
plot3(quant_thetas(1, :), quant_thetas(2, :), quant_thetas(3, :), 'ob',...
    'MarkerFaceColor', 'b', 'MarkerSize', 5, 'MarkerEdgeColor', 'k');
axis tight
grid on
axis equal
xlabel('\theta_x');
ylabel('\theta_y');
zlabel('\theta_z');
title('Rotation samples of estimated kernel', 'FontSize', 14);

% Plot the frame with the paths
figure;
imshow(I_blurry_paths);
title('Pixel paths during camera rotation', 'FontSize', 14);
