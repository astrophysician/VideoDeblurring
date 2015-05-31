The apk file is located at ../Application/Application-release.apk

This file gives description of the android app part of the code. The readme file for Matlab part is inside the folder Matlab.

Description:
This app records Rotation Vector Sensor data while recording a video. The code is based on the MediaRecorder
sample available in the official Android code samples. This code has been tested and verified to run on Nexus 5 devices.
This should run smoothly on other nexus devices as well but has not been tested on them. The app does not run on most of
the Galaxy series devices (We have tested it on Galaxy S2 and Galaxy Note 3 and it did not work). The video is recorded
with fixed focal length.

File Details:
Both video and the sensor data files are stored at the default picture storage folder (usually 'Pictues' folder).
The video file is in .mp4 format encoded using the default MPEG encoder for Android.

The sensor data file is a text file with the following data format:
1st line records the device time stamp for approximate start time of video. The time stamp is recorded right after
the control returns from MediaRecorder.start() method call.
2nd line records the focal length of the camera sensor.
Rest of the lines contain the system time stamp, event time stamp and rotation vector sensor readings respectively.
The rotation vector sensor gives the 3X3 rotation matrix. The readings are listed in the row major order.

These files should be copied to a PC location and used with the Matlab code for de-blurring.