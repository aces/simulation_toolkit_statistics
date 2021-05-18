# Simulation-toolkit
A Simulation Toolkit for Testing the Sensitivity and Accuracy of Corticometry Pipelines


August 2019, Mona Omidyeganeh

This function evaluates the effect of deformation on CIVET/FS results
i.e. thicknesses for deformed vs. the unaltered IBIS-Phantom/ICBM datasets
Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0


NOTE 1: before running code, you must have access to the CIVET_TaskForce_2016 directory thruogh ace_mount in your home directory
NOTE 2: Four cubic ROIs are selected and the deformation are applied in these areas (in STEROTAXIC space) (top/left/back coordinates)
            ROI1: Sensory area (x,y,z:w)
            ROI2: ACC (x,y,z:w)
            ROI3: Precuneus (x,y,z:w)
            ROI4: Superior Temporal area
NOTE 3: This function uses SrfStat toolbox:
            http://www.math.mcgill.ca/keith/surfstat/
NOTE 4: The unaltered and deformed surfaces are available at CBRAIN portal: https://portal.cbrain.mcgill.ca/ in cortical deformation project.

The resulting subtle, localized changes in the cortex in the four ROIs used in the present work is shown in videos which can be accessed on the GitHub repository:
https://github.com/aces/Simulation-toolkit/tree/monaomid-Sample-Videos-of-ROIs
