subjects=(CrunchPilot01_development1)

preprocessing_steps=("slicetime_fmri")

# Set the path for our custom matlab functions and scripts
Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code


export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}
	cd "${Subject_dir}"

	fmri_line_numbers_in_file_info=$(awk '/functional_run/{print NR}' ${SUB}_file_information.csv)
	this_index=0
	for this_line_number in ${fmri_line_numbers_in_file_info[@]}; do
		fmri_processed_folder_name_array[$this_index]=$(cat ${SUB}_file_information.csv | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	fmri_processed_folder_names=$(echo "${fmri_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')


	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		#cd $Subject_dir/Processed/MRI_files
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"

			if [ -e slicetimed_*.nii ]; then 
				rm slicetimed_*.nii
			fi
			
			ml parallel
			ml matlab
			for file in fMRI_Run*.nii*; do
				this_file_name=${file%.*}
				echo $this_file_name

				parallel --will-cite --jobs 3 matlab -nodesktop -nosplash -r "try; slicetime_fmri_parallel_dev('$this_file_name'); catch; end; quit"

				#matlab -nodesktop -nosplash -r "try; slicetime_fmri_parallel_dev('$this_file_name'); catch; end; quit"
			done

		done
		echo "This step took $SECONDS seconds to execute"
	fi

done