# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#subjects=(1002)
#subjects=(1004)
#subjects=(1011)
subjects=(2015)
#subjects=(2018)
# 1011 2015 2018
#subjects=(CrunchPilot01)
#subjects=(ClarkPilot_01)

####### slice time ##############################
#preprocessing_steps=("slicetime_fmri")
##################################################

################ Fieldmap Stuff m#############################
#preprocessing_steps=("merge_distmap_fmri")
#preprocessing_steps=("create_fieldmap_fmri")
#preprocessing_steps=("create_vdm_fmri")
###############################################################

###############################################################
#preprocessing_steps=("coregister_fmri_to_MeanFM")
###############################################################

############ DO Realign_unwarp #############
#preprocessing_steps=("realign_unwarp_fmri")
################################################################

############## run artifact regression? tool ######################
#preprocessing_steps=("art_fmri") 
##################################################################

############## outlier removal ######################
#preprocessing_steps=("remove_outlier_volumes")
##################################################################

############# coregister T1 to Mean Func or MeanFM (TF is using MeanFM) ###########################
#preprocessing_steps=("coregister_t1_to_MeanFM")
################################################################

############## Segment ##########################
#preprocessing_steps=("segment_t1")
################################################################

############## spm normalize stuff ###################################
preprocessing_steps=("spm_norm_fmri" "smooth_fmri")
#preprocessing_steps=("spm_norm_t1")  
#################################################################

############## smooth all fmri ########################################
#preprocessing_steps=("smooth_fmri")  
#preprocessing_steps=("smooth_t1")
##################################################################

##################### skull strip ########################################
#preprocessing_steps=("skull_strip_t1_4_ants")
######################################################################

############# ANTS normlize stuff ###############################
#preprocessing_steps=("n4_bias_correction")
#preprocessing_steps=("ants_registration_Func_2_T1")
#preprocessing_steps=("ants_apply_transform_Func_2_T1")
#preprocessing_steps=("ants_registration_Func_2_T1" "ants_apply_transform_Func_2_T1")
#preprocessing_steps=("ants_registration_T1_2_MNI")
preprocessing_steps=("ants_apply_transform_T1_2_MNI" "ants_apply_transform_Func_2_MNI")
#preprocessing_steps=("ants_apply_transform_Func_2_MNI")
#################################################################

############## level one stats ########################################
#preprocessing_steps=("level_one_stats")
##################################################################



#preprocessing_steps=("coregister_t1_to_MeanFM" "segment_t1" "spm_norm_fmri" "smooth_fmri")
#preprocessing_steps=("slicetime_fmri" "merge_distmap_fmri" "create_fieldmap_fmri" "create_vdm_fmri" "coregister_fmri_to_MeanFM" "realign_unwarp_fmri" "art_fmri") #  "segment_t1" "skull_strip_t1" "spm_norm_fmri" "smooth_fmri"
#preprocessing_steps=("realign_unwarp_fmri" "art_fmri" "remove_outlier_volumes")

# # # TO DO: 
# setup some code, maybe in file_organize to read dicom header info to compare parameters (slice order acq, total readout time, phase encoding) to json file
# create throw errors in different situations: 1) if file_settings.txt not created 2) ...
# grab age and sex info from somewhere
# error system: error=1 if [ $error != 0 ]; then
# ignore empty lines when reading file_settings.. some reason really difficult..

# create Results file for SPM betas and contrasts

# removing outliers TO DO: (probably needs to be a combo of fsl (split) and matlab (art) )
# 1) do something like this for  % remove initial white space
         #while ~isempty(this_line) && (this_line(1) == ' ' || double(this_line(1)) == 9)
         #    this_line(1) = [];
         #end
# 2) # setup some code, maybe in file_organize to read dicom header info to compare parameters (slice order acq, total readout time, phase encoding) to json file
# create throw errors in different situations: 1) if file_settings.txt not created 2) ...
# grab age and sex info from somewhere
# create option to run MVT and ANTSreg locally or batch
# what is a dilated segmentation??
# implement 06_Nback
# implement multiple runs
# shorten file paths (create groupAnts_dir and subjectAnts_dir)
# Func -> T1 -> MVT -> MNI  
# adjust MVT file output name to Sub_T1_to_MVT
# move them to the "processing folder" and change file name to include subjectI
# move .batch to "processing folder" 
# module load everything at top


# Set the path for our custom matlab functions and scripts
Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code


export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


for SUB in ${subjects[@]}; do
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/${SUB}
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


	for this_preprocessing_step in "${preprocessing_steps[@]}"; do
		if [[ $this_preprocessing_step == "slicetime_fmri" ]]; then
			run_slicetime ()
			{ 	
				cd "$1/Processed/MRI_files/$2/"
				
				if [ -e slicetimed_*.nii ]; then 
					rm slicetimed_*.nii
				fi
				ml matlab
				matlab -nodesktop -nosplash -r "try; slicetime_fmri; catch; end; quit"
			}
			export -f run_slicetime	
			
			data_folder_to_analyze=($fmri_processed_folder_names)
			ml parallel
  			parallel --will-cite 'run_slicetime' ::: "${Subject_dir}" ::: "${data_folder_to_analyze[@]}"

			echo "This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Slice Time: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
   		if [[ $this_preprocessing_step == "merge_distmap_fmri" ]]; then
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
			cd "${Subject_dir}"
			echo "Merging Fieldmaps: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "create_fieldmap_fmri" ]]; then
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
			cd "${Subject_dir}"
			echo "Fieldmap Creation: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "create_vdm_fmri" ]]; then
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
   					total_readout_sec=$(grep "TotalReadoutTime" ${this_functional_run_file} | tr -dc '0.00-9.00')
					encoding_direction=$(grep "PhaseEncodingDirection" ${this_functional_run_file} | cut -d: -f 2 | head -1 | tr -d '"' |  tr -d ',')
					if [[ $encoding_direction =~ j- ]]; then
						array[2]="pm_def.K_SPACE_TRAVERSAL_BLIP_DIR = 0;"
					else
						array[2]="pm_def.K_SPACE_TRAVERSAL_BLIP_DIR = 1;"
					fi
  				break; done
  				#array[0] is fine 
  				#d1d2=$(echo "$d1 + $d2" | bc)
  				#total_readout_ms=$(( 1000*$total_readout_sec ))
  				total_readout_ms=$(echo "1000 * $total_readout_sec" | bc )
  				
  				echo $total_readout_ms
				array[1]="pm_def.EPI_BASED_FIELDMAPS = 0;"
  				array[3]="pm_def.TOTAL_EPI_READOUT_TIME = $total_readout_ms;"
  				array[4]="pm_def.DO_JACOBIAN_MODULATION = 0;"
				
				cd ${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/
  				rm vdm_defaults.m
  				 			
  				echo ${array[0]} >> vdm_defaults.m
  				echo ${array[1]} >> vdm_defaults.m
  				echo ${array[2]} >> vdm_defaults.m
  				echo ${array[3]} >> vdm_defaults.m
  				echo ${array[4]} >> vdm_defaults.m
	
    	        ml matlab
    	        matlab -nodesktop -nosplash -r "try; create_vdm_img; catch; end; quit"
    	        matlab -nodesktop -nosplash -r "try; create_vdm_nifti; catch; end; quit"
	
    	        # needs to be an .img in case you want to try and use it...
    	        cp vdm5_fpm_my_fieldmap.hdr ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}
    	        cp vdm5_fpm_my_fieldmap.img ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_to[$this_loop_index]}
    	        (( this_loop_index++ ))
	
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Create VDM: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "coregister_fmri_to_MeanFM" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
				ml matlab
				matlab -nodesktop -nosplash -r "try; coregister_fmri_to_MeanFM; catch; end; quit"
				#matlab -nodesktop -nosplash -r "try; coregisterWrite_fmri_to_MeanFM; catch; end; quit"
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Coregiser fmri to Mean FM: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "realign_unwarp_fmri" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd "${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/"
				ml matlab
				matlab -nodesktop -nosplash -r "try; realign_unwarp_fmri; catch; end; quit"
				
				for this_rp_file in rp_*.txt; do
					if ! [[ $this_rp_file =~ "unwarpedRealigned" ]]; then
						this_filename_1=$(echo $this_rp_file | cut -d'_' -f1)
						this_filename_2=$(echo $this_rp_file | cut -d'_' -f2)
						this_filename_3=$(echo $this_rp_file | cut -d'_' -f3)
						this_filename_4=$(echo $this_rp_file | cut -d'_' -f4)
						mv -v $this_rp_file ${this_filename_1}_unwarpedRealigned_${this_filename_2}_${this_filename_3}_${this_filename_4}
					fi
				done
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Realign and Unwarp: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "art_fmri" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			data_folder_to_copy_from=($t1_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
	
				cp ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}/T1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
			
				for this_rp_file in rp_*.txt; do
					if ! [[ $this_rp_file =~ "unwarpedRealigned" ]]; then
						this_filename_1=$(echo $this_rp_file | cut -d'_' -f1)
						this_filename_2=$(echo $this_rp_file | cut -d'_' -f2)
						this_filename_3=$(echo $this_rp_file | cut -d'_' -f3)
						this_filename_4=$(echo $this_rp_file | cut -d'_' -f4)
						mv -v $this_rp_file ${this_filename_1}_unwarpedRealigned_${this_filename_2}_${this_filename_3}_${this_filename_4}
					fi
				done
	
				for this_functional_file in unwarpedRealigned*.nii; do
					ml matlab
					matlab -nodesktop -nosplash -r "try; art_fmri('$this_functional_file'); catch; end; quit"
		
					rm T1.nii
					rm -rf Conn_Art_Folder_Stuff
    				rm Conn_Art_Folder_Stuff.mat
    				rm art_mask.hdr
    				rm art_mask.img
				done
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Artifact Regression Tool: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "remove_outlier_volumes" ]]; then
			lines_to_ignore=$(awk '/#/{print NR}' outlier_removal_settings.txt)
			line_numbers_to_process=$(awk 'END{print NR}' outlier_removal_settings.txt)
			
			#this_index=0
			for (( this_line_number=1; this_line_number<=${line_numbers_to_process}; this_line_number++ )); do
				if ! [[ ${lines_to_ignore[*]} =~ $this_line_number ]]; then
					processed_folder_name_array=$(cat outlier_removal_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f1)
					run_number_array=$(cat outlier_removal_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
					first_index_array=$(cat outlier_removal_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f3)
					last_index_array=$(cat outlier_removal_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f4)
					processed_folder_names=$(echo "${processed_folder_name_array[@]}" | tr '' '\n' )

					for this_processed_folder in $processed_folder_names; do
						cd "${Subject_dir}/Processed/MRI_files/${this_processed_folder}"
		
						for this_slicetimed_file in slicetimed*.nii; do
							this_slicetimed_file_runnumber=$(echo "$this_slicetimed_file" | grep -o '[0-9]\+')
							echo $this_slicetimed_file_runnumber
							if [[ $this_slicetimed_file_runnumber =~ ${run_number_array} ]]; then
								ml fsl
								## need to check the length of slicetimed run with respect to raw.. if already changed throw an error
								this_slicetimed_file_corename=$(echo $this_slicetimed_file | cut -d. -f 1)
								this_raw_file_name=$(echo $this_slicetimed_file | cut -d_ -f2-)
		
								this_slicetimed_file_info=$(fslhd $this_slicetimed_file)
								this_slicetimed_file_number_of_volumes=$(echo $this_slicetimed_file_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)

								this_raw_file_info=$(fslhd $this_raw_file_name)
								this_raw_file_number_of_volumes=$(echo $this_raw_file_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)

								if ! [[ $this_slicetimed_file_number_of_volumes = $this_raw_file_number_of_volumes ]]; then
									echo "Warning:" $this_slicetimed_file_corename "in" $processed_folder_names "WAS ALREADY ADJUSTED!!!"
									#exit 1
								else
									fslsplit $this_slicetimed_file
									this_volume_index=0
									for this_volume_file in vol*; do
										if ! [[ ${first_index_array} =~ NA ]]; then 
											if [[ $this_volume_index -lt ${first_index_array} ]]; then
												rm $this_volume_file
												#echo $this_volume_file
											fi
										fi
										if ! [[ ${last_index_array} =~ NA ]]; then 
											if [[ ${last_index_array} -lt ${this_volume_index} ]]; then
												rm $this_volume_file
												#echo $this_volume_file
											fi
										fi
										(( this_volume_index++ ))
									done
			
									rm ${this_slicetimed_file_corename}.nii
									rm unwarpedRealigned_${this_slicetimed_file_corename}.nii
									rm rp_unwarpedRealigned_${this_slicetimed_file_corename}.txt
					
									fslmerge -a $this_slicetimed_file vol*
									rm vol*
									gunzip *nii.gz*
									
									ml matlab			
									## re-coregister slicetimed to mean_Distmap only if removing start of run (bc we coreg first volume to Distmap)
									if ! [[ ${first_index_array} =~ NA ]]; then 
										matlab -nodesktop -nosplash -r "try; coregister_fmri_to_MeanFM_single('$this_slicetimed_file'); catch; end; quit"
									fi
					
									matlab -nodesktop -nosplash -r "try; realign_unwarp_single('$this_slicetimed_file'); catch; end; quit"
								
									for this_rp_file in rp_*.txt; do
										if ! [[ $this_rp_file =~ "unwarpedRealigned" ]]; then
											this_filename_1=$(echo $this_rp_file | cut -d'_' -f1)
											this_filename_2=$(echo $this_rp_file | cut -d'_' -f2)
											this_filename_3=$(echo $this_rp_file | cut -d'_' -f3)
											this_filename_4=$(echo $this_rp_file | cut -d'_' -f4)
											mv -v $this_rp_file ${this_filename_1}_unwarpedRealigned_${this_filename_2}_${this_filename_3}_${this_filename_4}
										fi
									done
						
									matlab -nodesktop -nosplash -r "try; art_fmri('unwarpedRealigned_${this_slicetimed_file}'); catch; end; quit"
									rm T1.nii
									rm -rf Conn_Art_Folder_Stuff
    								rm Conn_Art_Folder_Stuff.mat
    								rm art_mask.hdr
    								rm art_mask.img
    							fi
							fi
						done
					done
				fi
				cd "${Subject_dir}"
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Outlier Removal: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "coregister_t1_to_MeanFM" ]]; then 
    	    
    	    this_t1_folder=($t1_processed_folder_names)
    	    for this_fieldmap_folder in ${fmri_fieldmap_processed_folder_names[@]}; do
    	    	mkdir -p "${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder"
    	    	cp "${Subject_dir}/Processed/MRI_files/${this_t1_folder}/T1.nii" "${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder"
    	    	cp "${Subject_dir}/Processed/MRI_files/${this_fieldmap_folder}/Mean_AP_PA_merged.nii" "${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder"
    	    	cd "${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder"
    	    	ml matlab
    	    	matlab -nodesktop -nosplash -r "try; coregister_t1_to_MeanFM; catch; end; quit"
    	    done
	
    	    "This step took $SECONDS seconds to execute"
    	    cd "${Subject_dir}"
			echo "Coregiser t1 to Mean FM: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
    	fi
	
		if [[ $this_preprocessing_step == "segment_t1" ]]; then
			#this needs to go into t1 folder and then for each fieldmap folder go into the t1 sub folder for that fieldmap
			this_t1_folder=($t1_processed_folder_names)
			for this_fieldmap_folder in ${fmri_fieldmap_processed_folder_names[@]}; do
				cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder
				cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder
	
				ml matlab
				matlab -nodesktop -nosplash -r "try; segment_t1; catch; end; quit"
				rm TPM.nii
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Segment T1: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "spm_norm_fmri" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			data_folder_to_copy_from=($t1_processed_folder_names)
			this_loop_index=0
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				
				cd ${Subject_dir}/Processed/MRI_files/${data_folder_to_copy_from}/Coregistered2_${fmri_fieldmap_processed_folder_names[$this_loop_index]}
				
				cp y_T1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
				
				ml matlab
				matlab -nodesktop -nosplash -r "try; spm_norm_fmri; catch; end; quit"
				(( this_loop_index++ ))
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "fMRI Normalization: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "spm_norm_t1" ]]; then
			this_t1_folder=($t1_processed_folder_names)
			for this_fieldmap_folder in ${fmri_fieldmap_processed_folder_names[@]}; do			
				cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/Coregistered2_$this_fieldmap_folder
				
				ml matlab
				matlab -nodesktop -nosplash -r "try; spm_norm_t1; catch; end; quit"
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "T1 Normalization: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "smooth_fmri" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/
				ml matlab
				matlab -nodesktop -nosplash -r "try; smooth_fmri; catch; end; quit"
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Smoothing: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "level_one_stats" ]]; then

			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}
				for this_functional_run_file in *.json; do 
					TR_from_json=$(grep "RepetitionTime" ${this_functional_run_file} | tr -dc '0.00-9.00')
  				break; done
  				ml matlab
    			matlab -nodesktop -nosplash -r "try; level_one_stats('$TR_from_json'); catch; end; quit"
    		done
    		"This step took $SECONDS seconds to execute"
    		cd "${Subject_dir}"
			echo "Smoothing: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "skull_strip_t1_4_ants" ]]; then
			this_t1_folder=($t1_processed_folder_names)
			cp ${Code_dir}/MR_Templates/TPM.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			ml matlab
			matlab -nodesktop -nosplash -r "try; segment_t1; catch; end; quit"
			matlab -nodesktop -nosplash -r "try; skull_strip_t1; catch; end; quit"
	
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Skull Strip T1: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi


		if [[ $this_preprocessing_step == "n4_bias_correction" ]]; then
			n4biascorrect ()
			{ 	
				N4BiasFieldCorrection -i $1 -o biascorrected_$1
				#echo biascorrected_$1
			}
			export -f n4biascorrect	

			this_t1_folder=($t1_processed_folder_names)
			cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/
			ml gcc/5.2.0; ml ants
			ml parallel
			#parallel --will-cite N4BiasFieldCorrection -i {} -o biascorrected_{} ::: SkullStripped_T1.nii
			#n4biascorrect $this_file_to_biascorrect &

			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				mkdir -p ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_t1_folder}/SkullStripped_T1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/meanunwarpedRealigned*.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				# for each run in this functional folder, bias correct and place in ANTS folder
				this_file_to_biascorrect[0]=SkullStripped_T1.nii
				#this index is here only because including skullstripped in parallel.. probably can get around this
				index=0;
				for this_func_file in meanunwarpedRealigned*.nii; do 
					if [[ $index =~ 0 ]]; then
						this_file_to_biascorrect[1]=$this_func_file
					fi
					if [[ $index =~ 1 ]]; then
						this_file_to_biascorrect[2]=$this_func_file
					fi
					(( index++ ))
				done
				parallel --will-cite 'n4biascorrect' ::: "${this_file_to_biascorrect[@]}" 
			done
			"This step took $SECONDS seconds to execute"
		fi
	
		

		if [[ $this_preprocessing_step == "ants_registration_Func_2_T1" ]]; then
			antsreg(){
						Mean_Func=$1
						T1_Template=biascorrected_SkullStripped_T1.nii
					
						this_core_file_name=$(echo $1 | cut -d. -f 1)
						echo $this_core_file_name
						# moving low res func to high res T1
						antsRegistration --dimensionality 3 --float 0 \
					     --output [warpToT1Params_${this_core_file_name},warpToT1Estimate_${this_core_file_name}.nii] \
					     --interpolation Linear \
					     --winsorize-image-intensities [0.005,0.995] \
					     --use-histogram-matching 0 \
					     --initial-moving-transform [$T1_Template,$Mean_Func,1] \
					     --transform Rigid[0.1] \
					     --metric MI[$T1_Template,$Mean_Func,1,32,Regular,0.25] \
					     --convergence [1000x500x250x100,1e-6,10] \
					     --shrink-factors 8x4x2x1 \
					     --smoothing-sigmas 3x2x1x0vox
					}
			export -f antsreg	

			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				
				ml gcc/5.2.0
				ml ants
				ml parallel
				parallel --will-cite 'antsreg' ::: biascorrected_mean*.nii
			done
			"This step took $SECONDS seconds to execute"
		fi
	
		if [[ $this_preprocessing_step == "ants_apply_transform_Func_2_T1" ]]; then
			transformFunc2T1(){
				this_core_file_name=$(echo $1 | cut -d. -f 1)
				#ml gcc/5.2.0
				#ml ants
				antsApplyTransforms -d 3 -e 3 -i ${this_core_file_name}.nii -r biascorrected_SkullStripped_T1.nii \
				-n BSpline -o warpedToT1_${this_core_file_name}.nii -t [warpToT1Params_${this_core_file_name}0GenericAffine.mat,0] -v 
				}
			export -f transformFunc2T1	

			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				ml gcc/5.2.0
				ml ants
				ml parallel
				parallel --will-cite 'transformFunc2T1' ::: biascorrected_meanunwarpedRealigned*.nii
			done
			echo "This script took $SECONDS seconds to execute"
		fi
	
		if [[ $this_preprocessing_step == "ants_registration_T1_2_MNI" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				# Create folders
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
	
				ml gcc/5.2.0
				ml ants
	
				outputFolder=${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				T1_Template=${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/biascorrected_SkullStripped_T1.nii
				MNI_Template=/ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii
				#MNI_Template=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/spm12/canonical/avg152T1.nii				

				this_core_file_name=biascorrected_SkullStripped_T1
	
				antsRegistration --dimensionality 3 --float 0 \
        		--output [$outputFolder/warpToMNIParams_${this_core_file_name},$outputFolder/warpToMNIEstimate_${this_core_file_name}.nii] \
        		--interpolation Linear \
        		--winsorize-image-intensities [0.01,0.99] \
        		--use-histogram-matching 1 \
        		--initial-moving-transform [$MNI_Template,$T1_Template,1] \
        		--transform Rigid[0.1] \
        		--metric MI[$MNI_Template,$T1_Template,1,64,Regular,.5] \
        		--convergence [1000x500x250x100,1e-6,10] \
        		--shrink-factors 8x4x2x1 \
        		--smoothing-sigmas 3x2x1x0vox \
        		--transform Affine[0.1] \
        		--metric MI[$MNI_Template,$T1_Template,1,64,Regular,.5] \
        		--convergence [1000x500x250x100,1e-6,10] \
        		--shrink-factors 8x4x2x1 \
        		--smoothing-sigmas 3x2x1x0vox \
        		--transform SyN[0.1,3,0] \
        		--metric CC[$MNI_Template,$T1_Template,1,2] \
        		--convergence [100x70x50x20,1e-6,10] \
        		--shrink-factors 8x4x2x1 \
        		--smoothing-sigmas 3x2x1x0vox
        	done
		fi
	
		if [[ $this_preprocessing_step == "ants_apply_transform_T1_2_MNI" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				#cp /ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/spm12/canonical/avg152T1.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
								

				ml gcc/5.2.0
				ml ants
				
				this_core_file_name=biascorrected_SkullStripped_T1
	
				antsApplyTransforms -d 3 -e 3 -i ${this_core_file_name}.nii -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
				-n BSpline -o warpedToMNI_${this_core_file_name}.nii -t [warpToMNIParams_${this_core_file_name}1Warp.nii.gz] -t [warpToMNIParams_${this_core_file_name}0GenericAffine.mat,0] -v
				#-t [warpToMNIParams_${this_core_file_name}0GenericAffine.mat,1]  [warpToMNIParams_${this_core_file_name}1InverseWarp.nii.gz] -v
			done
		fi
	
		if [[ $this_preprocessing_step == "ants_apply_transform_Func_2_MNI" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/unwarpedRealigned*.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
	
				for this_file_to_warp in unwarpedRealigned*.nii; do 
					ml fsl
					this_file_header_info=$(fslhd $this_file_to_warp)
					this_file_number_of_volumes=$(echo $this_file_header_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)
	
					this_func_core_file_name=$(echo $this_file_to_warp | cut -d. -f 1)
					this_T1_core_file_name=biascorrected_SkullStripped_T1
				
					fslsplit $this_file_to_warp
					gunzip *.nii.gz*
	
					for (( this_volume=0; this_volume<=$this_file_number_of_volumes-1; this_volume++ )); do
						#echo $this_volume
						if [ $this_volume -lt 10 ]; then
							this_volume_file=vol000$this_volume.nii
						fi
						if [ $this_volume -gt 9 ] && [ $this_volume -lt 100 ]; then
							this_volume_file=vol00$this_volume.nii
						fi
						if [ $this_volume -gt 99 ]; then
							this_volume_file=vol0$this_volume.nii
						fi
	
						# need the warpParams biascorrected_T1
						# need the warpParams fmri
						ml gcc/5.2.0; ml ants
						antsApplyTransforms -d 3 -e 3 -i $this_volume_file -r ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii \
						-o warpedToMNI_$this_volume_file -t [warpToT1Params_biascorrected_mean${this_func_core_file_name}0GenericAffine.mat,0] \
						-t [warpToMNIParams_${this_T1_core_file_name}1Warp.nii] -t [warpToMNIParams_${this_T1_core_file_name}0GenericAffine.mat,0] -v
						#[T1_to_MNIc0c_0GenericAffine.mat,1] -v
					done
					rm vol0*
					fslmerge -t warpedToMNI_$this_file_to_warp warpedToMNI_vol0* 		 # type of transformation _ registration type (L= linear, A = Affine, S = syn) _ flow field applied (i = inverse, A = affine.mat, W = warp) 
					rm warpedToMNI_vol0* 		
					gunzip *.nii.gz*
				done
			done
		fi
	
		if [[ $this_preprocessing_step == "smooth_fmri_ants" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				ml matlab
				matlab -nodesktop -nosplash -r "try; smooth_fmri_ants; catch; end; quit"
			done
			"This step took $SECONDS seconds to execute"
			cd "${Subject_dir}"
			echo "Smoothing: $SECONDS sec" >> preprocessing_log.txt
			SECONDS=0
		fi
	
		if [[ $this_preprocessing_step == "level_one_stats_ants" ]]; then
			data_folder_to_analyze=($fmri_processed_folder_names)
			for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
				cd ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/*.json ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/Condition_Onsets*.csv ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/art_regression_outliers_and_movement*.mat ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				# grab TR from json file
				for this_functional_run_file in *.json; do 
					TR_from_json=$(grep "RepetitionTime" ${this_functional_run_file} | tr -dc '0.00-9.00')
  				break; done
  				ml matlab
    			matlab -nodesktop -nosplash -r "try; level_one_stats('$TR_from_json'); catch; end; quit"
    		done
		fi
	done
done