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
Study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
cd "${Study_dir}"

for this_roi_analysis_step in "${roi_analysis_steps[@]}"; do
	
# for predetmined rois (.txt has manually entered mni coords)
#####################################################################################################################################################
	 if [[ $this_roi_analysis_step == "convert_load_sensitive_voxel_coordinates" ]]; then
	 	for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
	 		if [[ $this_functional_run_folder == "05_MotorImagery" ]] ; then
	 			cd ${Study_dir}/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/
	 			shopt -s nullglob
				prefix_to_delete=(roi_*.csv)
   				if  [ -e $prefix_to_delete ]; then 
	      			rm roi_*.csv
	      		fi

				cd $Study_dir


				lines_to_ignore=$(awk '/#/{print NR}' MotorImagery_roi_load_young.txt)

				roi_line_numbers=$(awk 'END{print NR}' MotorImagery_roi_load_young.txt)
				for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
					if ! [[ ${lines_to_ignore[*]} =~ $this_row ]]; then
						if [[ $group_name == oldAdult ]]; then 
							this_roi_name=$(cat MotorImagery_roi_load_old.txt | sed -n ${this_row}p | cut -d ',' -f1)
							this_roi_x=$(cat MotorImagery_roi_load_old.txt | sed -n ${this_row}p | cut -d ',' -f2)
							this_roi_y=$(cat MotorImagery_roi_load_old.txt | sed -n ${this_row}p | cut -d ',' -f3)
							this_roi_z=$(cat MotorImagery_roi_load_old.txt | sed -n ${this_row}p | cut -d ',' -f4)
						fi
						if [[ $group_name == youngAdult ]]; then 
							this_roi_name=$(cat MotorImagery_roi_load_young.txt | sed -n ${this_row}p | cut -d ',' -f1)
							this_roi_x=$(cat MotorImagery_roi_load_young.txt | sed -n ${this_row}p | cut -d ',' -f2)
							this_roi_y=$(cat MotorImagery_roi_load_young.txt | sed -n ${this_row}p | cut -d ',' -f3)
							this_roi_z=$(cat MotorImagery_roi_load_young.txt | sed -n ${this_row}p | cut -d ',' -f4)
						fi
						cd ${Study_dir}/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/
						
						ml matlab
						matlab -nodesktop -nosplash -r "try; convert_to_voxel_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
						cd $Study_dir
					fi
				done
	 		fi
	 	done
	fi

	if [[ $this_roi_analysis_step == "create_roi_sphere_for_load_sensitive_rois" ]]; then
		for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					shopt -s nullglob
					prefix_to_delete=(*roi_results.txt)
   					if  [ -e $prefix_to_delete ]; then 
	      				rm *_roi_results.txt
	      				rm brain_mask.nii
	      				rm brain_mask.nii.gz
	      			fi
   				done
			done <<< "$subjects"

			
			cd ${Code_dir}/MR_Templates
			#if ! [ -e brain_mask.nii ]; then 
				rm brain_mask.nii
	      				rm brain_mask.nii.gz
				ml fsl
				fslmaths MNI_2mm.nii -bin brain_mask
				gunzip *nii.gz
				cp brain_mask.nii $Study_dir/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/
			#fi

		 	cd $Study_dir/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/
			for this_roi_file in roi_*.csv; do
				
				this_roi_file_corename=$(echo $this_roi_file | cut -d. -f 1)
				this_roi_corename=$(echo $this_roi_file_corename | cut -d'_' -f 2)
				
				this_roi_x=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f1)
				this_roi_y=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f2)
				this_roi_z=$(cat $this_roi_file | sed -n 2p | cut -d ',' -f3)

			
				if [ -e LoadSensitiveROI_${this_roi_corename}_point.nii ]; then 
					rm LoadSensitiveROI_${this_roi_corename}_point.nii
					rm LoadSensitiveROI_${this_roi_corename}_sphere5mm.nii
					rm maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii
				fi

				#fslmaths MNI_2mm.nii -bin brain_mask
				#gunzip *nii.gz
				#cp brain_mask.nii $Study_dir/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/

				ml fsl
				echo converting ${this_roi_corename}: $this_roi_x $this_roi_y $this_roi_z to 5mm sphere ....
				fslmaths con_0001.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 LoadSensitiveROI_${this_roi_corename}_point -odt float
				fslmaths LoadSensitiveROI_${this_roi_corename}_point.nii -kernel sphere 5 -fmean LoadSensitiveROI_${this_roi_corename}_sphere5mm.nii -odt float
				gunzip *nii.gz*
						
				fslmaths LoadSensitiveROI_${this_roi_corename}_sphere5mm.nii -mas brain_mask.nii maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii
				gunzip *nii.gz*		

				while IFS=',' read -ra subject_list; do
   				    for this_subject in "${subject_list[@]}"; do
   				    	cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   				    	if [ -e maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii ]; then 
   					    	rm LoadSensitiveROI_${this_roi_corename}_sphere5mm.nii
   				    		rm maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii
   				    	fi

   				    	cp $Study_dir/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      				
	      				echo Currently calculating average activation for $this_subject at ${this_roi_corename}


     					if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then
				 			beta=0
							outfile=${this_subject}_${this_roi_corename}_roi_results.txt
							beta=$(fslmeants -i con_0001.nii -m maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii)
				 			echo -e "$beta", flat, >> "$outfile"				​
							
				 			beta=$(fslmeants -i con_0002.nii -m maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii)
				 			echo -e "$beta", low, >> "$outfile"				​
							
				 			beta=$(fslmeants -i con_0003.nii -m maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii)
							echo -e "$beta", medium, >> "$outfile"				​
							
							beta=$(fslmeants -i con_0004.nii -m maskedLoadSensitiveROI_${this_roi_corename}_sphere5mm.nii)
							echo -e "$beta", high, >> "$outfile"				​
							
						fi	
						cd $Study_dir/betweenGroup_Results_3Fac/MRI_files/${this_functional_run_folder}/
					done
 				done <<< "$subjects"
 									
			done
			
		done
	fi

	if [[ $this_roi_analysis_step == "collect_load_sensitive_rois" ]]; then
		data_folder_to_analyze=($fmri_processed_folder_names)
		for this_functional_run_folder in ${data_folder_to_analyze[@]}; do
			while IFS=',' read -ra subject_list; do
   				for this_subject in "${subject_list[@]}"; do
   					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			echo Currently collecting roi results for $this_subject

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					 if [ -e ${this_subject}_roi_results.txt ]; then
   	     	       		rm ${this_subject}_roi_results.txt
   	     	       		rm *meants5mmLoadSensitiveROI_roi_results.txt
   	     	   		fi


   	    	   		#rm ${this_subject}_meants5mmLoadSensitiveROI_roi_results.txt
					for this_txt_file in *roi_results*.txt; do
						this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						this_txt_roi_name=$(echo $this_txt_file_core_name | cut -d_ -f 2)

						roi_line_numbers=$(awk 'END{print NR}' $this_txt_file)
						for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
							this_roi_beta=$(cat $this_txt_file| sed -n ${this_row}p | cut -d ',' -f1)
							this_roi_condition=$(cat $this_txt_file| sed -n ${this_row}p | cut -d ',' -f2)
					
							echo $this_txt_roi_name, $this_roi_condition, $this_roi_beta, >> ${this_subject}_roi_results.txt
						done
					done
					cd $Study_dir/Crunch_Effects/${this_functional_run_folder}/${group_name}
					if [ -e ${this_subject}_roi_results.txt ]; then
   	     	       		rm ${this_subject}_roi_results.txt
   	     	   		fi
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			cp ${this_subject}_roi_results.txt ${Study_dir}/Crunch_Effects/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done
	fi

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
						rm noNAN*.nii
     					rm pos*.nii
					fi

					if [ -e brain_mask.nii ]; then
						rm brain_mask.nii
					fi

					#if [ -e posmask_con_0013.nii ]; then
						#rm maskedcon_0013.nii
					#	rm posmask_con_0013.nii
					#fi

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
     					
     				#	rm posmask_spmT_0013.nii
     				#	rm maskedspmT_0013.nii
     				#	rm noNANmaskedspmT_0013.nii
     				#	rm posmask_spmT_0014.nii
     					#rm maskedspmT_0014.nii
     				#	rm noNANmaskedspmT_0014.nii
     				#	rm posmask_spmT_0015.nii
     				#	rm maskedspmT_0015.nii
     				#	rm noNANmaskedspmT_0015.nii
     				#	rm posmask_spmT_0016.nii
     				#	rm maskedspmT_0016.nii
     				#	rm noNANmaskedspmT_0016.nii

     					#if ! [ -e posmask_con_0013.nii ]; then
     					#if ! [ -e noNANcon_0013.nii ]; then
							#echo does not exist
     						#fslmaths con_0013.nii -nan noNANcon_0013

     						# try a different type of threshold ... this does not seem to be working
     						#fslmaths con_0013.nii -thr 0.001 -bin posmask_con_0013.nii
							#fslmaths con_0013.nii -mas posmask_con_0013.nii maskedcon_0013.nii
							#gunzip *nii.gz*
							#fslmaths maskedcon_0013.nii -nan noNANmaskedcon_0013.nii
							#gunzip *nii.gz*			

							fslmaths spmT_0013.nii -thr 0.001 -bin posmask_spmT_0013.nii
							gunzip *nii.gz*
							fslmaths spmT_0013.nii -mas posmask_spmT_0013.nii maskedspmT_0013.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0013.nii -nan noNANmaskedspmT_0013.nii
							gunzip *nii.gz*

							fslmaths spmT_0014.nii -thr 0.001 -bin posmask_spmT_0014.nii
							gunzip *nii.gz*
							fslmaths spmT_0014.nii -mas posmask_spmT_0014.nii maskedspmT_0014.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0014.nii -nan noNANmaskedspmT_0014.nii
							gunzip *nii.gz*

							fslmaths spmT_0015.nii -thr 0.001 -bin posmask_spmT_0015.nii
							gunzip *nii.gz*
							fslmaths spmT_0015.nii -mas posmask_spmT_0015.nii maskedspmT_0015.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0015.nii -nan noNANmaskedspmT_0015.nii
							gunzip *nii.gz*

							fslmaths spmT_0016.nii -thr 0.001 -bin posmask_spmT_0016.nii
							gunzip *nii.gz*
							fslmaths spmT_0016.nii -mas posmask_spmT_0016.nii maskedspmT_0016.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0016.nii -nan noNANmaskedspmT_0016.nii
							gunzip *nii.gz*						
     						
     						#fslmaths con_0014.nii -nan noNANcon_0014
     						#fslmaths con_0015.nii -nan noNANcon_0015
     						#fslmaths con_0016.nii -nan noNANcon_0016
						#fi

     					for this_maskroi_file in maskedWFU*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
					 		#fslmeants -i noNANmaskedspmT_0013.nii -o meantsWFUROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file
					 		
					 		#fslmeants -i noNANmaskedcon_0013.nii -o meantsWFUROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file

					 		fslmeants -i noNANmaskedspmT_0013.nii -o meantsWFUROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0014.nii -o meantsWFUROI_${this_maskroi_corename}_high.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0015.nii -o meantsWFUROI_${this_maskroi_corename}_low.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0016.nii -o meantsWFUROI_${this_maskroi_corename}_medium.txt -m $this_maskroi_file
					 		
					 		#fslmeants -i noNANcon_0014.nii -o meantsWFUROI_${this_maskroi_corename}_high.txt -m $this_maskroi_file
					 		#fslmeants -i noNANcon_0015.nii -o meantsWFUROI_${this_maskroi_corename}_low.txt -m $this_maskroi_file
					 		#fslmeants -i noNANcon_0016.nii -o meantsWFUROI_${this_maskroi_corename}_medium.txt -m $this_maskroi_file
					 	done
					fi
					if [[ $this_functional_run_folder == "06_Nback" ]]; then
     					rm posmask_spmT_0017.nii
     					rm maskedspmT_0017.nii
     					rm noNANmaskedspmT_0017.nii
     					rm posmask_spmT_0018.nii
     					rm maskedspmT_0018.nii
     					rm noNANmaskedspmT_0018.nii
     					rm posmask_spmT_0019.nii
     					rm maskedspmT_0019.nii
     					rm noNANmaskedspmT_0019.nii
     					rm posmask_spmT_0020.nii
     					rm maskedspmT_0020.nii
     					rm noNANmaskedspmT_0020.nii
						if ! [ -e posmask_spmT_0017.nii ]; then
							#echo does not exist
     						#fslmaths con_0017.nii -nan noNANcon_0017
     						#fslmaths con_0018.nii -nan noNANcon_0018
     						#fslmaths con_0019.nii -nan noNANcon_0019
     						#fslmaths con_0020.nii -nan noNANcon_0020
     						fslmaths spmT_0017.nii -thr 0.001 -bin posmask_spmT_0017.nii
							gunzip *nii.gz*
							fslmaths spmT_0017.nii -mas posmask_spmT_0017.nii maskedspmT_0017.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0017.nii -nan noNANmaskedspmT_0017.nii
							gunzip *nii.gz*

							fslmaths spmT_0018.nii -thr 0.001 -bin posmask_spmT_0018.nii
							gunzip *nii.gz*
							fslmaths spmT_0018.nii -mas posmask_spmT_0018.nii maskedspmT_0018.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0018.nii -nan noNANmaskedspmT_0018.nii
							gunzip *nii.gz*

							fslmaths spmT_0019.nii -thr 0.001 -bin posmask_spmT_0019.nii
							gunzip *nii.gz*
							fslmaths spmT_0019.nii -mas posmask_spmT_0019.nii maskedspmT_0019.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0019.nii -nan noNANmaskedspmT_0019.nii
							gunzip *nii.gz*

							fslmaths spmT_0020.nii -thr 0.001 -bin posmask_spmT_0020.nii
							gunzip *nii.gz*
							fslmaths spmT_0020.nii -mas posmask_spmT_0020.nii maskedspmT_0020.nii
							gunzip *nii.gz*
							fslmaths maskedspmT_0020.nii -nan noNANmaskedspmT_0020.nii
							gunzip *nii.gz*			
						fi
						for this_maskroi_file in maskedWFU*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
     						fslmeants -i noNANmaskedspmT_0020.nii -o meantsWFUROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0017.nii -o meantsWFUROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0019.nii -o meantsWFUROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
					 		fslmeants -i noNANmaskedspmT_0018.nii -o meantsWFUROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0020.nii -o meantsNetworkROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0017.nii -o meantsNetworkROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0019.nii -o meantsNetworkROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0018.nii -o meantsNetworkROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file

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
   					#cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
	      			

					# for each txt file parse variable name , read contents and place in subject_roi_results.txt
					#if [ -e ${this_subject}_meantsWFUROI_roi_results.txt ]; then
   	    	       	#	rm ${this_subject}_meantsWFUROI_roi_results.txt
   	    	   		#fi
					#for this_txt_file in meantsWFUROI_*.txt; do

					#	this_txt_file_core_name=$(echo $this_txt_file | cut -d. -f 1)
						
						
					#	this_txt_file_prefix=$(echo $this_txt_file_core_name | cut -d_ -f 1)
					#	this_txt_file_contents=$(cat $this_txt_file)
					#	echo Extracting: $this_txt_file_core_name $this_subject ${this_functional_run_folder} = $this_txt_file_contents
						
					#	echo $this_txt_file_core_name, $this_txt_file_contents >> ${this_subject}_meantsWFUROI_roi_results.txt
					#done
					cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					rm ${this_subject}_meantsWFUROI_roi_results.txt
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					cp ${this_subject}_meantsWFUROI_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
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
   					echo extracting betas for $this_subject
					cd $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results

					shopt -s nullglob
					prefix_to_delete=(mask*)
					if [ -e "$prefix_to_delete" ]; then
						rm mask*
						rm meantsNetworkROI_*.txt
						rm noNAN*.nii
     					rm pos*.nii
     					rm network*
					fi

					if [ -e brain_mask.nii ]; then
						rm brain_mask.nii
					fi

   	   				cp $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
   	   				
   	   				ml fsl
					fslmaths ANTs_c0Template_T1_IXI555_MNI152_GS_brain.nii -bin brain_mask
					gunzip *nii.gz


					ml fsl
     				if [[ $this_functional_run_folder == "05_MotorImagery" ]]; then

     					cp $Study_dir/ROIs_Networks/networkZMotorImagery.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
     					cp $Study_dir/ROIs_Networks/networkDefaultmode.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
       					cp $Study_dir/ROIs_Networks/networkSomatosensory.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					
     					for this_roi_file in network*.nii; do
							this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
							#echo $this_roi_file
							ml fsl
					
							flirt -in $this_roi_file -ref con_0001.nii -applyxfm -usesqform -out mask${this_roi_corename}
							gunzip *nii.gz*		
	
							fslmaths mask${this_roi_corename}.nii -mas brain_mask.nii masked${this_roi_corename}.nii
							gunzip *nii.gz*								
	
						done

     					for this_maskroi_file in maskednetwork*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
					 		fslmeants -i spmT_0001.nii -o meantsNetworkROI_${this_maskroi_corename}_flat.txt -m $this_maskroi_file
					 		fslmeants -i spmT_0002.nii -o meantsNetworkROI_${this_maskroi_corename}_high.txt -m $this_maskroi_file
					 		fslmeants -i spmT_0003.nii -o meantsNetworkROI_${this_maskroi_corename}_low.txt -m $this_maskroi_file
					 		fslmeants -i spmT_0004.nii -o meantsNetworkROI_${this_maskroi_corename}_medium.txt -m $this_maskroi_file
					 	done
					fi
					if [[ $this_functional_run_folder == "06_Nback" ]]; then
						cp $Study_dir/ROIs_Networks/networkWorkingmemory.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
     					cp $Study_dir/ROIs_Networks/networkDefaultmode.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
       					cp $Study_dir/ROIs_Networks/networkSomatosensory.nii $Study_dir/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					
     						for this_roi_file in network*.nii; do
								this_roi_corename=$(echo $this_roi_file | cut -d. -f 1)
								#echo $this_roi_file
								ml fsl
						
								flirt -in $this_roi_file -ref con_0001.nii -applyxfm -usesqform -out mask${this_roi_corename}
								gunzip *nii.gz*	
		
								fslmaths mask${this_roi_corename}.nii -mas brain_mask.nii masked${this_roi_corename}.nii
								gunzip *nii.gz*
		
							done

     				
						for this_maskroi_file in maskednetwork*.nii; do
     						this_maskroi_corename=$(echo $this_maskroi_file | cut -d. -f 1)
     						echo $this_maskroi_corename
     						echo $this_maskroi_file
     						#fslmeants -i noNANcon_0020.nii -o meantsNetworkROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0017.nii -o meantsNetworkROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0019.nii -o meantsNetworkROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
							#fslmeants -i noNANcon_0018.nii -o meantsNetworkROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file

							fslmeants -i noNANmaskedspmT_0020.nii -o meantsNetworkROI_${this_maskroi_corename}_zero.txt -m $this_maskroi_file
							fslmeants -i noNANmaskedspmT_0017.nii -o meantsNetworkROI_${this_maskroi_corename}_one.txt -m $this_maskroi_file
							fslmeants -i noNANmaskedspmT_0019.nii -o meantsNetworkROI_${this_maskroi_corename}_two.txt -m $this_maskroi_file
							fslmeants -i noNANmaskedspmT_0018.nii -o meantsNetworkROI_${this_maskroi_corename}_three.txt -m $this_maskroi_file
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
					cd $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
					rm ${this_subject}_meantsNetworkROI_roi_results.txt
					cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_Results
					cp ${this_subject}_${this_txt_file_prefix}_roi_results.txt $Study_dir/withinGroup_Results/MRI_files/${this_functional_run_folder}/${group_name}
				done
			done <<< "$subjects"
		done
	fi
done