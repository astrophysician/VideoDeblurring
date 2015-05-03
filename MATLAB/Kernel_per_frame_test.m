%% Estimate blur kernel for a single frame of a video

% close all;
clear all;

%% Load registered sensor data and video

file_name = 'VID_20150503_200430';
load(strcat('data/', file_name, '_registered.mat'));

vid = VideoReader(strcat('data/', file_name, '.mp4'));

%% Select sample blurry frame and depict the kernel estimation

frame_number = 50;
blurry_frame = im2double(read(vid, frame_number));
% h = vision.GammaCorrector('Correction','De-gamma');
% blurry_frame = step(h, blurry_frame);

% Compute the rotation sequence for the examined frame
Rs = reshape_and_align_rotation_matrices(samples_per_frame{frame_number}.rot_mats);
thetas = get_rotation_vectors_from_matrices(Rs);

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

% Plot the resulting kernel
figure;
plot3(non_zeros(1, :), non_zeros(2, :), non_zeros(3, :), 'ob',...
    'MarkerFaceColor', 'b', 'MarkerSize', 5, 'MarkerEdgeColor', 'k');
axis tight
grid on
xlabel('\theta_x');
ylabel('\theta_y');
zlabel('\theta_z');
title('Non-zero elements of estimated kernel', 'FontSize', 14);

% Plot the corresponding blurry frame
figure;
imshow(blurry_frame);

%% 
[quant_thetas, weights] = get_quantized_rotation_vectors(w, non_zeros, grid_origin, theta_cell);
% blurry_frame_rotated = cat(3, flipud(blurry_frame(:,:,1)), flipud(blurry_frame(:,:,2)), flipud(blurry_frame(:,:,3)));
% figure;
% imshow(blurry_frame_rotated);
tic;
i_rl = deconvlucy_rotational(blurry_frame, [height, width], weights, quant_thetas, K, K, 255, 1);
toc;
% sharp_frame = cat(3, flipud(i_rl(:,:,1)), flipud(i_rl(:,:,2)), flipud(i_rl(:,:,3)));
figure;
imshow(i_rl);
% figure;
% imshow(sharp_frame);