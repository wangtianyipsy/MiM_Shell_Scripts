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
step_counter=0
wu_dir=/blue/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/MiM_Data/
cd "${wu_dir}"

for this_subject_directory in wu120_*/; do
	# echo $this_subject_directory
	cd ${wu_dir}/$this_subject_directory

	# step 1
	# mkdir -p Processed/MRI_files

	#step 2
	# dirs_2_mv=$(ls -d -- */)
	# dirs_2_mv=$(ls -I "Processed")
	# for this_dir in $dirs_2_mv; do
	# 	mv ${this_dir}/* Processed/MRI_files/
	# done

	#step 3
	# rm -r anat
	# rm -r func

	#step 4
	# cd Processed/MRI_files
	# mkdir -p 02_T1
	# mkdir -p 04_rsfMRI

	#step 5
	# cd Processed/MRI_files
	# mv *T1w* 02_T1
	

	#step 6
	# cd Processed/MRI_files/02_T1
	# gunzip *nii.gz
	# mv *T1* T1.nii

	#step 7
	# cd Processed/MRI_files/04_rsfMRI
	# gunzip *.nii.gz
	# mv *bold* RestingState.nii

	#step 8
	# cd ${wu_dir}
	# cp RestingState.json ${wu_dir}/$this_subject_directory/Processed/MRI_files/04_rsfMRI
	# cp file_settings.txt ${wu_dir}/$this_subject_directory

	#step 9
	# asdf=$(echo $this_subject_directory | cut -d'-' -f2)
	# echo $asdf
 #    mv $this_subject_directory wu120_${asdf} 

 	#step 10
	# cd ${wu_dir}/$this_subject_directory/Processed/MRI_files/04_rsfMRI
	# mv RestingState.nii slicetimed_RestingState.nii

	#step 11
	cd Processed/MRI_files/04_rsfMRI
	FILE=(slicetimed_RestingState1.nii)
	if [[ -e "$FILE" ]];then
		echo ${this_subject_directory}
		# cd ${wu_dir}
		# cp file_settings.txt ${this_subject_directory}
		# cd ${this_subject_directory}Processed/MRI_files/04_rsfMRI
		# files_to_change=$(echo *bold.nii)
		# index=1
		# for this_file in ${files_to_change[@]}; do 
		# 	mv $this_file slicetimed_RestingState${index}.nii
		# 	(( index++ )) 
		# done
		# files_to_change=
		# cd ${wu_dir}
	fi
done