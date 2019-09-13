#####################################################################################
ml mricrogl
ml gcc/5.2.0
ml pigz


subjects=(CrunchPilot01_development1)

for SUB in ${subjects[@]}; do

	Subject_dir=/ufrc/rachaelseidler/share/FromExternal/Research_Projects_UF/CRUNCH/Pilot_Study_Data/${SUB}

	cd $Subject_dir

	
	number_of_folders_to_extract=$(cat ${SUB}_file_information.csv | wc -l)
	for (( this_folder_row=1; this_folder_row<=${number_of_folders_to_extract}; this_folder_row++ )); do
		this_raw_folder_name=$(cat ${SUB}_file_information.csv | sed -n ${this_folder_row}p | cut -d ',' -f1)
		this_processed_folder_name=$(cat ${SUB}_file_information.csv | sed -n ${this_folder_row}p  | cut -d ',' -f2)
		this_processed_file_name=$(cat ${SUB}_file_information.csv | sed -n ${this_folder_row}p | cut -d ',' -f3)

		mkdir -p "${Subject_dir}/Processed/MRI_files/${this_processed_folder_name}"
	
		cd ${Subject_dir}/Raw/MRI_files/$this_raw_folder_name
		rm *.nii.gz*
		rm *.nii
		rm *.json
	
		dcm2niix -ba n ${Subject_dir}/Raw/MRI_files/$this_raw_folder_name
	
		for nii_file in *.nii*; do
			mv -v ${nii_file} $this_processed_file_name.nii
			cp $this_processed_file_name.nii "${Subject_dir}/Processed/MRI_files/${this_processed_folder_name}";
		done
	
		for json_file in *.json*; do
			mv -v ${json_file} $this_processed_file_name.json
			cp $this_processed_file_name.json "${Subject_dir}/Processed/MRI_files/$this_processed_folder_name";
		done
	done
done
