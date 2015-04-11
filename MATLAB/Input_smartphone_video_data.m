%% Register sensor data from text file with video

close all;
clear all;

%% Read sensor data

file_sensor_data = 'data/VID_20150409_162957.txt';
[F, time_sys_videostart, time_sys_sensor, time_ev_sensor, rot_mats] =...
    get_sensor_data(file_sensor_data);

%% Read video from file and get basic properties

file_video = 'data/VID_20150409_162957.mp4';
vid = VideoReader(file_video);

% Duration in ms
duration = get(vid, 'Duration')*1000;

% Frame rate in fps
frame_rate = get(vid, 'FrameRate');

% Total number of frames
num_frames = get(vid, 'NumberOfFrames');

%% Divide sensor data time-wise according to corresponding frame

% Use system timestamps of sensor readings - assuming that their difference
% to event timestamps is negligible (!!! - might not be true)

% Remove offset from sensor timestamps to obtain a video-based reference
% for time of sensor samples
time_sensor_video = time_sys_sensor - time_sys_videostart;

% Get cell array with single-frame sequences of sensor samples per cell
samples_per_frame = video_sensor_registration(time_sensor_video, rot_mats, duration, num_frames);

% Save frame-separated sensor data
save(strcat(file_video(1:end-4), '_registered', '.mat'), 'samples_per_frame', 'F');
