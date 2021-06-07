#!/bin/sh -f
###############################################
#Mona Omidyeganeh
#To source minctool
#source /opt/minc/minc-toolkit-config.sh
###
#To source VanEedecode
#export PYTHONPATH=/opt/mcvaneede
#export PATH=/opt/mcvaneede/bin:$PATH
#export LD_LIBRARY_PATH=/opt/minc/lib
###############################################
#Inputs:
#   coord_list = Text file that contains the list of coordinates of the mask
#          note: since resample gets the coordinates as z y x so in the file they are in z y x order.
#   filename = Text file including list of minc file names;
#   ROI_ref = ROI reference image directory(directory contains ROIref.mnc);
#   imdir= Directory of images
#   deformation_size=size of deformation cube in mm (e.g. 10)
#   deformation_vector=Text file containing deformation amount
#   outdir=Directory of outputs
###############################################



crd_fl=$1
filename=$2
ROI_dir=$3
imdir=$4
w0=$5
deformation_vector=$6
outdir=$7

if [ $# -eq 0 ]
  then
    echo "This function generates graded cortical deformations with specific start coordinates and size for different GM painted ROIS"
    echo "Usage: ./localdeformation_simulationtoolkit.sh coordinates_list.txt minc_filenames_list.txt ROI_dir(directorycontaningROIs) minc_files_dir deformation_size deformation_vector.txt out_dir"
    exit 1
fi
mkdir $outdir
num=1;k=1;x=0;y=0;z=0;
w1=$((w0+6));
for i in `cat $coord_list` 
    do
    if  [ $k = 1 ] 
    then
        z=$i 
        k=2
    else
       if  [ $k = 2 ]
       then 
        y=$i 
        k=3
        else  
           x=$i
           k=1
           echo $x","$y","$z
           xp=$((x-6));
           yp=$((y-6));
           zp=$((z-6));
           echo $xp","$yp","$zp
           #########################################################################
           OUTDIR0=$outdir"/size"$w0"_ROI"$num"/";
           mkdir $OUTDIR0
           OUTDIR=$outdir"/size"$w0"_ROI"$num"/xfm/";
           mkdir $OUTDIR
           #########################################################################
           #Creating the ROI mask and parking area
           mincreshape $ROI_dir"/ROIref.mnc" $OUTDIR"/ROI"$num"_size"$w0".mnc" -start $z,$y,$x -count $w0,$w0,$w0 -clobber
           mincresample -like $ROI_dir"/ROI"$num"_mask.mnc" $OUTDIR"/ROI"$num"_size"$w0".mnc" $OUTDIR"/ROI"$num"_size"$w0"_mask.mnc" -clobber
           minccalc -expression "A[0]==0 ? 0:A[1]" $OUTDIR"/ROI"$num"_size"$w0"_mask.mnc" $ROI_dir"/ROI"$num"_mask.mnc" $OUTDIR"/ROI"$num"_size"$w0"_labeled.mnc" -clobber
           #########################################################################
           mincreshape $ROI_dir"/ROI"$num"_mask.mnc" $OUTDIR"/ROI"$num"_size"$w0"_park0.mnc" -start $zp,$yp,$xp -count $w1,$w1,$w1 -clobber
           mincresample -like $ROI_dir"/ROI"$num"_mask.mnc" $OUTDIR"/ROI"$num"_size"$w0"_park0.mnc" $OUTDIR"/ROI"$num"_size"$w0"_mask_park.mnc" -clobber
           minccalc -expression "A[0]==0 ? A[1]:0" $OUTDIR"/ROI"$num"_size"$w0"_mask.mnc" $OUTDIR"/ROI"$num"_size"$w0"_mask_park.mnc" $OUTDIR"/ROI"$num"_size"$w0"_park.mnc" -clobber
           #########################################################################
           n=1;
           while read -r line 
             do
             ratio=$line;
             ###Calculate determinant fielss
             minccalc -expression "A[0]==1 ? "$ratio" : 1" $OUTDIR"/ROI"$num"_size"$w0"_labeled.mnc" $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_determinant.mnc" -clobber -quiet
             ######################################################
	     create_deformation.py -t 0.00001 -i 100000 -m $OUTDIR"/ROI"$num"_size"$w0"_park.mnc" $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_determinant.mnc" $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field.xfm"  
	     mincblob  -det $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field_grid.mnc" $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field_grid_determinant.mnc" -clobber
	     mincmath -add -const 1 $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field_grid_determinant.mnc" $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field_grid_determinant_plus_one.mnc" -clobber -quiet
             #########################################################
             ###for each MRI image
             while read -r line
                do
                inname=$line; 
	        imname=$imdir"/civet_"$inname"_t1_final.mnc"
	        echo "*******************************\n ***\n ***\n ***\n File name - $imname - ROI $num"
                mincresample -like $imname -transformation $OUTDIR"/roi"$num"_s"$w0"_r"$ratio"_deformation_field.xfm" $imname $OUTDIR0"/"$inname"_roi"$num"_s"$w0"_r"$ratio".mnc" -clobber -quiet
                minccalc -expression "A[0]-A[1]" $imname $OUTDIR0"/"$inname"_roi"$num"_s"$w0"_r"$ratio".mnc" $OUTDIR0"/diff_"$inname"_roi"$num"_s"$w0"_r"$ratio"_deformed.mnc" -clobber
                done < "$filename"
             n=$((n+1));
          done < "$deformation_vector"
          num=$((num+1))
        fi
      fi       
done
