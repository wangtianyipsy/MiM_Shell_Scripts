#./Shell_Scripts/zip_t1_for_ceres.sh '2002,2007,2008,2012,2013,2015,2018,2020,2021,2022,2023,2025,2026'

argument_counter=0
for this_argument in "$@"; do
	if	[[ $argument_counter == 0 ]]; then
		subjects=$this_argument
	fi
	echo $subjects
	# Set the path for our custom matlab functions and scripts
	Code_dir=/blue/rachaelseidler/tfettrow/Crunch_Code
	
	export MATLABPATH=${Code_dir}/Matlab_Scripts/helper
	
	Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
	cd "${Study_dir}"

	while IFS=',' read -ra subject_list; do
   		for this_subject in "${subject_list[@]}"; do   			
   			cd ${Study_dir}/$this_subject/Processed/MRI_files/02_T1/
   			gunzip *nii.gz*
   			cp T1.nii ${this_subject}.nii
   			gzip ${this_subject}.nii
   			cp ${this_subject}.nii.gz ${Study_dir}/Ceres_Raw_T1/
   		done
	done <<< "$subjects"
done