%% Visualize blurring process for a single frame
% Offsets for which to run the algorithm.
for i = 83
close all;
clearvars -except i;
it = 5;
%% Load registered sensor data and video
tic;
file_name = 'VID_20150510_210632';

load(strcat('data/', file_name, strcat('_registeredExposureTime40',num2str(i)), '.mat'));
% load(strcat('data/', file_name, '_registered.mat'));

vid = VideoReader(strcat('data/', file_name, '.mp4'));

%% Select sample blurry frame, perform the kernel estimation 

frame_number = 202;
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
% theta_cell = get_theta_cell(focal_length, width, height, pixels_per_theta_cell);

% Calculate the blur kernel using the rotation sequence and the cell size
% for the grid in rotation space
% [w, non_zeros, grid_origin] = construct_kernel(thetas, theta_cell);
weights = ones(1,size(thetas,2))./size(thetas,2);
% Re-determine the locations of rotation samples after quantization
% [quant_thetas, weights] = get_quantized_rotation_vectors(w, non_zeros, grid_origin, theta_cell);

% Create the corresponding "quantized" rotation matrices
% quant_Rs = get_rotation_matrices_from_vectors(quant_thetas);

% Transpose the above rot. matrices so that the direction of the
% homographies is from the blurry to the sharp frame
Rs_corrected_inverse = zeros(size(Rs_corrected));

for s=1:size(Rs_corrected, 3)
    Rs_corrected_inverse(:, :, s) = Rs_corrected(:, :, s)';
end

% Sequence of homographies from blurry to sharp frame
H_blurry2sharp = generate_homographies(Rs_corrected_inverse, K);

% Draw the sharp pixels' paths during camera shake on the blurry frame
I_blurry_paths = draw_kernel_on_frame(I_blurry, H_blurry2sharp);

% Run Richardson-Lucy deconvolution
% tic;
i_rl = deconvlucy_rotational(I_blurry, [height, width], weights, thetas, K, K, 0.80, it);
% imshow(i_rl)
imwrite(i_rl, strcat('results/',file_name,'/',num2str(frame_number),'Image80sat30Exposure',num2str(i),'offset',num2str(it),'.png'));
%% Visualize the results

% Plot the resulting kernel
fk = figure;
plot3(thetas(1, :), thetas(2, :), thetas(3, :), 'ob',...
    'MarkerFaceColor', 'b', 'MarkerSize', 5, 'MarkerEdgeColor', 'k');
axis tight
grid on
axis equal
xlabel('\theta_x');
ylabel('\theta_y');
zlabel('\theta_z');
title('Rotation samples of estimated kernel', 'FontSize', 14);
saveas(fk, strcat('results/',file_name, '/',num2str(frame_number),'Kernel',num2str(i),'offset',num2str(it),'.eps'))

% Plot the frame with the paths
% fp = figure;
imwrite(I_blurry_paths, strcat('results/',file_name, '/',num2str(frame_number),'ImagePaths80sat30Exposure',num2str(i),'offset',num2str(it),'.png'));
% imshow(I_blurry_paths);
% title('Pixel paths during camera rotation', 'FontSize', 14);
toc;
end
