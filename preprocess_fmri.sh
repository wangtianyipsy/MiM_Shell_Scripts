
subjects=(CrunchPilot01_development1)
#subjects=(ClarkPilot_01)

#preprocessing_steps=("slicetime_fmri")
#preprocessing_steps=("merge_distmap_fmri")
#preprocessing_steps=("create_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("coregister_fmri_to_MeanFM")
#preprocessing_steps=("realign_fmri")
#preprocessing_steps=("realign_unwarp_fmri")
#preprocessing_steps=("apply_vdm_fmri")

#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("skull_strip_t1")

#preprocessing_steps=("coregister_fmri_to_T1") # this is for 

preprocessing_steps=("art_fmri") # implement in conn


# in progress.. 
####preprocessing_steps=("spm_norm_fmri")  # replace the y_T1 with Ants output??
####preprocessing_steps=("smooth_fmri")  # how to decide which norms to smooth?? look for both??



# # # TO DO: 
# setup some code, maybe in file_organize to read dicom header info to compare parameters (slice order acq, total readout time, phase encoding) to json file
# create throw errors in different situations: 1) if file_info.csv not created 2) ...
# remove means after realign and unwarp
# move coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1,2,3,.. to ANTS processing folder 

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

	fmri_fieldmap_line_numbers_in_file_info=$(awk '/fmri_fieldmap/{print NR}' ${SUB}_file_information.csv)
	this_index=0
	for this_line_number in ${fmri_fieldmap_line_numbers_in_file_info[@]}; do
		fmri_fieldmap_processed_folder_name_array[$this_index]=$(cat ${SUB}_file_information.csv | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	fmri_fieldmap_processed_folder_names=$(echo "${fmri_fieldmap_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')


	t1_line_numbers_in_file_info=$(awk '/t1/{print NR}' ${SUB}_file_information.csv)
	this_index=0
	for this_line_number in ${t1_line_numbers_in_file_info[@]}; do
		t1_processed_folder_name_array[$this_index]=$(cat ${SUB}_file_information.csv | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	t1_processed_folder_names=$(echo "${t1_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')




	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		#cd $Subject_dir/Processed/MRI_files
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			
			ml matlab
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
		done
	fi
   	if [[ ${preprocessing_steps[*]} =~ "merge_distmap_fmri" ]]; then
   		data_folder_to_analyze=($fmri_fieldmap_processed_folder_names)
   		data_folder_to_copy_to=($fmri_processed_folder_names)
   		this_loop_index=0
	   	for this_fieldmap_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/"
			
			# just cleaning up in case this is being rerun
			if [ -e AP_PA_merged.nii ]; then 
				rm AP_PA_merged.nii
			fi
			if [ -e Mean_AP_PA_merged.nii ]; then 
				rm Mean_AP_PA_merged.nii
			fi
			if [ -e se_epi_unwarped.nii ]; then 
				rm se_epi_unwarped.nii
			fi 
			if [ -e topup_results_fieldcoef.nii ]; then 
				rm topup_results_fieldcoef.nii
			fi
			if [ -e topup_results_movpar.txt ]; then 
				rm topup_results_movpar.txt
			fi
			
			ml fsl
			fslmerge -t AP_PA_merged.nii DistMap_AP.nii DistMap_PA.nii

			fslmaths AP_PA_merged.nii -Tmean Mean_AP_PA_merged.nii
			gunzip *nii.gz*

			cp Mean_AP_PA_merged.nii "${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}"
			(( this_loop_index++ ))
			
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=($fmri_fieldmap_processed_folder_names)
	   	for this_fieldmap_folder in ${data_folder_to_analyze[@]}; do
	   		cd "${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/"
	   		# just cleaning up in case this is being rerun
	   		rm my_fieldmap.nii
  			rm acqParams.txt

			# assuming only the DistMaps have .jsons in this folder
			for this_json_file in *.json*; do
									
				total_readout=$(grep "TotalReadoutTime" ${this_json_file} | tr -dc '0.00-9.00')
				encoding_direction=$(grep "PhaseEncodingDirection" ${this_json_file} | cut -d: -f 2 | head -1 | tr -d '"' |  tr -d ',')
				
				this_file_name=$(echo $this_json_file | cut -d. -f 1)
				ml fsl
				this_file_header_info=$(fslhd $this_file_name.nii)
				this_file_number_of_volumes=$(echo $this_file_header_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)

				for (( this_volume=1; this_volume<=$this_file_number_of_volumes; this_volume++ )); do
					if [[ $encoding_direction =~ j- ]]; then
						echo 0 -1 0 ${total_readout} >> acqParams.txt
					else
						echo 0 1 0 ${total_readout} >> acqParams.txt
					fi
				done
			done

			ml fsl
			topup --imain=AP_PA_merged.nii --datain=acqParams.txt --fout=my_fieldmap_nifti --config=b02b0.cnf --iout=se_epi_unwarped --out=topup_results
	
			ml fsl/5.0.8
			fslchfiletype ANALYZE my_fieldmap_nifti.nii my_fieldmap

			gunzip *nii.gz*
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=($fmri_fieldmap_processed_folder_names)
		data_folder_to_copy_to=($fmri_processed_folder_names)
   		this_loop_index=0
	   	for this_fieldmap_folder in ${data_folder_to_analyze[@]}; do
   			cp ${Code_dir}/Matlab_Scripts/helper/Ugrant_defaults.m ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/
			cd ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/ 

			ml matlab
			matlab -nodesktop -nosplash -r "try; create_vdm_img; catch; end; quit"
			matlab -nodesktop -nosplash -r "try; create_vdm_nifti; catch; end; quit"

			# needs to be an .img in case you want to try and use it...
			cp vdm5_my_fieldmap.hdr "${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}"
			cp vdm5_my_fieldmap.img "${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}"
			(( this_loop_index++ ))

			rm Ugrant_defaults.m
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_MeanFM" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			pwd
			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_MeanFM; catch; end; quit"
			
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_fmri; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_unwarp_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_unwarp_fmri; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "apply_vdm_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			ml matlab
			matlab -nodesktop -nosplash -r "try; apply_vdm; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "segment_fmri" ]]; then
		data_folder_to_analyze=($t1_processed_folder_names)
		for this_t1_folder in ${data_folder_to_analyze[@]}; do
			cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; segment_fmri; catch; end; quit"
			rm TPM.nii
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "skull_strip_t1" ]]; then
		data_folder_to_analyze=($t1_processed_folder_names)
		for this_t1_folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; skull_strip_t1; catch; end; quit"
		done
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_T1" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		data_folder_to_copy_from=($t1_processed_folder_names)

		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cp "${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}/SkullStripped_T1.nii" "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"

			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_t1; catch; end; quit"
	
			rm SkullStripped_biascorrected.nii
		done
	fi
	
	if [[ ${preprocessing_steps[*]} =~ "art_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		data_folder_to_copy_from=($t1_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cp ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}/T1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/

			ml matlab
			matlab -nodesktop -nosplash -r "try; art_fmri; catch; end; quit"

			rm T1.nii
			rm Conn_Art_Folder_Stuff.mat
			rm -rf Conn_Art_Folder_Stuff
			
		done
	fi

	#if [[ ${preprocessing_steps[*]} =~ "spm_norm_fmri" ]]; then
	#	data_folder_to_analyze=($fmri_processed_folder_names)
	#	data_folder_to_copy_from=($t1_processed_folder_names)
   	#	this_loop_index=0
	#	for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
	#		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/02_T1
	#		cp y_T1.nii /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${this_functional_run_folder}/
	#		cd /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}/Processed/MRI_files/${this_functional_run_folder}/
	#		ml matlab
	#		matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
	#		rm y_T1.nii
	#	done
	#fi

	#if [[ ${preprocessing_steps[*]} =~ "smooth_fmri" ]]; then
	#	data_folder_to_analyze=($fmri_processed_folder_names)
	#	for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
	#		cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
	#		ml matlab
	#		matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
	#	done
	#fi

done