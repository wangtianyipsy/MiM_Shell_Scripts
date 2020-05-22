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

argument_counter=0
for this_argument in "$@"; do
	if	[[ $argument_counter == 0 ]]; then
    	subject=$this_argument
	else
		ceres_processing_steps="$this_argument"
	fi
	
	# Set the path for our custom matlab functions and scripts
	Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code
		
	export MATLABPATH=${Code_dir}/Matlab_Scripts/helper
		
	study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/$subject
	cd $Subject_dir

########### determine which functional files you would like to ceres process (resting state and fmri) ############################
	lines_to_ignore=$(awk '/#/{print NR}' file_settings.txt) # file_settings dictates which folders are Processed

	fmri_line_numbers_in_file_info=$(awk '/functional_run/{print NR}' file_settings.txt)
	restingstate_line_numbers_in_file_info=$(awk '/restingstate/{print NR}' file_settings.txt)

	restingstate_line_numbers_to_process=$restingstate_line_numbers_in_file_info
	fmri_line_numbers_to_process=$fmri_line_numbers_in_file_info

	this_index_fmri=0
	this_index_restingstate=0
	for item_to_ignore in ${lines_to_ignore[@]}; do
		for item_to_check in ${fmri_line_numbers_in_file_info[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_fmri[$this_index_fmri]=$item_to_ignore
  				(( this_index_fmri++ ))
  			fi
  		done
  		for item_to_check in ${restingstate_line_numbers_in_file_info[@]}; do
  			if [[ $item_to_check == $item_to_ignore ]]; then 
  				remove_this_item_restingstate[$this_index_restingstate]=$item_to_ignore
  				(( this_index_restingstate++ ))
  			fi
  		done
	done

	for item_to_remove_fmri in ${remove_this_item_fmri[@]}; do
		fmri_line_numbers_to_process=$(echo ${fmri_line_numbers_to_process[@]/$item_to_remove_fmri})
	done
	for item_to_remove_restingstate in ${remove_this_item_restingstate[@]}; do
		restingstate_line_numbers_to_process=$(echo ${restingstate_line_numbers_to_process[@]/$item_to_remove_restingstate})
	done

	this_index=0
	for this_line_number in ${fmri_line_numbers_to_process[@]}; do
		fmri_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	this_index=0
	for this_line_number in ${restingstate_line_numbers_to_process[@]}; do
		restingstate_processed_folder_name_array[$this_index]=$(cat file_settings.txt | sed -n ${this_line_number}p | cut -d ',' -f2)
		(( this_index++ ))
	done
	
	
	fmri_processed_folder_names=$(echo "${fmri_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	restingstate_processed_folder_names=$(echo "${restingstate_processed_folder_name_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	
	for this_ceres_processing_step in "${ceres_processing_steps[@]}"; do
###################################################################################

########### move and unzip raw ceres files ############################
		if [[ $this_ceres_processing_step ==  "ceres_unzip" ]]; then
			
			cd $Subject_dir/Processed/MRI_files/
			mkdir 01_Ceres
			cd 01_Ceres
			rm *
			cd $study_dir/Ceres_Output_Native
			cp native_${subject}* $Subject_dir/Processed/MRI_files/01_Ceres
			
			cd $Subject_dir/Processed/MRI_files/01_Ceres

			unzip *.zip
			
			ml matlab
			matlab -nodesktop -nosplash -r "try; ceres_create_binary; catch; end; quit"

			for this_functional_run_folder in ${fmri_processed_folder_names[@]} ${restingstate_processed_folder_names[@]}; do
				cp $Subject_dir/Processed/MRI_files/01_Ceres/CB_mask.nii $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
				cp $Subject_dir/Processed/MRI_files/01_Ceres/job* $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
				cp $Subject_dir/Processed/MRI_files/01_Ceres/native_tissue_ln_crop_mmni* $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
			done
		fi
###################################################################################

########### Place Functional Run in T1 space (write) to allow for proper cb mask ############################
		if [[ $this_ceres_processing_step ==  "coreg_func_to_ceresT1" ]]; then
			for this_functional_run_folder in ${fmri_processed_folder_names[@]} ${restingstate_processed_folder_names[@]}; do
				cd $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
				cp ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/meanunwarped*.nii ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization

				for this_func_run in unwarpedRealigned*.nii; do
					this_core_file_name=$(echo $this_func_run | cut -d. -f 1)

					ml fsl
					flirt -in biascorrected_SkullStripped_T1.nii -ref mean${this_func_run} -out dimMatch2Func_biascorrected_SkullStripped_T1.nii
					gunzip -f *nii.gz

					ml gcc; ml ants
					antsApplyTransforms -d 3 -e 3 -i ${this_core_file_name}.nii --float 0 -r dimMatch2Func_biascorrected_SkullStripped_T1.nii \
					-n BSpline -o coregToT1_${this_core_file_name}.nii -t [warpToT1Params_biascorrected_mean${this_core_file_name}0GenericAffine.mat,0] -v 

					antsApplyTransforms -d 3 -e 3 -i native_tissue*.nii --float 0 -r dimMatch2Func_biascorrected_SkullStripped_T1.nii \
					-n BSpline -o coregToT1_native_tissue_CB.nii -t [warpToT1Params_biascorrected_mean${this_core_file_name}0GenericAffine.mat,0] -v 					

					fslmaths coregToT1_native_tissue_CB.nii -thr 0.5 -bin binary_coregToT1_native_tissue_CB
					gunzip -f *nii.gz					
				done
			done
			echo This step took $SECONDS seconds to execute
        	cd "${Subject_dir}"
        	echo "coreg and write: $SECONDS sec" >> ceres_processing_log.txt
        	SECONDS=0
		fi
###################################################################################

########### JAMMED FULL WITH LOTS OF STEPS (Change dimensions, masking, and Ants warping) ############################
		if [[ $this_ceres_processing_step ==  "ceres_cb_mask_norm" ]]; then
			for this_functional_run_folder in ${fmri_processed_folder_names[@]} ${restingstate_processed_folder_names[@]}; do
				cd $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
				echo 'running normalization steps... this may take a while...'
				
				for ceres_image in native_*.nii; do
					ml gcc/5.2.0; ml ants
					N4BiasFieldCorrection -i $ceres_image -o biascorrected_$ceres_image
					ceres_image=biascorrected_$ceres_image
					SUIT_Template_1mm=$Code_dir/MR_Templates/SUIT_maskedByCEREScoreg_1mm.nii
					SUIT_Template_2mm=$Code_dir/MR_Templates/SUIT_maskedByCEREScoreg_2mm.nii
					echo 'registering' $ceres_image 'to' $SUIT_Template_1mm
					
					ml gcc/5.2.0; ml ants
					antsRegistration --dimensionality 3 --float 0 \
				   	 	--output [warpToSUITParams,warpToSUITEstimate.nii] \
				   	 	--interpolation Linear \
				   	 	--winsorize-image-intensities [0.01,0.99] \
				   	 	--use-histogram-matching 1 \
				   	 	--initial-moving-transform [$SUIT_Template_1mm,$ceres_image,1] \
				   	 	--transform Rigid[0.1] \
				   	 	--metric MI[$SUIT_Template_1mm,$ceres_image,1,64,Regular,.5] \
				   	 	--convergence [1000x500x250x100,1e-6,10] \
				   	 	--shrink-factors 8x4x2x1 \
				   	 	--smoothing-sigmas 3x2x1x0vox \
				   	 	--transform Affine[0.1] \
				   	 	--metric MI[$SUIT_Template_1mm,$ceres_image,1,64,Regular,.5] \
				   	 	--convergence [1000x500x250x100,1e-6,10] \
				   	 	--shrink-factors 8x4x2x1 \
				   	 	--smoothing-sigmas 3x2x1x0vox \
				   	 	--transform SyN[0.1,3,0] \
				   	 	--metric CC[$SUIT_Template_1mm,$ceres_image,1,2] \
				   	 	--convergence [100x70x50x20,1e-6,10] \
				   	 	--shrink-factors 8x4x2x1 \
				   	 	--smoothing-sigmas 3x2x1x0vox
				done

				gunzip -f *nii.gz

				cp $SUIT_Template_2mm ${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization
				for this_func_run in unwarpedRealigned*.nii; do
					ml fsl	
					fslmaths coregToT1_${this_func_run} -mas binary_coregToT1_native_tissue_CB.nii CBmasked_coregToT1_${this_func_run}
					gunzip -f *nii.gz

					ml gcc/5.2.0; ml ants
					antsApplyTransforms -d 3 -e 3 -i CBmasked_coregToT1_${this_func_run} -r $SUIT_Template_2mm \
					-o warpedToSUITKH_CBmasked_coregToT1_${this_func_run} -t [warpToSUITParams1Warp.nii] -t [warpToSUITParams0GenericAffine.mat,0] -v
				done
			done
			echo This step took $SECONDS seconds to execute
        	cd "${Subject_dir}"
        	echo "Normalizing CB: $SECONDS sec" >> ceres_processing_log.txt
        	SECONDS=0
		fi
		
		if [[ $this_ceres_processing_step ==  "ceres_smooth_norm"  ]]; then
			for this_functional_run_folder in ${fmri_processed_folder_names[@]} ${restingstate_processed_folder_names[@]}; do
				cd $Subject_dir/Processed/MRI_files/$this_functional_run_folder/ANTS_Normalization
				ml matlab
				matlab -nodesktop -nosplash -r "try; ceres_smooth_antsnorm; catch; end; quit"
			done	
			echo This step took $SECONDS seconds to execute
        	cd "${Subject_dir}"
        	echo "smoothing ceres: $SECONDS sec" >> ceres_processing_log.txt
        	SECONDS=0
		fi		
	done
	(( argument_counter++ ))
done