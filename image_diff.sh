subjects=(CrunchPilot03)
data_folder_to_analyze=(05_MotorImagery)
file_to_compare_1='meanunwarpedRealigned_slicetimed_fMRI01Run1'
file_to_compare_2='meanunwarpedRealigned_slicetimedMBtiming_fMRI01Run1'
volume=1

export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper

		
cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/$subjects/Processed/MRI_files/$data_folder_to_analyze/

#cd ..

#pwd

ml matlab
matlab -nodesktop -nosplash -r "try; image_diff $file_to_compare_1 $file_to_compare_2 $volume; catch; end; quit"
