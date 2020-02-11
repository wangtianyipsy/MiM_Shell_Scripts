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

# this script requires arguments 

# example >> estimate_betas_by_condition.sh '1002,1004' youngAdult 05_MotorImagery collect_intensity_from_network_rois

# things to be aware of with this script: 
# 1) only run one step at a time
# 2) only run one population at a time
# 3) only run one task (MotorImagery or Nback) at a time

# potential steps:
#convert_manually_entered_roi_to_voxel_coordinates
#create_roi_sphere_for_maually_entered_roi
#collect_manually_entered_rois

#convert_to_mni_for_significant_clusters
#extract_intensity_from_significant_clusters
#collect_roi_from_significant_clusters

#extract_intensity_from_WFU_rois
#collect_intensity_from_WFU_rois

#extract_intensity_from_network_rois
#collect_intensity_from_network_rois

##################################################

argument_counter=0
for this_argument in "$@"; do
	if	[[ $argument_counter == 0 ]]; then
		subjects=$this_argument
	elif [[ $argument_counter == 1 ]]; then
		group_name=$this_argument
	elif [[ $argument_counter == 2 ]]; then
		fmri_processed_folder_names=$this_argument
	elif [[ $argument_counter == 3 ]]; then
		roi_analysis_steps=$this_argument
	fi
	(( argument_counter++ ))		
done

echo $subjects
echo $group_name
echo $fmri_processed_folder_names
echo $roi_analysis_steps

Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper

#for SUB in ${subjects[@]}; do
Study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/
cd "${Study_dir}"

for this_roi_analysis_step in "${roi_analysis_steps[@]}"; do
	
# for predetmined rois (.txt has manually entered mni coords)
#####################################################################################################################################################
	if [[ $this_roi_analysis_step == "convert_manually_entered_roi_to_voxel_coordinates" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			if [[ $this_functional_run_folder == "05_MotorImagery" ]] ; then
				ml matlab
				cd $Study_dir
				lines_to_ignore=$(awk '/#/{print NR}' MotorImagery_roi.txt)

				roi_line_numbers=$(awk 'END{print NR}' MotorImagery_roi.txt)
				for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
					if ! [[ ${lines_to_ignore[*]} =~ $this_row ]]; then
						this_roi_name=$(cat MotorImagery_roi.txt | sed -n ${this_row}p | cut -d ',' -f1)
						this_roi_x=$(cat MotorImagery_roi.txt | sed -n ${this_row}p | cut -d ',' -f2)
						this_roi_y=$(cat MotorImagery_roi.txt | sed -n ${this_row}p | cut -d ',' -f3)
						this_roi_z=$(cat MotorImagery_roi.txt | sed -n ${this_row}p | cut -d ',' -f4)
						cd ${Study_dir}/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
						matlab -nodesktop -nosplash -r "try; find_roi_voxel_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
						cd $Study_dir
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
						cd ${Study_dir}/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
						matlab -nodesktop -nosplash -r "try; find_roi_voxel_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
						cd $Study_dir
					fi
				done
			fi
		done
	fi

	if [[ $this_roi_analysis_step == "create_roi_sphere_for_maually_entered_rois" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
			for this_roi_file in roi_*.csv; do
				
				this_roi_file_corename=$(echo $this_roi_file | cut -d. -f 1)
				this_roi_corename=$(echo $this_roi_file_corename | cut -d'_' -f 2)
				
				this_roi_x=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f1)
				this_roi_y=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f2)
				this_roi_z=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f3)

				if [ -e ManEnteredROI_${this_roi_corename}_point.nii ]; then 
					rm ManEnteredROI_${this_roi_corename}_point.nii
					rm ManEnteredROI_${this_roi_corename}_sphere5mm.nii
				fi
				ml fsl
				echo converting  ${this_roi_corename}: $this_roi_x $this_roi_y $this_roi_z to 5mm sphere ....
				fslmaths con_0001.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ManEnteredROI_${this_roi_corename}_point -odt float
				fslmaths ManEnteredROI_${this_roi_corename}_point.nii -kernel sphere 5 -fmean ManEnteredROI_${this_roi_corename}_sphere5mm.nii -odt float
				gunzip *nii.gz*

				while IFS=',' read -ra subject_list; do
   				    for this_subject in "${subject_list[@]}"; do
   				    	cp ManEnteredROI_${this_roi_corename}_sphere5mm.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      				echo Currently calculating average activation for $this_subject at ${this_roi_corename}

   						if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
							if [ -e noNANcon_0013.nii ]; then 
   	    	   					rm noNANcon_00*.nii
   	    	   					rm meants5mmManEnteredROI_${this_roi_corename}sphere_hard.txt 
   	    	   					rm meants5mmManEnteredROI_${this_roi_corename}sphere_flat.txt 
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_high.txt 
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_low.txt
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_medium.txt
   	    	   				fi
						fi
						if [[ $this_functional_run_folder == "06_Nback" ]]; then
							if [ -e meants5mmManEnteredROI_${this_roi_corename}sphere_zero.txt ]; then 
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_zero.txt
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_one.txt
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_two.txt
								rm meants5mmManEnteredROI_${this_roi_corename}sphere_three.txt
   	    	   				fi
						fi

     					if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
				 			fslmeants -i spmT0013.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_flat.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
				 			fslmeants -i spmT0014.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_high.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
				 			fslmeants -i spmT0015.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_low.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
			 				fslmeants -i spmT0016.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_medium.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
						fi
						if [[ $this_functional_run_folder == "06_Nback" ]]; then
							fslmeants -i spmT_0020.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_zero.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
							fslmeants -i spmT_0017.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_one.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
							fslmeants -i spmT_0019.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_two.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
							fslmeants -i spmT_0018.nii -o meants5mmManEnteredROI_${this_roi_corename}sphere_three.txt -m ManEnteredROI_${this_roi_corename}_sphere5mm.nii
									
						fi
						cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					done
 				done <<< "$subjects"
			done
		done
	fi

	if [[ $this_roi_analysis_step == "collect_manually_entered_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					if [ -e ${this_subject}_roi_results.txt ]; then
   	    	       		rm ${this_subject}_meants5mmManEnteredROI_roi_results.txt
   	    	   		fi
   	    	   		rm ${this_subject}_meants5mmManEnteredROI_roi_results.txt
					for this_txt_file in meants5mmManEnteredROI_*.txt; do

						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_txt_file)
						echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
					done
					cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					rm ${this_subject}_meants5mmManEnteredROI_roi_results.txt
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done
	fi

	if [[ $this_roi_analysis_step == "convert_to_mni_for_significant_clusters" ]]; then
		####### find roi locations ##############################
		################################################################3
		# no longer available... create new script
		#roi_analysis_steps=("level_two_stats_withinGroup")
		#roi_analysis_steps=("level_two_stats_betweenGroup")
		################################################################
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			ml matlab
			cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					
			lines_to_ignore=$(awk '/#/{print NR}' ROIs.txt)
	
			roi_line_numbers=$(awk 'END{print NR}' ROIs.txt)
			for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
				if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
					echo $this_folder_row
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

#if [[ $this_roi_analysis_step == "extract_intensity_from_significant_clusters" ]]; then
#	for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
#		while IFS=',' read -ra subject_list; do
#			for this_subject in "${subject_list[@]}"; do
 # 				
#				ml matlab
#				cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
#				cp MNIROIs.txt ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
#				cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results

#				lines_to_ignore=$(awk '/#/{print NR}' MNIROIs.txt)
#				roi_line_numbers=$(awk 'END{print NR}' MNIROIs.txt)

#				for (( this_folder_row=1; this_folder_row<=${roi_line_numbers}; this_folder_row++ )); do
#					if ! [[ ${lines_to_ignore[*]} =~ $this_folder_row ]]; then
#						this_roi_name=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f1)
#						this_roi_x=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f2)
#						this_roi_y=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f3)
#						this_roi_z=$(cat MNIROIs.txt | sed -n ${this_folder_row}p | cut -d ',' -f4)
#						echo Analyzing $this_roi_name for $this_subject

#						if [ -e ${this_roi_name}point.nii ]; then
#							rm ${this_roi_name}point*.nii
#							rm ${this_roi_name}sphere5mm*.nii
#							
#							if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
#								rm CONmeants5mm_${this_roi_name}sphere_flat.txt
#								rm CONmeants5mm_${this_roi_name}sphere_low.txt
#								rm CONmeants5mm_${this_roi_name}sphere_medium.txt
#								rm CONmeants5mm_${this_roi_name}sphere_high.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_flat.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_low.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_medium.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_high.txt
#							if [[ $this_functional_run_folder == "06_Nback" ]]; then
#								rm CONmeants5mm_${this_roi_name}sphere_zero.txt
#								rm CONmeants5mm_${this_roi_name}sphere_one.txt
#								rm CONmeants5mm_${this_roi_name}sphere_two.txt
#								rm CONmeants5mm_${this_roi_name}sphere_three.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_zero.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_one.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_two.txt
#								rm meants5mmSignificantROI_${this_roi_name}sphere_three.txt
#							fi
#							
#						fi
#						
#						ml fsl
#						fslmaths con_0001.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ${this_roi_name}point -odt float
#				 		fslmaths ${this_roi_name}point.nii -kernel sphere 5 -fmean ${this_roi_name}sphere5mm.nii -odt float
#				 		gunzip *nii.gz*
#	
#						if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
#				 	 		fslmeants -i spmT_0013.nii -o meants5mmSignificantROI_${this_roi_name}sphere_flat.txt -m ${this_roi_name}sphere5mm.nii
#				 	 		fslmeants -i spmT_0014.nii -o meants5mmSignificantROI_${this_roi_name}sphere_high.txt -m ${this_roi_name}sphere5mm.nii
#				 	 		fslmeants -i spmT_0015.nii -o meants5mmSignificantROI_${this_roi_name}sphere_low.txt -m ${this_roi_name}sphere5mm.nii
#					 		fslmeants -i spmT_0016.nii -o meants5mmSignificantROI_${this_roi_name}sphere_medium.txt -m ${this_roi_name}sphere5mm.nii
#						fi

#						if [[ $this_functional_run_folder == "06_Nback" ]]; then
#							fslmeants -i spmT_0020.nii -o meants5mmSignificantROI_${this_roi_name}sphere_zero.txt -m ${this_roi_name}sphere5mm.nii
#							fslmeants -i spmT_0017.nii -o meants5mmSignificantROI_${this_roi_name}sphere_one.txt -m ${this_roi_name}sphere5mm.nii
#							fslmeants -i spmT_0019.nii -o meants5mmSignificantROI_${this_roi_name}sphere_two.txt -m ${this_roi_name}sphere5mm.nii
#							fslmeants -i spmT_0018.nii -o meants5mmSignificantROI_${this_roi_name}sphere_three.txt -m ${this_roi_name}sphere5mm.nii
#						fi
#					fi
#				done
#			done
#		done <<< "$subjects"
#	done
#fi

#if [[ $this_roi_analysis_step == "collect_roi_from_significant_clusters" ]]; then
#	data_folder_to_analyze=($fmri_processed_folder_names)
#	for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
#		while IFS=',' read -ra subject_list; do
 # 				for this_subject in "${subject_list[@]}"; do
 # 					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
#      			echo Currently collecting roi results for $this_subject

#				if [ -e ${this_subject}_meants5mmSignificantROIroi_results.txt ]; then
 # 	    	       		rm ${this_subject}_meants5mmSignificantROI_roi_results.txt
 # 	    	   		fi

#				for this_txt_file in meants5mmSignificantROI_*.txt; do
#					this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
#					this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
#					this_txt_file_contents=$(cat $this_txt_file)
#					
#					echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
#				done
#				cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
#				rm ${this_subject}_meants5mmSignificantROI_roi_results.txt
#				cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
#      			
#				cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
#			done
#		done <<< "$subjects"
#	done	
#fi

	#####################################################################################################################################################

# need WFU roi masks for this section..
#####################################################################################################################################################
	if [[ $this_roi_analysis_step == "extract_intensity_from_WFU_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					echo extracting betas for $this_subject
					# this was for premade nback rois
					#cp $Study_dir/ROIs_Nback/roi*.nii $Study_dir/Group_Results/MRI_files/${this_functional_run_folder}/${group_name}
					cp $Study_dir/ROIs_Lobes/WFU*.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					cp ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   				cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   				#cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					
					shopt -s nullglob
					prefix_to_delete=(mask*)
					if [ -e "$prefix_to_delete" ]; then
						rm mask*
						rm meantsWFUROI_*.txt
						rm roi_*.txt
					fi

					if [ -e brain_mask.nii ]; then
						rm brain_mask.nii
					fi

					ml fsl
					fslmaths ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii -bin brain_mask
					gunzip *nii.gz

					for this_roi_file in WFU*.nii; do
						this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
				
						flirt -in $this_roi_file -ref con_0001.nii -applyxfm -usesqform -out mask${this_roi_corename}
						gunzip *nii.gz*		

						fslmaths mask${this_roi_corename}.nii -mas brain_mask.nii masked${this_roi_corename}.nii
						gunzip *nii.gz*		
					done
     				if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
     					if ! [ -e noNANcon_0013.nii ]; then
							#echo does not exist
     						#fslmaths con_0013.nii -nan noNANcon_0013
     						fslmaths con_0013.nii -thr 0 -bin posmask_con_0013
							fslmaths con_0013.nii -mas posmask_con_0013 maskedcon_0013.nii     						
     						#fslmaths con_0014.nii -nan noNANcon_0014
     						#fslmaths con_0015.nii -nan noNANcon_0015
     						#fslmaths con_0016.nii -nan noNANcon_0016
						fi

     					for this_maskroi_file in maskedWFU*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
					 		fslmeants -i noNANcon_0013.nii -o meantsWFUROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0014.nii -o meantsWFUROI_${this_maskroi_corename}_high.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0015.nii -o meantsWFUROI_${this_maskroi_corename}_low.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0016.nii -o meantsWFUROI_${this_maskroi_corename}_medium.txt -m $this_maskroi_file
					 	done
					fi
					if [[ $this_functional_run_folder == "06_Nback" ]]; then
						if ! [ -e con_0017.nii ]; then
							#echo does not exist
     						fslmaths con_0017.nii -nan noNANcon_0017
     						fslmaths con_0018.nii -nan noNANcon_0018
     						fslmaths con_0019.nii -nan noNANcon_0019
     						fslmaths con_0020.nii -nan noNANcon_0020
						fi
						for this_maskroi_file in maskedWFU*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
							fslmeants -i noNANcon_0020.nii -o meantsNetworkROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0017.nii -o meantsNetworkROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0019.nii -o meantsNetworkROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0018.nii -o meantsNetworkROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file
						done
					fi
				done
			done <<< "$subjects"
		done
	fi

	if [[ $this_roi_analysis_step == "collect_intensity_from_WFU_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					if [ -e ${this_subject}_meantsWFUROI_roi_results.txt ]; then
   	    	       		rm ${this_subject}_meantsWFUROI_roi_results.txt
   	    	   		fi
					for this_txt_file in meantsWFUROI_*.txt; do

						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_txt_file)
						
						echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
					done
					cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done	
	fi
#####################################################################################################################################################

# network ROI
if [[ $this_roi_analysis_step == "extract_intensity_from_network_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
					cp $Study_dir/ROIs_Networks/network_*.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   				cp ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   				cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
 
 					rm noNANcon_00*.nii
					shopt -s nullglob
					prefix_to_delete=(mask*)
					if [ -e "$prefix_to_delete" ]; then
						rm mask*
					fi

					if [ -e brain_mask.nii ]; then
						rm brain_mask.nii
					fi
#
					ml fsl
					fslmaths ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii -bin brain_mask
					gunzip *nii.gz

					for this_roi_file in network*.nii; do
						this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
						#echo $this_roi_file
						ml fsl
				#
						flirt -in $this_roi_file -ref con_0001.nii -applyxfm -usesqform -out mask${this_roi_corename}
						gunzip *nii.gz*		

						fslmaths mask${this_roi_corename}.nii -mas brain_mask.nii masked${this_roi_corename}.nii
						gunzip *nii.gz*								

					done

					ml fsl
     				if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
     					if ! [ -e noNANcon_0013.nii ]; then
							#echo does not exist
     						fslmaths con_0013.nii -nan noNANcon_0013
     						fslmaths con_0014.nii -nan noNANcon_0014
     						fslmaths con_0015.nii -nan noNANcon_0015
     						fslmaths con_0016.nii -nan noNANcon_0016
						fi
     					for this_maskroi_file in maskednetwork*.nii; do

     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
					 		fslmeants -i noNANcon_0013.nii -o meantsNetworkROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0014.nii -o meantsNetworkROI_${this_maskroi_corename}_high.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0015.nii -o meantsNetworkROI_${this_maskroi_corename}_low.txt -m $this_maskroi_file
					 		fslmeants -i noNANcon_0016.nii -o meantsNetworkROI_${this_maskroi_corename}_medium.txt -m $this_maskroi_file
					 	done
					fi
					if [[ $this_functional_run_folder == "06_Nback" ]]; then
						if ! [ -e con_0017.nii ]; then
							#echo does not exist
     						fslmaths con_0017.nii -nan noNANcon_0017
     						fslmaths con_0018.nii -nan noNANcon_0018
     						fslmaths con_0019.nii -nan noNANcon_0019
     						fslmaths con_0020.nii -nan noNANcon_0020
						fi
						for this_maskroi_file in maskednetwork*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
     						echo $this_maskroi_corename
     						echo $this_maskroi_file
     						fslmeants -i noNANcon_0020.nii -o meantsNetworkROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0017.nii -o meantsNetworkROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0019.nii -o meantsNetworkROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
							fslmeants -i noNANcon_0018.nii -o meantsNetworkROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file
						done
					fi
				done
			done <<< "$subjects"
		done
	fi

	if [[ $this_roi_analysis_step == "collect_intensity_from_network_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					if [ -e ${this_subject}_meantsNetworkROI_roi_results.txt ]; then
   	    	       		rm ${this_subject}_meantsNetworkROI_roi_results.txt
   	    	   		fi
					for this_txt_file in meantsNetworkROI_*.txt; do

						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
						this_txt_file_contents=$(cat $this_txt_file)
						
						echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_${this_txt_file_prefix}_roi_results.txt
					done
					cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done	
	fi
done