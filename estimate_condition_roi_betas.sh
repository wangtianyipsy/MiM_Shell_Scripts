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

#subjects=('1002,1004,1010,1011')
subjects=('2002,2015,2018,2021')
#group_name=(youngAdult)
group_name=(oldAdult)
fmri_processed_folder_names=('06_Nback')
	
#subjects=(1011)
#subjects=(2015)
#subjects=(2018)
# 1011 2015 2018

#subjects=(1010)
#subjects=(2021)

#subjects=(CrunchPilot01)
#subjects=(ClarkPilot_01)

####### find roi locations ##############################
#roi_analysis_steps=("level_two_stats_maineffect")

#roi_analysis_steps=("convert_roi")
#roi_analysis_steps=("create_roi_sphere")

#roi_analysis_steps=("extract_intensity_from_existing_rois")

#roi_analysis_steps=("convert_to_mni_for_significant_clusters")
#roi_analysis_steps=("extract_intensity_from_significant_clusters")
roi_analysis_steps=("collect_roi_from_significant_clusters")

#roi_analysis_steps=("collect_roi")
##################################################

Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper

#for SUB in ${subjects[@]}; do
Study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/
cd "${Study_dir}"

for this_roi_analysis_step in "${roi_analysis_steps[@]}"; do
	if [[ $this_roi_analysis_step == "level_two_stats_maineffect" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			# task_folder = '06_Nback';
			# subject_codes = {'1002', '1004'}; % need to figure out how to pass cell from shell
			echo $this_functional_run_folder
			echo $group_name
			echo ${subjects[@]}
			mkdir -p "${Study_dir}/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}"
			ml matlab
   			matlab -nodesktop -nosplash -r "try; level_two_stats_maineffect(1, '$this_functional_run_folder', '${subjects}', '$group_name'); catch; end; quit"
   		done
   		echo This step took $SECONDS seconds to execute
   		#cd "${Subject_dir}"
		#echo "Level Two Main Effect: $SECONDS sec" >> preprocessing_log.txt
		#SECONDS=0
	fi

	if [[ $this_roi_analysis_step == "convert_roi" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			if [[ $this_functional_run_folder == "05_MotorImagery" ]] ; then
				ml matlab
				cd $Study_dir
				lines_to_ignore=$(awk '/#/{print NR}' MotorImagery_roi.txt)

				roi_line_numbers=$(awk 'END{print NR}' Nback_roi.txt)
				for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
					if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
						this_roi_name=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
						this_roi_x=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
						this_roi_y=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
						this_roi_z=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
						cd ${Study_dir}/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
						#matlab -nodesktop -nosplash -r "try; find_roi_voxel_coordinates('$this_roi_name', '$this_roi_x', '$this_roi_y', '$this_roi_z'); catch; end; quit"
					fi
				done
			fi
			if [[ $this_functional_run_folder == "06_Nback" ]] ; then
				ml matlab
				cd $Study_dir
				lines_to_ignore=$(awk '/#/{print NR}' Nback_roi.txt)

				roi_line_numbers=$(awk 'END{print NR}' Nback_roi.txt)
				for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
					if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
						this_roi_name=$(cat Nback_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
						this_roi_x=$(cat Nback_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
						this_roi_y=$(cat Nback_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
						this_roi_z=$(cat Nback_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
						cd ${Study_dir}/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
						#echo $this_roi_z
						matlab -nodesktop -nosplash -r "try; find_roi_voxel_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
						cd $Study_dir
					fi
				done
			fi
		done
	fi

	if [[ $this_roi_analysis_step == "create_roi_sphere" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			cd $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
			for this_roi_file in roi_*.csv; do
				
				this_roi_file_corename=$(echo $this_roi_file | cut -d. -f 1)
				this_roi_corename=$(echo $this_roi_file_corename | cut -d'_' -f 2)
				
				this_roi_x=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f1)
				this_roi_y=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f2)
				this_roi_z=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f3)

				while IFS=',' read -ra subject_list; do
   				    for this_subject in "${subject_list[@]}"; do
   	   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      				echo Currently calculating average activation for $this_subject at ${this_roi_corename}

      					if [ -e ${this_roi_corename}point.nii ]; then 
							rm ${this_roi_corename}point*.nii
							rm ${this_roi_corename}sphere15mm*.nii
						fi 


      					ml fsl
						fslmaths con_0001.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ${this_roi_corename}point -odt float
				 		fslmaths ${this_roi_corename}point.nii -kernel sphere 15 -fmean ${this_roi_corename}sphere15mm -odt float
				 		gunzip *nii.gz*
				 		# TO DO: need a way to auto determine which spm file to choose
				 		# TO DO: should I be using spmT or conn images here?
						if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
				 			fslmeants -i spmT_0013.nii -o meants_${this_roi_corename}sphere_flat.txt -m ${this_roi_corename}sphere
				 			fslmeants -i spmT_0014.nii -o meants_${this_roi_corename}sphere_hard.txt -m ${this_roi_corename}sphere
				 			fslmeants -i spmT_0015.nii -o meants_${this_roi_corename}sphere_low.txt -m ${this_roi_corename}sphere
			 				fslmeants -i spmT_0016.nii -o meants_${this_roi_corename}sphere_medium.txt -m ${this_roi_corename}sphere
						fi
						if [[ $this_functional_run_folder == "06_Nback" ]]; then
							fslmeants -i con_0057.nii -o CONmeants15mm_${this_roi_corename}sphere_long_one.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0058.nii -o CONmeants15mm_${this_roi_corename}sphere_long_three.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0059.nii -o CONmeants15mm_${this_roi_corename}sphere_long_two.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0060.nii -o CONmeants15mm_${this_roi_corename}sphere_long_zero.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0061.nii -o CONmeants15mm_${this_roi_corename}sphere_short_one.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0062.nii -o CONmeants15mm_${this_roi_corename}sphere_short_three.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0063.nii -o CONmeants15mm_${this_roi_corename}sphere_short_two.txt -m ${this_roi_corename}sphere15mm
							fslmeants -i con_0064.nii -o CONmeants15mm_${this_roi_corename}sphere_short_zero.txt -m ${this_roi_corename}sphere15mm
						fi
						cd $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
					done
 				done <<< "$subjects"
			done
		done
	fi
	if [[ $this_roi_analysis_step == "collect_roi" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					if [ -e ${this_subject}_roi_results.txt ]; then 
   	    	       		rm ${this_subject}${this_txt_file_prefix}_roi_results.txt
   	    	       		rm ${this_subject}_${this_txt_file_prefix}_roi_results.txt
   	    	   		fi
					for this_txt_file in CONmeants_*.txt; do

      					#if [ -e $this_txt_file ]; then 
						#	rm $this_txt_file
						#fi

						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_txt_file)
						echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
					done	
					cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done	
	fi

	if [[ $this_roi_analysis_step == "extract_intensity_from_existing_rois" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do

			if [[ $this_functional_run_folder == "06_Nback" ]]; then
				ml fsl
				
				cp $Study_dir/ROIs_Nback/roi*.nii $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				cp /ufrc/rachaelseidler/tfettrow/Crunch_Code/MR_Templates/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				cd $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				

				if [ -e maskroi_LBA6.nii ]; then 
   	    	       	rm maskroi*.nii
   	    	   	fi
   	    	   	if [ -e noNANmaskroi_LBA6.nii ]; then 
   	    	    	rm noNANbinmask*.nii
   	    	    fi
   	    	    if [ -e binmaskroi_LBA6.nii ]; then 
   	    	    	rm binmask*.nii
   	    	    fi

				for this_roi_file in roi*.nii; do
					this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
					#echo $this_roi_file
					
					flirt -in $this_roi_file -ref con_0001.nii -applyxfm -usesqform -out mask${this_roi_corename}
					gunzip *nii.gz*
					#fslmaths mask${this_roi_corename}.nii -thr 0.5 -bin binmask${this_roi_corename}.nii
					#fslmaths binmask${this_roi_corename}.nii -nan noNANbinmask${this_roi_corename}.nii					
				done
				
				#fslmeants -i con_0057.nii -o CONmeants15mm_${this_roi_corename}sphere_long_one.txt -m ${this_roi_corename}sphere15mm

				#fslmaths 'spmT_0001.nii' -mas nback_mask_roi.nii.gz nback_mask_roi_GroupAveragemask.nii
				if [ -e noNANcon_0002.nii ]; then 
   	    	       	rm noNANcon_00*.nii
   	    	   	fi

				fslmaths con_0002.nii -nan noNANcon_0002.nii
				fslmaths con_0003.nii -nan noNANcon_0003.nii
				fslmaths con_0004.nii -nan noNANcon_0004.nii
				fslmaths con_0005.nii -nan noNANcon_0005.nii
				fslmaths con_0006.nii -nan noNANcon_0006.nii
				fslmaths con_0007.nii -nan noNANcon_0007.nii
				fslmaths con_0008.nii -nan noNANcon_0008.nii
				fslmaths con_0009.nii -nan noNANcon_0009.nii
				gunzip *nii.gz*

				for this_roi_file in maskroi*.nii; do
					this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
					echo $this_roi_corename
					


					fslmeants -i noNANcon_0002.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_short_zero.txt -m $this_roi_file
					fslmeants -i noNANcon_0003.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_long_zero.txt -m $this_roi_file
					fslmeants -i noNANcon_0004.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_short_one.txt -m $this_roi_file
					fslmeants -i noNANcon_0005.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_long_one.txt -m $this_roi_file
					fslmeants -i noNANcon_0006.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_short_two.txt -m $this_roi_file
					fslmeants -i noNANcon_0007.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_long_two.txt -m $this_roi_file
					fslmeants -i noNANcon_0008.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_short_three.txt -m $this_roi_file
					fslmeants -i noNANcon_0009.nii -o CONmeantsGroupAveragemask_${this_roi_corename}_long_three.txt -m $this_roi_file

				# 	fslmeants -i spmT_0002.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_short_zero.txt -m $this_roi_file
				# 	fslmeants -i spmT_0003.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_long_zero.txt -m $this_roi_file
				# 	fslmeants -i spmT_0004.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_short_one.txt -m $this_roi_file
				# 	fslmeants -i spmT_0005.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_long_one.txt -m $this_roi_file
				# 	fslmeants -i spmT_0006.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_short_two.txt -m $this_roi_file
				# 	fslmeants -i spmT_0007.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_long_two.txt -m $this_roi_file
				# 	fslmeants -i spmT_0008.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_short_three.txt -m $this_roi_file
				# 	fslmeants -i spmT_0009.nii -o spmTmeantsGroupAveragemask_${this_roi_corename}_long_three.txt -m $this_roi_file
				done

				if [ -e CONmeantsGroupAveragemask_roi_results.txt ]; then 
   	    	       	rm CONmeantsGroupAveragemask_roi_results.txt
   	    	   	fi
				
				for this_GroupAverage_roi_results_file in CONmeantsGroupAveragemask_*.txt; do
						this_txt_file_core_name=$(echo $this_GroupAverage_roi_results_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_GroupAverage_roi_results_file)
						echo $this_txt_file_core_name, $this_txt_file_contents >> CONmeantsGroupAveragemask_roi_results.txt
				done

				#fslmeants -i con_0001.nii -o CONmeantsGroupAveragemask_.txt -m nback_mask_roi_GroupAveragemask.nii
				##apply a mask to an image
				##############################################################################################
				#
				#flirt -in mask3mm -ref $FSLDIR/data/standard/MNI152_T1_2mm -applyxfm -usesqform -out mask2mm
				#fslmaths mask2mm -thr 0.5 -bin highres_mask 
			fi
		done
	fi
	if [[ $this_roi_analysis_step == "convert_to_mni_for_significant_clusters" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			ml matlab
			cd $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
					
			lines_to_ignore=$(awk '/#/{print NR}' ROIs.txt)
	
			roi_line_numbers=$(awk 'END{print NR}' ROIs.txt)
			for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
				if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
					this_roi_name=$(cat ROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
					this_roi_x=$(cat ROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
					this_roi_y=$(cat ROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
					this_roi_z=$(cat ROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
					echo converting mni $this_roi_name coordinates to voxel coordinates
					#################################33
					matlab -nodesktop -nosplash -r "try; convert_to_mni_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
				#	cd $Study_dir
					#################################33
				fi
			done
		done
	fi

	if [[ $this_roi_analysis_step == "extract_intensity_from_significant_clusters" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			while IFS=',' read -ra subject_list; do
   			
				for this_subject in "${subject_list[@]}"; do
   				
				# if [[ $this_functional_run_folder == "05_MotorImagery" ]] ; then
				# 	ml matlab
				# 	cd $Study_dir
				# 	lines_to_ignore=$(awk '/#/{print NR}' MotorImagery_roi.txt)
	
				# 	roi_line_numbers=$(awk 'END{print NR}' Nback_roi.txt)
				# 	for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
				# 		if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
				# 			this_roi_name=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
				# 			this_roi_x=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
				# 			this_roi_y=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
				# 			this_roi_z=$(cat MotorImagery_roi.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
				# 			cd ${Study_dir}/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				# 			#matlab -nodesktop -nosplash -r "try; find_roi_voxel_coordinates('$this_roi_name', '$this_roi_x', '$this_roi_y', '$this_roi_z'); catch; end; quit"
				# 		fi
				# 	done
				# fi
					ml matlab
					cd $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
					cp MNIROIs.txt ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results

					if [ -e noNANcon_0057.nii ]; then 
   	    	   			rm noNANcon_00*.nii
   	    	   		fi
					ml fsl

					fslmaths con_0057.nii -nan noNANcon_0057.nii
					fslmaths con_0058.nii -nan noNANcon_0058.nii
					fslmaths con_0059.nii -nan noNANcon_0059.nii
					fslmaths con_0060.nii -nan noNANcon_0060.nii
					fslmaths con_0061.nii -nan noNANcon_0061.nii
					fslmaths con_0062.nii -nan noNANcon_0062.nii
					fslmaths con_0063.nii -nan noNANcon_0063.nii
					fslmaths con_0064.nii -nan noNANcon_0064.nii
					gunzip *nii.gz*
					
					lines_to_ignore=$(awk '/#/{print NR}' MNIROIs.txt)
	
					roi_line_numbers=$(awk 'END{print NR}' MNIROIs.txt)
					for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
						if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
							this_roi_name=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
							this_roi_x=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
							this_roi_y=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
							this_roi_z=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
							echo Analyzing $this_roi_name for $this_subject

							if [ -e ${this_roi_name}point.nii ]; then 
								rm ${this_roi_name}point*.nii
								rm ${this_roi_name}sphere5mm*.nii
							fi 
	
							ml fsl
							fslmaths con_0001.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ${this_roi_name}point -odt float
					 		fslmaths ${this_roi_name}point.nii -kernel sphere 5 -fmean ${this_roi_name}sphere5mm.nii -odt float
					 		gunzip *nii.gz*
					 		# TO DO: need a way to auto determine which spm file to choose
					 		# TO DO: should I be using spmT or conn images here?
							# if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
					 	# 		fslmeants -i spmT_0013.nii -o meants_${this_roi_name}sphere_flat.txt -m ${this_roi_name}sphere
					 	# 		fslmeants -i spmT_0014.nii -o meants_${this_roi_name}sphere_hard.txt -m ${this_roi_name}sphere
					 	# 		fslmeants -i spmT_0015.nii -o meants_${this_roi_name}sphere_low.txt -m ${this_roi_name}sphere
						# 		fslmeants -i spmT_0016.nii -o meants_${this_roi_name}sphere_medium.txt -m ${this_roi_name}sphere
							# file
							if [[ $this_functional_run_folder == "06_Nback" ]]; then

								fslmeants -i noNANcon_0057.nii -o CONmeants5mm_${this_roi_name}sphere_long_one.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0058.nii -o CONmeants5mm_${this_roi_name}sphere_long_three.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0059.nii -o CONmeants5mm_${this_roi_name}sphere_long_two.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0060.nii -o CONmeants5mm_${this_roi_name}sphere_long_zero.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0061.nii -o CONmeants5mm_${this_roi_name}sphere_short_one.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0062.nii -o CONmeants5mm_${this_roi_name}sphere_short_three.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0063.nii -o CONmeants5mm_${this_roi_name}sphere_short_two.txt -m ${this_roi_name}sphere5mm.nii
								fslmeants -i noNANcon_0064.nii -o CONmeants5mm_${this_roi_name}sphere_short_zero.txt -m ${this_roi_name}sphere5mm.nii
							fi
							
						fi
					done
				done
			done <<< "$subjects"
		done
	fi
	if [[ $this_roi_analysis_step == "collect_roi_from_significant_clusters" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					if [ -e ${this_subject}_CONmeants5mm_roi_results.txt ]; then
   	    	       		rm ${this_subject}_CONmeants5mm_roi_results.txt
   	    	   		fi
					for this_txt_file in CONmeants5mm_roi*.txt; do

      					#if [ -e $this_txt_file ]; then 
						#	rm $this_txt_file
						#fi

						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_txt_file)
						
						echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
					done
					cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done	
	fi
done
