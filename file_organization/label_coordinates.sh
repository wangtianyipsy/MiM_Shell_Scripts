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

# label_coordinates.sh ROI_labels_conn_wu120_all_wb.txt AAL

#### use neuromorphometrica ####
#### insert different templates ### as argument??

argument_counter=0
for this_argument in "$@"; do
	if	[[ $argument_counter == 0 ]]; then
		settings_file=$this_argument
	elif [[ $argument_counter == 1 ]]; then
		atlas=$this_argument
	fi
	(( argument_counter++ ))
done

Code_dir=/blue/rachaelseidler/tfettrow/Crunch_Code
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper

Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data

cd "${Study_dir}"
analysis_name=$(echo "$settings_file" | cut -d'_' -f3-)
# echo $analysis_name
if [ -e $ROI_labels_${analysis_name} ]; then
  	rm $ROI_labels_${analysis_name}
fi

outfile=ROI_labels_${analysis_name}

lines_to_ignore=$(awk '/#/{print NR}' $settings_file)

roi_line_numbers=$(awk 'END{print NR}' $settings_file)
for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
	if ! [[ ${lines_to_ignore[*]} =~ $this_row ]]; then
		this_roi_name=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f4)
		this_roi_x=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f1)
		this_roi_y=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f2)
		this_roi_z=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f3)
		this_network_name=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f5)
		
		cd ${Study_dir}/ROIs/
		ml fsl
		if [[ $atlas == AAL ]]; then
			fslmaths MNI_2mm.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ${this_roi_name}_point.nii -odt float	
			gunzip -f *nii.gz
			brain_area_code=$(fslmeants -i ${Study_dir}/ROIs/AAL_Labeling_Files/AAL3_2mm.nii -m ${this_roi_name}_point.nii)
			brain_area_code=$(printf "%.0f" $(echo "$brain_area_code" | bc))
			#echo $brain_area_code
	
			brain_area_name=$(cat ${Study_dir}/ROIs/AAL_Labeling_Files/AAL3.nii.txt | sed -n ${brain_area_code}p | cut -d ' ' -f2)
			#echo $brain_area_name
		elif [[ $atlas == SUIT ]] ; then
			ml matlab/2020a
			matlab -nodesktop -nosplash -r "try; convert_to_mni_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
			this_roi_x=$(cat "mni_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f1)
			this_roi_y=$(cat "mni_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f2)
			this_roi_z=$(cat "mni_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f3)

			matlab -nodesktop -nosplash -r "try; convert_to_suitVoxel_coordinates '$this_roi_name' '$this_roi_x' '$this_roi_y' '${this_roi_z}'; catch; end; quit"
			this_roi_x=$(cat "suitVoxel_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f1)
			this_roi_y=$(cat "suitVoxel_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f2)
			this_roi_z=$(cat "suitVoxel_${this_roi_name}.csv" | sed -n 2p | cut -d ',' -f3)
			
			if [ -e ${this_roi_name}_point.nii ]; then
				rm ${this_roi_name}_point.nii
			fi
			fslmaths ${Study_dir}/ROIs/SUIT_Labeling_Files/SUIT_2mm.nii -mul 0 -add 1 -roi $this_roi_x 1 $this_roi_y 1 $this_roi_z 1 0 1 ${this_roi_name}_point.nii -odt float
			gunzip -f *nii.gz
			brain_area_code=$(fslmeants -i ${Study_dir}/ROIs/SUIT_Labeling_Files/SUIT_2mm.nii -m ${this_roi_name}_point.nii)
			brain_area_code=$(printf "%.0f" $(echo "$brain_area_code" | bc))
			echo $brain_area_code
	
			brain_area_name=$(cat ${Study_dir}/ROIs/SUIT_Labeling_Files/Cerebellum-SUIT.nii.txt | sed -n ${brain_area_code}p | cut -d ' ' -f2)
			echo $brain_area_name
		fi

		# echo ROI:$this_roi_name located in $brain_area_name 
		cd $Study_dir
		echo $this_roi_x, $this_roi_y, $this_roi_z, "$brain_area_name", "$this_network_name" >> "$outfile"	
	fi
done