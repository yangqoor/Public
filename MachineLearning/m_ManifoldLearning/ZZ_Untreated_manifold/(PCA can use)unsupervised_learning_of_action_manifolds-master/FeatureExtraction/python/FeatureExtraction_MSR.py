#!/usr/bin/python

# importing the required modules
import sys
import math
import os
import time

# string variables
textFileDir = "Features/"
videoFileDir = "OpticalFlow/"
videoFileDir_Mhi = "MHI/"
executable1 = "./Release/FeatureExtraction"
executable2 = "./Release/MotionHistoryImages"

# Get the home directory
home_path = os.getenv("HOME")
try:
        actionDataset_path = sys.argv[1] # getting the dataset path
except IOError:
        print "No Argument present"
        sys.exit()

#getting the effective action sequence path
eff_dataset_path = home_path + actionDataset_path
eff_list_of_actions_path = eff_dataset_path + sys.argv[2]

try:
        action_list_file = open(eff_list_of_actions_path,"r")
except IOError:
        print "No Argument present"
        sys.exit()

#creating the directory for writing the Optical Flow Feature set
try:
        eff_dataset_optFlow_path = eff_dataset_path + textFileDir
        os.mkdir(eff_dataset_optFlow_path)
except OSError:
        pass
    
#creating the directory for writing the Optical Flow video illustration
try:
    eff_dataset_optFlow_video_path = eff_dataset_path + videoFileDir
    os.mkdir(eff_dataset_optFlow_video_path)
except OSError:
    pass

#creating the directory for writing the MHI Video
try:
    eff_dataset_mhi_video_path = eff_dataset_path + videoFileDir_Mhi
    os.mkdir(eff_dataset_mhi_video_path)
except OSError:
    pass

# getting the various actions classes
action_list = action_list_file.readlines()

action_list_file.close();

for k in range(len(action_list)):
        action = action_list[k-1]
        action = action.strip()
        action_list[k-1] = action

#TODO: Set the path appropriately
# Iterating through each action class directory
for action in action_list:
        # effective path of the action class        
        eff_action_path = eff_dataset_path + action
        eff_action_optFlow_path = eff_dataset_optFlow_path + action
        eff_action_optFlow_video_path = eff_dataset_optFlow_video_path + action
        eff_action_mhi_video_path = eff_dataset_mhi_video_path + action
        
        try:
                os.mkdir(eff_action_optFlow_path)
        except OSError:
                pass
            
        try:
                os.mkdir(eff_action_optFlow_video_path)
        except OSError:
                pass
        
        try:
                os.mkdir(eff_action_mhi_video_path)
        except OSError:
                pass

        #get the list of video sequences corresponding to that action class        
        video_list = os.listdir(eff_action_path)
        for video in video_list:
                #create the text file
                #video_file = video.strip(".avi")
                video_file = video[:-4]
                input_video_file = eff_action_path + "/" + video_file + ".avi"
                flow_video_file_dir = eff_action_optFlow_path+"/"+video_file

                # create the person and action directory
                try:
                    os.mkdir(flow_video_file_dir)
                except OSError:
                    pass
                
                optflow_mag_file = flow_video_file_dir + "/" + "optflow_mag"
                optflow_direction_file = flow_video_file_dir + "/" + "optflow_dir" 
                optflow_video_file = eff_action_optFlow_video_path + "/" + video_file + "_flow.avi"   
                
                mhi_video_file = eff_action_mhi_video_path + "/" + video_file + "_mhi.avi"

                # TODO: Modify this command create the command to run STIP extractor 
                #command = executable + " -i " + video_file_name_inText + " -vpath " + eff_action_path + "/ -o " + stip_file + " -det harris3d -vis no" 
                #command = "./bin/stipdet -i ./data/video-list.txt -vpath ./data/ -o ./data/walk-samples-stip.txt -det harris3d "  
                command1 = executable1 +  " " + input_video_file + " " + optflow_video_file + " " + optflow_mag_file + " " + optflow_direction_file
                command2 = executable2 + " " + input_video_file + " " + mhi_video_file   
                command_comp = "tar -zcf" +  video_file + ".tar.gz " + video_file
                command_rem = "rm -rf "+ video_file
                
                #time.sleep(1)
                # call the command using system command
                
                os.system(command1);
                
                curr_dir = os.getcwd();
                os.chdir(eff_action_optFlow_path)
                os.system(command_comp)
                os.system(command_rem)     
                os.chdir(curr_dir)
                
                #os.system(command2);
                
                #os.system(command4);
                
                print input_video_file
        
        




