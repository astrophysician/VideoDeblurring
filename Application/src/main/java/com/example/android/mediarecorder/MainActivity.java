/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.mediarecorder;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.CamcorderProfile;
import android.media.MediaRecorder;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;

import com.example.android.common.media.CameraHelper;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 *  This activity uses the camera/camcorder as the A/V source for the {@link android.media.MediaRecorder} API.
 *  A {@link android.view.TextureView} is used as the camera preview which limits the code to API 14+. This
 *  can be easily replaced with a {@link android.view.SurfaceView} to run on older devices.
 */
public class MainActivity extends Activity implements SensorEventListener{

    private Camera mCamera;
    private TextureView mPreview;
    private MediaRecorder mMediaRecorder;
    private SensorManager mSensorManager;
    private Sensor mRotationVectorSensor;
    private ArrayList<float[]> mRotationMatrices = new ArrayList();
    private ArrayList<Long> mEventTimestamps = new ArrayList();
    private ArrayList<Long> mSystemTimestamps = new ArrayList();


    private boolean isRecording = false;
    private boolean hasRotationVectorSensor = false;
    private static final String TAG = "Recorder";
    private Button captureButton;
    private String videoFile =  null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.sample_main);

        // Get an instance of the SensorManager
        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);

        // Try getting an instance of the RotationVector Sensor
        if (mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null) {
            mRotationVectorSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
            hasRotationVectorSensor = true;
        }
        else System.out.println("No RotationVector Sensor available!");

        int rotation = ((WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getRotation();
        System.out.println(rotation);
        mPreview = (TextureView) findViewById(R.id.surface_view);
        captureButton = (Button) findViewById(R.id.button_capture);
    }

    /**
     * The capture button controls all user interaction. When recording, the button click
     * stops recording, releases {@link android.media.MediaRecorder} and {@link android.hardware.Camera}. When not recording,
     * it prepares the {@link android.media.MediaRecorder} and starts recording.
     *
     * @param view the view generating the event.
     */
    public void onCaptureClick(View view) {
        if (isRecording) {
            // BEGIN_INCLUDE(stop_release_media_recorder)

            // stop recording and release camera
            mMediaRecorder.stop();  // stop the recording
            // Move it to start if on debugging, it is not giving the correct value.
            float mFocalLength = mCamera.getParameters().getFocalLength();
            releaseMediaRecorder(); // release the MediaRecorder object
            mCamera.lock();         // take camera access back from MediaRecorder

            // inform the user that recording has stopped
            setCaptureButtonText("Capture");
            isRecording = false;
            releaseCamera();
            // END_INCLUDE(stop_release_media_recorder)

            // Unregister the sensor listener **after** the recording has stopped
            if (hasRotationVectorSensor) {
                mSensorManager.unregisterListener(this);
            }

            // Write the sensor data and timestamps to file
            StringBuilder lineToWrite = new StringBuilder(mFocalLength + "\n");
            for (int i = 0; i<mSystemTimestamps.size();i++) {
                lineToWrite.append(String.valueOf(mSystemTimestamps.get(i)));
                lineToWrite.append(", " + String.valueOf(mEventTimestamps.get(i)));
                lineToWrite.append(", " + Arrays.toString(mRotationMatrices.get(i)));
                lineToWrite.append("\n");
            }
            writeToSensorFile(videoFile.substring(0, videoFile.length()-4)+ ".txt",
                    lineToWrite.toString());
            mSystemTimestamps.clear();
            mEventTimestamps.clear();
            mRotationMatrices.clear();
        } else {

            // Get file name for storing data first
            videoFile = CameraHelper.getOutputMediaFile(CameraHelper.MEDIA_TYPE_VIDEO).toString();

            /* Use minimum possible delay for sensor events -> obtain more rotation vector samples per frame
            We can also use the getMinDelay() method of the Sensor class as the 3rd argument for this purpose -
            check whether RotationVectorSensor is a streaming sensor (which means that getMinDelay() will
            return a positive integer for the microseconds of the minimum delay) or if it creates SensorEvent
            only when its data changes.
             */
            // Register the sensor listener **before** the recording starts
            if (hasRotationVectorSensor) {
                mSensorManager.registerListener(this, mRotationVectorSensor, SensorManager.SENSOR_DELAY_FASTEST);
            }

            // BEGIN_INCLUDE(prepare_start_media_recorder)
            new MediaPrepareTask().execute(null, null, null);
            // END_INCLUDE(prepare_start_media_recorder)

        }
    }

    private void setCaptureButtonText(String title) {
        captureButton.setText(title);
    }

    @Override
    protected void onPause() {
        super.onPause();
        // Unregister the sensor to save power
        if (hasRotationVectorSensor) {
            mSensorManager.unregisterListener(this);
        }
        // if we are using MediaRecorder, release it first
        releaseMediaRecorder();
        // release the camera immediately on pause event
        releaseCamera();
    }

/*    @Override
    protected void onResume() {
        super.onResume();

        if (hasRotationVectorSensor) {
            mSensorManager.registerListener(this, mRotationVectorSensor, SensorManager.SENSOR_DELAY_FASTEST);
        }
    }*/

    private void releaseMediaRecorder(){
        if (mMediaRecorder != null) {
            // clear recorder configuration
            mMediaRecorder.reset();
            // release the recorder object
            mMediaRecorder.release();
            mMediaRecorder = null;
            // Lock camera for later use i.e taking it back from MediaRecorder.
            // MediaRecorder doesn't need it anymore and we will release it if the activity pauses.
            mCamera.lock();
        }
    }

    private void releaseCamera(){
        if (mCamera != null){
            // release the camera for other applications
            mCamera.release();
            mCamera = null;
        }
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private boolean prepareVideoRecorder(){

        // BEGIN_INCLUDE (configure_preview)
        mCamera = CameraHelper.getDefaultCameraInstance();

        // We need to make sure that our preview and recording video size are supported by the
        // camera. Query camera to find all the sizes and choose the optimal size given the
        // dimensions of our preview surface.
        Camera.Parameters parameters = mCamera.getParameters();
        List<Camera.Size> mSupportedPreviewSizes = parameters.getSupportedPreviewSizes();
        Camera.Size optimalSize = CameraHelper.getOptimalPreviewSize(mSupportedPreviewSizes,
                mPreview.getWidth(), mPreview.getHeight());

        // Use the same size for recording profile.
        CamcorderProfile profile = CamcorderProfile.get(CamcorderProfile.QUALITY_HIGH);
        profile.videoFrameWidth = optimalSize.width;
        profile.videoFrameHeight = optimalSize.height;
        profile.videoFrameRate = 15;

        // likewise for the camera object itself.
        parameters.setPreviewSize(profile.videoFrameWidth, profile.videoFrameHeight);
        parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_FIXED);
        parameters.setVideoStabilization(false);
        parameters.setRecordingHint(true);
        parameters.setPreviewFrameRate(15);
        mCamera.setParameters(parameters);
        try {
                // Requires API level 11+, For backward compatibility use {@link setPreviewDisplay}
                // with {@link SurfaceView}
                mCamera.setPreviewTexture(mPreview.getSurfaceTexture());
        } catch (IOException e) {
            Log.e(TAG, "Surface texture is unavailable or unsuitable" + e.getMessage());
            return false;
        }
        // END_INCLUDE (configure_preview)


        // BEGIN_INCLUDE (configure_media_recorder)
        mMediaRecorder = new MediaRecorder();

        // Step 1: Unlock and set camera to MediaRecorder
        mCamera.unlock();
        mMediaRecorder.setCamera(mCamera);

        // Step 2: Set sources
        mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.DEFAULT );
        mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);
//        mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);
//        mMediaRecorder.setVideoFrameRate(15);
        mMediaRecorder.setCaptureRate(15);

        // Step 3: Set a CamcorderProfile (requires API Level 8 or higher)
        mMediaRecorder.setProfile(profile);

        // Step 4: Set output file
        mMediaRecorder.setOutputFile(videoFile);
        // END_INCLUDE (configure_media_recorder)

        // Step 5: Prepare configured MediaRecorder
        try {
            mMediaRecorder.prepare();
        } catch (IllegalStateException e) {
            Log.d(TAG, "IllegalStateException preparing MediaRecorder: " + e.getMessage());
            releaseMediaRecorder();
            return false;
        } catch (IOException e) {
            Log.d(TAG, "IOException preparing MediaRecorder: " + e.getMessage());
            releaseMediaRecorder();
            return false;
        }
        return true;
    }

    @Override
    public void onSensorChanged(SensorEvent event) {

        // Confirm that the event was triggered by the proper sensor
        if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {

            // Add new measurements to measurement lists
            mEventTimestamps.add(event.timestamp);
            mSystemTimestamps.add(System.currentTimeMillis());
            float[] mRotationMatrix = new float[9];
            SensorManager.getRotationMatrixFromVector(mRotationMatrix, event.values);
            // Store the returned rotation vectors as rotation matrix. There is also a function
            // to get rotationMatrix but not sure what kind of rotation matrix is returned.
            mRotationMatrices.add(mRotationMatrix);
            // Could also retrieve current accuracy level of the sensor with event.accuracy

        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    /**
     * Write line to filename and append with a newline
     * @param filename
     * @param line
     */
    private void writeToSensorFile(String filename, String line) {
        try {
            File file = new File(filename);
            if(!file.exists()){
                file.createNewFile();
            }
            BufferedWriter writer = new BufferedWriter(new FileWriter(file, true));
            writer.write(line);
            writer.newLine();
            writer.flush();
            writer.close();
        } catch (IOException e) {
            Log.e(TAG, "File for sensor not created" + e.getMessage());
        }
    }
    /**
     * Asynchronous task for preparing the {@link android.media.MediaRecorder} since it's a long blocking
     * operation.
     */
    class MediaPrepareTask extends AsyncTask<Void, Void, Boolean> {

        @Override
        protected Boolean doInBackground(Void... voids) {
            // initialize video camera
            if (prepareVideoRecorder()) {
                // Camera is available and unlocked, MediaRecorder is prepared,
                // now you can start recording
                mMediaRecorder.start();
                long startTime = System.currentTimeMillis();
                writeToSensorFile(videoFile.substring(0, videoFile.length()-4)+ ".txt",
                        String.valueOf(startTime));

                isRecording = true;
            } else {
                // prepare didn't work, release the camera
                releaseMediaRecorder();
                return false;
            }
            return true;
        }

        @Override
        protected void onPostExecute(Boolean result) {
            if (!result) {
                MainActivity.this.finish();
            }
            // inform the user that recording has started
            setCaptureButtonText("Stop");
        }
    }

}