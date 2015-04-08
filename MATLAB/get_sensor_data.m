function [F, time_sys_videostart, time_sys_sensor, time_ev_sensor, rot_mats] = get_sensor_data(file)

% Open file
fid = fopen(file);

% Read first line to get system timestamp for the beginning of the video
time_sys_videostart = str2double(fgets(fid));

% Read second line to get focal length of camera in mm
F = str2double(fgets(fid));

% Read rest lines with sensor readings

time_sys_sensor = [];
time_ev_sensor = [];
rot_mats = [];

line = fgets(fid);

empty_line = sprintf('\n');

while (ischar(line))
    % Break at first empty line (there are two at the end of the file)
    if (strcmp(line, empty_line))
        break;
    end
    
    % Get system timestamp for current reading
    [tim1, rmn] = strtok(line, ',');
    time_sys_sensor = [time_sys_sensor, str2double(tim1)];
    
    % Get event timestamp for current reading - eat whitespaces
    [tim2, rmn] = strtok(rmn, ' ,');
    time_ev_sensor = [time_ev_sensor, str2double(tim2)];
    
    % Get rotation matrix sample
    rot = strsplit(rmn, {' ', ',', '[', ']'});
    rot_mat = str2double(rot(2:10));
    rot_mats = [rot_mats; rot_mat];
    
    line = fgets(fid);
end


% Close file
fclose(fid);

end

