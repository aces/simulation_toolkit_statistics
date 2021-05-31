Scripts and data provided in this repository are created by Mona OmidYeganeh and are used to generate and test data in Frontiers In Neuroinformatics:  
A Simulation Toolkit for Testing the Sensitivity and Accuracy of Corticometry Pipelines

This repository includes:
example : This folder includes a sample set of files, needed to run the simulation toolkit, including the calculated thickness
            files and CSV files. 
surfstat: A toolbox for the statistical analysis. 
fs_surfs: Freesurfer Surfaces including masks of the ROI areas.
CSV_files: CIVET Surfaces including masks of the ROI areas.
statisticalanalysis: Simulation function that evaluates the effect of deformation. 
Sample-Videos-of-ROIs: Videos of subtle, localized changes in the cortex.


Data and statistical analyses relate to our published experiments, testing the effect of regional deformations in sensitivity and specificity of statistical abnormalities detected by CIVET or FreeSurface corticometry pipelines.

i.e. thicknesses for deformed vs. the unaltered samples from IBIS-Phantom (within-subject) and ICBM datasets (between subjects).

Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0


The resulting subtle, localized changes in the cortex in the four ROIs used in the present work is shown in videos which can be accessed on the GitHub repository:
https://github.com/aces/Simulation-toolkit/Sample-Videos-of-ROIsFour cubic ROIs are selected and the deformation are applied in these areas (in STEROTAXIC space) (top/left/back coordinates)
            ROI1: Sensory area (x,y,z:w) 11,-11,72
            ROI2: ACC (x,y,z:w) 8,44,8
            ROI3: Precuneus (x,y,z:w) -2,-63,35
            ROI4: Superior Temporal area (x,y,z:w) 65,-16,20
                  
We have also considered an ellipsoid ROI at the same position as ROI5 with size 10x5x5 mm

In order to replicate these results you must install SurfStat toolbox:
            http://www.math.mcgill.ca/keith/surfstat/

Data for this analysis are also available through our CBRAIN portal: https://portal.cbrain.mcgill.ca/ Please contact us for access. 



