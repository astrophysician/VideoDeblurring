tic;
file_sensor_data = 'data/VID_20150510_210615.txt';
[F, time_sys_videostart, time_sys_sensor, time_ev_sensor, rot_mats] =...
    get_sensor_data(file_sensor_data);

% Compute the rotation sequence for the examined frame
n = size(rot_mats, 1);
% Reshape rotation matrices to a set of 3x3 pages
Rs = reshape_and_align_rotation_matrices(rot_mats);

% Rs_corrected = correct_rotation_matrices(Rs);
thetas = get_rotation_vectors_from_matrices(Rs);
toc;