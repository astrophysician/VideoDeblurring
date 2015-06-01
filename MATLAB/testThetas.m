tic;
file_sensor_data = 'data/VID_20150510_210632.txt';
[F, time_sys_videostart, time_sys_sensor, time_ev_sensor, rot_mats] =...
    get_sensor_data(file_sensor_data);

% Compute the rotation sequence for the examined frame
rot_mats = rot_mats(find(time_sys_sensor-time_sys_videostart >= 2300 & time_sys_sensor-time_sys_videostart <= 2700), :);
n = size(rot_mats, 1);
% Reshape rotation matrices to a set of 3x3 pages
% Rs = permute(reshape(rot_mats', 3, 3, n), [2 1 3]);
Rs = reshape_and_align_rotation_matrices(rot_mats);

Rs_corrected = correct_rotation_matrices(Rs);

thetas = get_rotation_vectors_from_matrices(Rs_corrected);
toc;