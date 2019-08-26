subjects=(CrunchPilot03)
data_folder_to_analyze=(05_MotorImagery)
file_to_compare_1='slicetimed_fMRI01_Run2.nii'
file_to_compare_2='slicetimedManualBatch_fMRI01_Run2.nii'
#volume=1
export MATLABPATH=/ufrc/rachaelseidler/tfettrow/Crunch_Code/Matlab_Scripts/helper
		
cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/$subjects/Processed/MRI_files/$data_folder_to_analyze

fslmaths $file_to_compare_1 -sub $file_to_compare_2 imdiff_manualCheck_run2

gunzip *.nii.gz*
