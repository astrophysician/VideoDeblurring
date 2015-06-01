%% Deblur entire video and produce deblurred output
tic;
close all;
clear all;

%% Load registered sensor data and video

file_name = 'VID_20150510_210632';

% Load video
vid = VideoReader(strcat('data/', file_name, '.mp4'));
writerObj = VideoWriter(strcat('data/', file_name, '_Sharp.avi'));

% Total number of frames to be deblurred
num_frames = get(vid, 'NumberOfFrames');

% Offset of recorded system timestamp from true start of video (in samples)
i = 83;

% Load sensor data
load(strcat('data/', file_name, strcat('_registeredExposureTime40',num2str(i)), '.mat'));

%% Define parameters

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

%% Main deblurring loop over all video frames
writerObj.FrameRate = 15;
open(writerObj);
for frame_number = 1:num_frames
    blurry_frame = im2double(read(vid, frame_number));
    
    % Check whether the number of samples acquired is small enough in order
    % to avoid deblurring
    min_samples = 4;
    if (length(samples_per_frame{frame_number}.timestamps) < min_samples)
        sharp_frame = blurry_frame;
    else
        Rs = reshape_and_align_rotation_matrices(samples_per_frame{frame_number}.rot_mats);
        Rs_corrected = correct_rotation_matrices(Rs);
        thetas = get_rotation_vectors_from_matrices(Rs_corrected);
        
        % Also check if range of all rotations is small enough for the same
        % purpose
        
        theta_range = norm(max(thetas, [], 2) - min(thetas, [], 2));
        
        % Minimum rotation that is assumed to cause non-negligible blur (in
        % radians)
        degree_fraction = 0.2;
        min_rotation = degree_fraction*sqrt(3)*(pi/180);
        
        if (theta_range < min_rotation)
            sharp_frame = blurry_frame;
        else
            % Deblur
            
            % Step 1: Kernel computation
            % Calculate the blur kernel using the rotation sequence and the
            % cell size for the grid in rotation space
%             [w, non_zeros, grid_origin] = construct_kernel(thetas, theta_cell);
            weights = ones(1,size(thetas,2))./size(thetas,2);
            % Step 2: Frame reconstruction
            % Get the quantized rotation vectors corresponding to positive
            % kernel weights
%             [quant_thetas, weights] = get_quantized_rotation_vectors(w, non_zeros, grid_origin, theta_cell);
            % Apply Richardson-Lucy algorithm for deconvolution
            sharp_frame = deconvlucy_rotational(blurry_frame, [height, width], weights, thetas, K, K, 255, 5);
            sharp_frame = max(min(1,sharp_frame),0);
        end
    end
    % Write sharp_frame to output video in a proper way!!!
    writeVideo(writerObj,sharp_frame);
end
close(writerObj);
toc;

