
subjects=(CrunchPilot01_development1)
#subjects=(ClarkPilot_01)

####### slice time ##############################
#preprocessing_steps=("slicetime_fmri")
##################################################

################ Fieldmap Stuff m#############################
#preprocessing_steps=("merge_distmap_fmri")
#preprocessing_steps=("create_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
#preprocessing_steps=("coregister_fmri_to_MeanFM")
###############################################################

############ DO Realign_unwarp ############
#preprocessing_steps=("realign_unwarp_fmri")
################################################################

############# coregister T1 to Mean (before segmenting T1 to put in same space as functional runs) ###########################
#preprocessing_steps=("coregister_t1_to_MeanFM")
################################################################

############## Segment and Skull Strip ##########################
#preprocessing_steps=("segment_fmri")
#preprocessing_steps=("segment_fmri" "skull_strip_t1")
################################################################

############## run artifact regression? tool ######################
#preprocessing_steps=("art_fmri") 
##################################################################

############## normalize fmri ###################################
preprocessing_steps=("spm_norm_fmri")  
#################################################################

############## smooth all fmri ########################################
#preprocessing_steps=("smooth_fmri")  
##################################################################

#preprocessing_steps=("segment_fmri" "skull_strip_t1" "spm_norm_fmri" "smooth_fmri") #  "segment_fmri" "skull_strip_t1" "spm_norm_fmri" "smooth_fmri"




# # # TO DO: 
# setup some code, maybe in file_organize to read dicom header info to compare parameters (slice order acq, total readout time, phase encoding) to json file
# create throw errors in different situations: 1) if file_settings.txt not created 2) ...
# remove means after realign and unwarp
# move coregistered2t1_unwarpedRealigned_coregistered2vdm_slicetimed_fMRI01_Run1,2,3,.. to ANTS processing folder 
# remove if slice_timed exists remove.. or determine a way to prevent matlab slice_timing from finding slice_timed_*
# try removing all default values from Ugrant_defaults.m
# automate population of XX_defaults.m 
# error system: error=1 if [ $error != 0 ]; then
# rename m_T1 to biascorrected
# create log (step run, time taken..)

# Set the path for our custom matlab functions and scripts
Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code


export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}
	cd "${Subject_dir}"

	lines_to_ignore=$(awk '/#/{print NR}' file_settings.txt)

	fmri_line_numbers_in_file_info=$(awk '/functional_run/{print NR}' file_settings.txt)
	fmri_fieldmap_line_numbers_in_file_info=$(awk '/fmri_fieldmap/{print NR}' file_settings.txt)
	t1_line_numbers_in_file_info=$(awk '/t1/{print NR}' file_settings.txt)

	fmri_line_numbers_to_process=$fmri_line_numbers_in_file_info
	fieldmap_line_numbers_to_process=$fmri_fieldmap_line_numbers_in_file_info
	t1_line_numbers_to_process=$t1_line_numbers_in_file_info

	this_index_fmri=0
	this_index_fieldmap=0
	this_index_t1=0
	for item_to_ignore in ${lines_to_ignore[@]}; do
		for item_to_check in ${fmri_line_numbers_in_file_info[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_fmri[$this_index_fmri]=$item_to_ignore
  				(( this_index_fmri++ ))
  			fi
  		done
  		for item_to_check in ${fieldmap_line_numbers_to_process[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_fieldmap[$this_index_fieldmap]=$item_to_ignore
  				(( this_index_fieldmap++ ))
  			fi
  		done
  		for item_to_check in ${t1_line_numbers_to_process[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_t1[$this_index_t1]=$item_to_ignore
  				(( this_index_t1++ ))
  			fi
  		done
	done

	for item_to_remove_fmri in ${remove_this_item_fmri[@]}; do
		fmri_line_numbers_to_process=$(echo ${fmri_line_numbers_to_process[@]/$item_to_remove_fmri})
	done
	for item_to_remove_fieldmap in ${remove_this_item_fieldmap[@]}; do
		fieldmap_line_numbers_to_process=$(echo ${fieldmap_line_numbers_to_process[@]/$item_to_remove_fieldmap})
	done
	for item_to_remove_t1 in ${remove_this_item_t1[@]}; do
		t1_line_numbers_to_process=$(echo ${t1_line_numbers_to_process[@]/$item_to_remove_t1})
	done


	this_index=0
	for this_line_number in ${fmri_line_numbers_to_process[@]}; do
		fmri_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	
	this_index=0
	for this_line_number in ${fieldmap_line_numbers_to_process[@]}; do
		fmri_fieldmap_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	
	this_index=0
	for this_line_number in ${t1_line_numbers_to_process[@]}; do
		t1_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	
	fmri_processed_folder_names=$(echo "${fmri_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	fmri_fieldmap_processed_folder_names=$(echo "${fmri_fieldmap_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	t1_processed_folder_names=$(echo "${t1_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')






	if [[ ${preprocessing_steps[*]} =~ "slicetime_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		#cd $Subject_dir/Processed/MRI_files
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			
			if [ -e slicetimed_*.nii ]; then 
				rm slicetimed_*.nii
			fi
			ml matlab
			matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
		done
		echo "This step took $SECONDS seconds to execute"
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

			this_file_header_info=$(fslhd AP_PA_merged.nii )
			this_file_number_of_slices=$(echo $this_file_header_info | grep -o dim3.* | tr -s ' ' | cut -d ' ' -f 2)

			if [ $((this_file_number_of_slices%2)) -ne 0 ]; then
				fslsplit AP_PA_merged.nii slice -z
				gunzip *nii.gz*
				rm slice0000.nii
				fslmerge -z AP_PA_merged slice0*
				rm slice00*.nii
			fi

			fslmaths AP_PA_merged.nii -Tmean Mean_AP_PA_merged.nii
			gunzip *nii.gz*

			cp Mean_AP_PA_merged.nii "${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}"
			(( this_loop_index++ ))
			
		done
		echo "This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_fieldmap_fmri" ]]; then
   		data_folder_to_analyze=($fmri_fieldmap_processed_folder_names)
	   	for this_fieldmap_folder in ${data_folder_to_analyze[@]}; do
	   		cd "${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/"
	   		# just cleaning up in case this is being rerun
	   		if [ -e my_fieldmap_nifti.nii ]; then 
	   			rm my_fieldmap_nifti.nii
	   		fi
	   		if [ -e acqParams.txt ]; then 
	   			rm acqParams.txt
	   		fi
	   		if [ -e my_fieldmap_mag.nii ]; then 
				rm my_fieldmap_mag.nii
			fi
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

			fslmaths se_epi_unwarped -Tmean my_fieldmap_mag

			ml fsl/5.0.8
			fslchfiletype ANALYZE my_fieldmap_nifti.nii fpm_my_fieldmap

			gunzip *nii.gz*
		done
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "create_vdm_fmri" ]]; then
		data_folder_to_analyze=($fmri_fieldmap_processed_folder_names)
		data_folder_to_copy_to=($fmri_processed_folder_names)
		data_folder_to_gather_info_from=($fmri_processed_folder_names)
   		this_loop_index=0
	   	for this_fieldmap_folder in ${data_folder_to_analyze[@]}; do
			cp ${Code_dir}/Matlab_Scripts/helper/vdm_defaults.m ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/
			cd ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/
			
			read_out=$(cat vdm_defaults.m)

			array[0]=$(echo $read_out | awk -F";" '{print $1}')
			array[1]=$(echo $read_out | awk -F";" '{print $2}')
			array[2]=$(echo $read_out | awk -F";" '{print $3}')
			array[3]=$(echo $read_out | awk -F";" '{print $4}')
			array[4]=$(echo $read_out | awk -F";" '{print $5}')
				
   			cd ${Subject_dir}/Processed/MRI_files/${data_folder_to_gather_info_from[$this_loop_index]}

   			for this_functional_run_file in *.json; do 
   				total_readout=$(grep "TotalReadoutTime" ${this_functional_run_file} | tr -dc '0.00-9.00')
				encoding_direction=$(grep "PhaseEncodingDirection" ${this_functional_run_file} | cut -d: -f 2 | head -1 | tr -d '"' |  tr -d ',')
				if [[ $encoding_direction =~ j- ]]; then
					array[2]="pm_def.K_SPACE_TRAVERSAL_BLIP_DIR = 0;"
				else
					array[2]="pm_def.K_SPACE_TRAVERSAL_BLIP_DIR = 1;"
				fi
  			break; done
  			#array[0] is fine 
			array[1]="pm_def.EPI_BASED_FIELDMAPS = 0;"
  			array[3]="pm_def.TOTAL_EPI_READOUT_TIME = $total_readout;"
  			array[4]="pm_def.DO_JACOBIAN_MODULATION = 0;"
			
			cd ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/
  			rm vdm_defaults.m
  			 			
  			echo ${array[0]} >> vdm_defaults.m
  			echo ${array[1]} >> vdm_defaults.m
  			echo ${array[2]} >> vdm_defaults.m
  			echo ${array[3]} >> vdm_defaults.m
  			echo ${array[4]} >> vdm_defaults.m
  		
			rm vdm_defaults.m
		done
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_fmri_to_MeanFM" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			ml matlab
			matlab -nodesktop -nosplash -r "try; coregister_fmri_to_MeanFM; catch; end; quit"
		done
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "realign_unwarp_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
			ml matlab
			matlab -nodesktop -nosplash -r "try; realign_unwarp_fmri; catch; end; quit"
		done
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "coregister_t1_to_MeanFM" ]]; then 
        
        data_folder_to_analyze=($t1_processed_folder_names)
        data_folder_to_copy_from=($fmri_fieldmap_processed_folder_names)
        for this_t1_folder in ${data_folder_to_analyze[@]}; do

        	cp ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}/Mean_AP_PA_merged.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
            
            cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
            
            ml matlab
            matlab -nodesktop -nosplash -r "try; coregister_t1_to_MeanFM; catch; end; quit"
        done
        "This step took $SECONDS seconds to execute"
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
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "skull_strip_t1" ]]; then
		data_folder_to_analyze=($t1_processed_folder_names)
		for this_t1_folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; skull_strip_t1; catch; end; quit"
		done
		"This step took $SECONDS seconds to execute"
	fi

	if [[ ${preprocessing_steps[*]} =~ "spm_norm_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		data_folder_to_copy_from=($t1_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}
			cp mT1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/

			cp ${Code_dir}/MR_Templates/_ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/

			cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			mv -v _ANTs_c0cTemplate_T1_IXI555_MNI152_GS_brain.nii this_template.nii
			# m_T1 is the bias_field corrected T1 

			cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
			
			rm mT1.nii
			rm this_template.nii
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
		"This step took $SECONDS seconds to execute"
	fi


	if [[ ${preprocessing_steps[*]} =~ "smooth_fmri" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
		done
	fi

done
