tic;
% name for output files
CONFIG_FNAME = '202ImageBlurry';

% non-uniform model?
NON_UNIFORM = 1;

%% image configuration
% User selected region (xmin xmax ymin ymax)
AXIS = [1 320 1 192];

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image to deblur & intrinsic calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filename of image to deblur
obs_im = imread('../images/202ImageBlurry.png');

% Focal length in 35mm equivalent
f = 3.97;
w = 4.54;
focal_length_35mm = (f*36)/w;

% downsample image before we start?
PRESCALE = 0.25;

% size of blur kernel in the image
BLUR_KERNEL_SIZE = 9;

% inital value of kernel
% FIRST_INIT_MODE_BLUR = 'hbar';
FIRST_INIT_MODE_BLUR = 'vbar';
%FIRST_INIT_MODE_BLUR = 'delta';

% parameters for dimensions of non-uniform kernel
pixels_per_theta_step = 1;
blur_x_lims = floor(((BLUR_KERNEL_SIZE)-1)/2)*[-1 1];
blur_y_lims = floor(((BLUR_KERNEL_SIZE)-1)/2)*[-1 1];
blur_z_lims = floor(((BLUR_KERNEL_SIZE)-1)/4)*[-1 1];



%%
NUM_THREADS = 1;

% default configuration
default_config;

deblur;
toc;