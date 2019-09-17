cd /ufrc/davidclark/share/MiM_Code/MiM_Shell_Scripts
#cd /ufrc/rachaelseidler/tfettrow/Crunch_Code/MiM_Shell_Scripts
#####################################################################################
#mkdir -p ${Subject_dir}/Processed/MRI_files/01_Localizer
./cleanup.sh
echo "cleanup done"

./generate_raw_file_info.sh
echo "csv information generated"

./test_organize.sh
echo "test_organize done"

./test_preprocess_fmri.sh
echo "preprocessing done"

echo "THE WHOLE THING (COMPILATION) TOOK $SECONDS seconds TO FINISH"