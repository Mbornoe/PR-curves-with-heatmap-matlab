# PR-curves-with-heatmap-matlab
Generate Precision-Recall curves based on detection and ground truth file. Furthermore used to generate heat maps of PRC results from e.g. multiple model size detections.

All code are optimized towards using multiple workers in matlab.

# Usage
The generateHeatmap.m is the main function, which are used for generating a heatmap based on multiple detections result found in folder "outputResults/". The syntax for the subfolder naming is: modelDS[15,16]-nOctUp[2]-treeDepth[4], where the modelDS parameters can be changed to create the heatmap.

# Additional
Shell script for merging worker.csv files are included aswell as a python script for locating unmerged .csv files.
A python script is included for generating the heatmap based on the outputfile from the matlab code.
