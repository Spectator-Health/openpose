# From Python
# It requires OpenCV installed for Python
import sys
import cv2
import os
from sys import platform
import argparse
import time

try:
    # Import Openpose (Windows/Ubuntu/OSX)
    dir_path = os.path.dirname(os.path.realpath(__file__))
    try:
        # Windows Import
        if platform == "win32":
            # Change these variables to point to the correct folder (Release/x64 etc.)
            sys.path.append(dir_path + '/../../python/openpose/Release');
            os.environ['PATH']  = os.environ['PATH'] + ';' + dir_path + '/../../x64/Release;' +  dir_path + '/../../bin;'
            import pyopenpose as op
        else:
            # Change these variables to point to the correct folder (Release/x64 etc.)
            sys.path.append('../../python');
            # If you run `make install` (default path is `/usr/local/python` for Ubuntu), you can also access the OpenPose/python module from there. This will install OpenPose and the python library at your desired installation path. Ensure that this is in your python path in order to use it.
            sys.path.append('/usr/local/python')
            from openpose import pyopenpose as op
    except ImportError as e:
        print('Error: OpenPose library could not be found. Did you enable `BUILD_PYTHON` in CMake and have this Python script in the right folder?')
        raise e

    # Flags
    parser = argparse.ArgumentParser()
    parser.add_argument("--image_dir", default="../../../examples/media/", help="Process a directory of images. Read all standard formats (jpg, png, bmp, etc.).")
    parser.add_argument("--source", default="", help="Path to input video file") 
    parser.add_argument("--dest", default="./open-pose-out.mp4", help="Path to output video file") 
    parser.add_argument("--no_display", action="store_true", help="Enable to disable the visual display.")
    args = parser.parse_known_args()

    # Custom Params (refer to include/openpose/flags.hpp for more parameters)
    params = dict()
    params["model_folder"] = "../../../models/"
    params["number_people_max"] = 1 
    params["maximize_positives"] = True 
    params["fps_max"] = -1. 
    params["model_pose"] = "BODY_25"
    params["net_resolution"] = "-1x480" 
    #params["write_video"] = "./openpose_body_keypoints.mp4" 
    params["write_json"] = "" 

    # Add others in path?
    for i in range(0, len(args[1])):
        curr_item = args[1][i]
        if i != len(args[1])-1: next_item = args[1][i+1]
        else: next_item = "1"
        if "--" in curr_item and "--" in next_item:
            key = curr_item.replace('-','')
            if key not in params:  params[key] = "1"
        elif "--" in curr_item and "--" not in next_item:
            key = curr_item.replace('-','')
            if key not in params: params[key] = next_item

    # Construct it from system arguments
    # op.init_argv(args[1])
    # oppython = op.OpenposePython()

    # Starting OpenPose
    opWrapper = op.WrapperPython()
    opWrapper.configure(params)
    opWrapper.start()

    # Read frames on directory
    #imagePaths = op.get_images_on_directory(args[0].image_dir);
    
    # Read images from .mp4 
    cap = cv2.VideoCapture(args[0].source)
    frame_array = [] 

    start = time.time()

    # Process and display images
    #for imagePath in imagePaths:
    while True: 
        datum = op.Datum()
        #imageToProcess = cv2.imread(imagePath)
        ret, imageToProcess = cap.read()
        if ret: 
            datum.cvInputData = imageToProcess
            opWrapper.emplaceAndPop([datum])

            print("Body keypoints: \n" + str(datum.poseKeypoints))

            if not args[0].no_display:
                cv2.imshow("OpenPose 1.5.1 - Tutorial Python API", datum.cvOutputData)
                key = cv2.waitKey(15)
                if key == 27: break
            else: 
                frame_array.append(datum.cvOutputData) 

        else: 
            break 
    
    # Write to video
    out = cv2.VideoWriter(
        args[0].dest, cv2.VideoWriter_fourcc(*'mp4v'), 30.0, ((640,480)))
    for i in range(len(frame_array)):
        # writing to image array
        out.write(frame_array[i])
    out.release()

    cap.release() 
    end = time.time()
    print("OpenPose demo successfully finished. Total time: " + str(end - start) + " seconds")

except Exception as e:
    print(e)
    sys.exit(-1)

finally: 
    cv2.destroyAllWindows() 
