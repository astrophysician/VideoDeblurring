function samples_per_frame = video_sensor_registration(time_sensor, rot_mats, duration, num_frames, diff, exposure_time)

% Inputs:
% - time_sensor:    1xn vector with timestamps of sensor samples in video
%                   time frame and ms
% - rot_mats:       nxm matrix with one rotation matrix sample in each row
% - duration:       total video duration in ms
% - num_frames:     total number of video frames
% - diff:           number of samples to take before the system time samples
% - exposure_time   exposure time for the frame in milliseconds


% Output:
% - samples_per_frame:  1xnum_frames cell array with sample and timestamp
%                       sequence corresponding to a certain frame in each
%                       cell at two separate fields

% Initialize cell array
samples_per_frame = cell(1, num_frames);

% Frame period
period = duration/num_frames;

% Main loop filling the samples-per-frame output structure
for i=1:num_frames
    % Isolate sensor samples corresponding to current frame
    frame_samples = find(time_sensor >= period*(i-1) & time_sensor < ((period*(i-1))+exposure_time));
    frame_samples = frame_samples - diff;
    frame_data.timestamps = time_sensor(frame_samples);
    frame_data.rot_mats = rot_mats(frame_samples, :);
    
    samples_per_frame{i} = frame_data;
end

end

