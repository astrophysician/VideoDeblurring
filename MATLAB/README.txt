Please follow the Readme from parent folder to get the video and sensor files.

=========================================
Initial Set up
=========================================
Run the 'Input_smartphone_video_data.m' script to create some intermediate .mat files.
The variables in line 8 and 14 should be changed to the appropriate values corresponding to the video
and sensor file names. This script will generate video frame and sensor correspondence data for different
offsets between them. The offset is calculated in terms of the number of samples to be taken before the
system time stamp. 'video_sensor_registration.m' function generates the sample and time stamp correspondence
sequence. To change the values for exposure time or offsets, please make appropriate changes in the call
to this function in line 36 and 38. The intermediate file name and location can be changed in line 41.

=========================================
Running whole video:
=========================================
'Deblur_video.m' script can then be used to de-blur the entire video. Following parameters must be set
appropriately in the script:
- line 8: video file name without the extension. Currently only '.mp4' extension is supported.
- line 18: Offset to use for de-blurring. (Please see section 'Running individual frames' to find the correct offset values)
- line 27: the pixel size is set for Nexus 5 (on which all the experiments were done) by default. If you are
           using a different device, please set this value appropriately.
Make sure to change the intermediate file name (line 21) in case you changed it in the earlier step.
By default the script will generate the output file named 'original_filename_sharp.avi'. See line 12 to change this.

=========================================
Running individual frames
=========================================
Individual frames can be run instead of the whole video to identify the correct offset. We have not yet been
able to automate this process. Use 'VisualizeKernelNoQuantization.m' script to run individual frames. We advise
to identify a blurry frame and run this script for the same set of offsets as in the 'Initial Set up' step. You 
can change the offsets to run for in line 3. Following parameters can be tuned in this script:
- line 9: Video file name.
- line 18: frame number to be used.
- line 28: pixel size, need to be changed if the device is not Nexus 5.
Make sure to change the intermediate file name (line 11) in case you changed it in the earlier steps.
Please create the folder 'results'. The results for different offsets will be stored in this folder.
Following 3 files are generated for each offset.
- ImagePaths: This shows the blur kernel path for a grid of pixels superimposed on the initial image.
- Kernel: Blur kernel visualization in a 3d grid (.fig file)
- Image: The final deblurred image file.

The offset can be identified by viewing the images and selecting ones that have the best result. More than 1 frame can
be leveraged to correctly identify the offset.