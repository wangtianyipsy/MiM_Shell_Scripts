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

# this script requires arguments... use the batch_fmri.batch to call this shell script
# example >> combine_subject_mri_redcap.sh '1002,1004,1007,1009,1010,1011,1013,2021,2015,2002,2018,2017,2012,2025,2020,2026,2023,2022,2007,2013,2008,2033,2034,2037' 05_MotorImagery 

argument_counter=0
for this_argument in "$@"; do
	if [[ $argument_counter == 0 ]]; then
		subjects=$this_argument
	elif [[ $argument_counter == 1 ]]; then
		fmri_processed_folder_names=$this_argument
	fi
	(( argument_counter++ ))
done

Study_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data
cd $Study_dir

for this_functional_run_folder in ${fmri_processed_folder_names[@]}; do # only doing one task folder at a time so this for loop not necessary
	ml fsl
	subject_index=0

	outfile=${this_functional_run_folder}_fmri_wholebrain.csv

	if [ -e ${this_functional_run_folder}_fmri_wholebrain.csv ]; then
		rm ${this_functional_run_folder}_fmri_wholebrain.csv
	fi

	while IFS=',' read -ra subject_list; do
   	    for this_subject in "${subject_list[@]}"; do
   	    	cd ${Study_dir}/$this_subject/Processed/MRI_files/${this_functional_run_folder}/ANTS_Normalization/Level1_WholeBrain

   	    	this_subject_header=$(cat ${this_subject}_fmri_wholebrain.csv | sed -n 1p)
   	    	this_subject_data=$(cat ${this_subject}_fmri_wholebrain.csv | sed -n 2p)
			
			cd ${Study_dir}
   	    	this_subject_header_outfile=$(cat $outfile | sed 1d)

   			row1=$this_subject_header
			existing_section=$this_subject_header_outfile
			new_row=$this_subject_data
			if [[ subject_index == 0 ]]; then
				echo -e "$row1\n$new_row" >> "$outfile"
			else
				rm $outfile
				echo -e "$row1\n$existing_section\n$new_row" >> "$outfile"
			fi
			(( subject_index++ ))
		done
 	done <<< "$subjects"
done