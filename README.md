# Simulation-toolkit
A Simulation Toolkit for Testing the Sensitivity and Accuracy of Corticometry Pipelines


August 2019, Mona Omidyeganeh

This function evaluates the effect of deformation on CIVET/FS results
i.e. thicknesses for deformed vs. the unaltered IBIS-Phantom/ICBM datasets
Supported Versions CIVET: 2.0,2.1.0,2.1.1 and FreeSurfer 5.3 and 6.0

Usage:  sta = sta_june19_momid_v2(pipelinen, csv_filename, meter, sm_fwhm, ptv, ttv, c_centre, roi_right, roi_left, output_folder)

NOTE 1: before running code, you must have access to the CIVET_TaskForce_2016 directory thruogh ace_mount in your home directory

NOTE 2: Four cubic ROIs are selected and the deformation are applied in these areas (in STEROTAXIC space) (top/left/back coordinates)
            ROI1: Sensory area (x,y,z:w) 11,-11,72
            ROI2: ACC (x,y,z:w) 8,44,8
            ROI3: Precuneus (x,y,z:w) -2,-63,35
            ROI4: Superior Temporal area (x,y,z:w) 65,-16,20
NOTE 3: This function uses SrfStat toolbox:
            http://www.math.mcgill.ca/keith/surfstat/
NOTE 4: Please set phat and save the folders containing the surface
         samples and masks and CSV files.
