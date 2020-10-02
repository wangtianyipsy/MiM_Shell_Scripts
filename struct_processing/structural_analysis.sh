#cat12('expert')

if [[ $this_preprocessing_step == "cat12StructuralAnalysis" ]]; the
	this_t1_folder=($t1_processed_folder_names)
	cp ${Code_dir}/MR_Templates/Template_*.nii ${Subject_dir}/Processed/MRI_files/${this_t1_folder}
	cd ${Subject_dir}/Processed/MRI_files/${this_t1_folder}
	ml matlab
	matlab -nodesktop -nosplash -r "try; cat12StructuralAnalysis; catch; end; quit"
fi