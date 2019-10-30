#cd /ufrc/davidclark/share/MiM_Code/MiM_Shell_Scripts
cd /ufrc/rachaelseidler/tfettrow/Crunch_Code/MiM_Shell_Scripts
#####################################################################################
#mkdir -p ${Subject_dir}/Processed/MRI_files/01_Localizer
#./cleanup.sh
#echo "cleanup done"

./generate_raw_file_info.sh
echo "csv information generated"

./file_organize.sh
echo "file_organize done"

#./preprocess_fmri.sh
#echo "preprocessing done"
ml parallel
parallel --will-cite --jobs 3 ./preprocess_fmri.sh ::: CrunchPilot01_development1 #subject2 subject3
echo "parallel preprocessing done"

echo "THE WHOLE THING (COMPILATION) TOOK $SECONDS seconds TO FINISH"