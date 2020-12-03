
argument_counter=0
for this_argument in "$@"
do
	if	[[ $argument_counter == 0 ]]; then
    	subject=$this_argument
	else
		processing_steps="$this_argument"
	fi
	
	# Set the path for our custom matlab functions and scripts
	Code_dir=/blue/rachaelseidler/tfettrow/Crunch_Code
	
	export MATLABPATH=${Code_dir}/Matlab_Scripts/helper
	
	Subject_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/${subject}
	cd "${Subject_dir}"

	lines_to_ignore=$(awk '/#/{print NR}' file_settings.txt)

	t1_line_numbers_in_file_info=$(awk '/t1/{print NR}' file_settings.txt)

	t1_line_numbers_to_process=$t1_line_numbers_in_file_info

	this_index_t1=0
	for item_to_ignore in ${lines_to_ignore[@]}; do
  		for item_to_check in ${t1_line_numbers_to_process[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_t1[$this_index_t1]=$item_to_ignore
  				(( this_index_t1++ ))
  			fi
  		done
	done

	for item_to_remove_t1 in ${remove_this_item_t1[@]}; do
		t1_line_numbers_to_process=$(echo ${t1_line_numbers_to_process[@]/$item_to_remove_t1})
	done
	
	this_index=0
	for this_line_number in ${t1_line_numbers_to_process[@]}; do
		t1_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	
	t1_processed_folder_names=$(echo "${t1_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	
	for this_preprocessing_step in "${processing_steps[@]}"; do
		if [[ $this_preprocessing_step == "cat12StructuralAnalysis" ]]; then
			this_t1_folder=($t1_processed_folder_names)
		    mkdir -p ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/CAT12_Analysis
		    #cat12('expert')
			cp ${Code_dir}/MR_Templates/Template_*.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/CAT12_Analysis
			cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/CAT12_Analysis
			cp ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/T1.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/CAT12_Analysis
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}
			ml matlab/2020a
			matlab -nodesktop -nosplash -r "try; cat12StructuralAnalysis; catch; end; quit"
		fi

	done
	(( argument_counter++ ))
done