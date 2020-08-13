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

Code_dir=/blue/rachaelseidler/tfettrow/Crunch_Code

export MATLABPATH=${Code_dir}/Matlab_Scripts/helper

Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data

subjects='2007,2012,2008,2021,2015'
# subjects='1002,1004,1010,1011,1013'

output_filename=OAnsDartelNoBS_subject_normalized_intensity_variability.nii
file_to_compare='warpedToSUITdartelNoBrainstem_coregToSUIT_CBmasked_coregToT1_unwarpedRealigned_slicetimed_fMRI_Run1.nii'
image_folder='05_MotorImagery'
#image_folder='06_Nback'

while IFS=',' read -ra subject_list; do
   for this_subject in "${subject_list[@]}"; do
		cd ${Study_dir}/$this_subject/Processed/MRI_files/${image_folder}/ANTS_Normalization
      echo collecting $this_subject variability estimates
   	ml fsl

      this_file_header_info=$(fslhd $file_to_compare)
      this_file_number_of_volumes=$(echo $this_file_header_info | grep -o dim4.* | tr -s ' ' | cut -d ' ' -f 2)
      echo $this_file_number_of_volumes
      
      if [[ -e ${this_subject}_normalized_intensity_for_subject_normalization_variability_analysis.nii ]]; then 
         rm ${this_subject}_normalized_intensity_for_subject_normalization_variability_analysis.nii
      fi

      if [[ $this_file_number_of_volumes == 1 ]]; then
         
         fslmaths $file_to_compare -nan noNAN_$file_to_compare
         gunzip -f *nii.gz
         cp noNAN_$file_to_compare duplicate_$file_to_compare
         gunzip -f *nii.gz
         fslmerge -t merged_$file_to_compare noNAN_$file_to_compare duplicate_$file_to_compare
         gunzip -f *nii.gz
         fslmaths merged_$file_to_compare -Tmean Mean_$file_to_compare
         gunzip -f *nii.gz
         
         rm merged_$file_to_compare
         rm duplicate_$file_to_compare
         rm noNAN_$file_to_compare

         in_brain_mean=$(fslmeants -i Mean_$file_to_compare -m Mean_$file_to_compare)
         echo $in_brain_mean

         fslmaths $file_to_compare -div $in_brain_mean ${this_subject}_normalized_intensity_for_subject_normalization_variability_analysis
         gunzip -f *nii.gz
      else
         fslmaths $file_to_compare -Tmean Mean_$file_to_compare
         
         in_brain_mean=$(fslmeants -i Mean_$file_to_compare -m Mean_$file_to_compare)
         echo $in_brain_mean

         fslmaths Mean_$file_to_compare -div $in_brain_mean ${this_subject}_normalized_intensity_for_subject_normalization_variability_analysis
         gunzip -f *nii.gz
      fi
	done
done <<< "$subjects"
cd $Study_dir

while IFS=',' read -ra subject_list; do
   for this_subject in "${subject_list[@]}"; do
   		cd ${Study_dir}/$this_subject/Processed/MRI_files/${image_folder}/ANTS_Normalization
   		cp ${this_subject}_normalized_intensity_for_subject_normalization_variability_analysis.nii $Study_dir
	done
done <<< "$subjects"

cd $Study_dir
ml fsl
fslmerge -t all_subject_normalized_intensity.nii *normalization_variability_analysis.nii
gunzip -f *nii.gz
fslmaths all_subject_normalized_intensity.nii -Tstd $output_filename
gunzip -f *nii.gz
rm *normalization_variability_analysis.nii
rm all_subject_normalized_intensity.nii