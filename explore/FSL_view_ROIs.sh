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

settings_file=$1

Code_dir=/ufrc/rachaelseidler/tfettrow/Crunch_Code
	
export MATLABPATH=${Code_dir}/Matlab_Scripts/helper


Study_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data

cd "${Study_dir}"

lines_to_ignore=$(awk '/#/{print NR}' $settings_file)

roi_line_numbers=$(awk 'END{print NR}' $settings_file)
for (( this_row=1; this_row<=${roi_line_numbers}; this_row++ )); do
	if ! [[ ${lines_to_ignore[*]} =~ $this_row ]]; then
		this_roi_name=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f4)
		this_roi_x=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f1)
		this_roi_y=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f2)
		this_roi_z=$(cat $settings_file | sed -n ${this_row}p | cut -d ',' -f3)

		cd ${Study_dir}/ROIs
		
		xvfb-run -s "-screen 0 640x480x24" fsleyes render --scene ortho --outfile ${Code_dir}/MR_Templates/Gordon_Parcels_Brain \
		${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/MNI_2mm.nii -cm red-yellow \
		${Subject_dir}/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/$this_functional_file --alpha 85
	fi	
done