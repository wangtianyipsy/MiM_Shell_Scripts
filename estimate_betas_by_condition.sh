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

# example >> estimate_betas_by_condition.sh '1002,1004' youngAdult 05_MotorImagery gather_subject_betas_manually_entered_roi ROI_settings_motorimagerySWE.txt

# things to be aware of with this script: 
# 1) only run one step at a time
# 2) only run one population at a time
# 3) only run one task (MotorImagery or Nback) at a time

# potential steps:
#gather_subject_betas_manually_entered_roi
#collect_manually_entered_rois


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
		roi_settings_file=$this_argument
	fi
	(( argument_counter++ ))
done

# TO DO: setup an error if one of these is not present
# echo $subjects
# echo $group_name
# echo $fmri_processed_folder_names
# echo $roi_settings_file

Code_dir=/blue/rachaelseidler/tfettrow/Crunch_Code
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper

#for SUB in ${subjects[@]}; do
Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
#cd "${Study_dir}"
	
#####################################################################################################################################################
	# replaced by convert_rois_to_spheres... should have something synonomous for networks (ask GT/see WFU below)

for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do # only doing one task folder at a time so this for loop not necessary
	ml fsl
	while IFS=',' read -ra subject_list; do
   	    for this_subject in "${subject_list[@]}"; do
   	    	cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results	     					
   	    	if [ -e ${this_subject}_roi_results.txt ]; then
	   	      	rm ${this_subject}_roi_results.txt
	   	    fi
   	    	cd "${Study_dir}"
			lines_to_ignore=$(awk '/#/{print NR}' $roi_settings_file)
			roi_line_numbers=$(awk 'END{print NR}' $roi_settings_file)
			for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
				if ! [[ ${lines_to_ignore[*]} =~ $this_row ]]; then
					this_roi_file_corename=$(cat $roi_settings_file | sed -n ${this_row}p | cut -d ',' -f4)
					this_roi_file_corename_squeeze=$(echo $this_roi_file_corename | sed -r 's/( )+//g')
					this_roi_image_name=${Study_dir}/ROIs/${this_roi_file_corename_squeeze}.nii
					echo pulling betas for $this_roi_image_name on $this_subject
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
    					if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
			 	
			 			# if ! [ -e noNANcon_0001.nii ]; then
     						# fslmaths con_0001.nii -nan noNANcon_0001
     						# fslmaths con_0002.nii -nan noNANcon_0002
     						# fslmaths con_0003.nii -nan noNANcon_0003
     						# fslmaths con_0004.nii -nan noNANcon_0004
     						# gunzip *nii.gz*
     					# fi

						outfile=${this_subject}_roi_results.txt
						beta=0
						beta=$(fslmeants -i con_0001.nii -m $this_roi_image_name)
			 			echo $this_roi_file_corename_squeeze, "$beta", flat >> "$outfile"				​
						
			 			beta=$(fslmeants -i con_0003.nii -m $this_roi_image_name)
			 			echo $this_roi_file_corename_squeeze, "$beta", low >> "$outfile"				​
						
			 			beta=$(fslmeants -i con_0004.nii -m $this_roi_image_name)
						echo $this_roi_file_corename_squeeze, "$beta", medium >> "$outfile"				​
						
						beta=$(fslmeants -i con_0002.nii -m $this_roi_image_name)
						echo $this_roi_file_corename_squeeze, "$beta", high >> "$outfile"				​								
					fi	
					#echo $this_roi_file_corename_squeeze, $this_roi_condition, $this_roi_beta, >> ${this_subject}_roi_results.txt
	 				cd ${Study_dir}
 				fi			
			done
			# cd $Study_dir/Group_Results_loadModulation/MRI_files/${this_functional_run_folder}/${group_name}
			# rm ${this_subject}_roi_results.txt
			# 
			cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
			
			# cp ${this_subject}_roi_results.txt $Study_dir/Group_Results_loadModulation/MRI_files/${this_functional_run_folder}/${group_name}
			# cd ${Study_dir}
		done
 	done <<< "$subjects"
done