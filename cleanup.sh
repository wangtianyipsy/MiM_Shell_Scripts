cd /ufrc/davidclark/share/ClarkPilot/
chmod -R 775 sub-01
chmod -R 775 sub-03
rm -rf sub-01
rm -rf sub-03
#rm -rf Figures
#rm *.csv*
mkdir /ufrc/davidclark/share/ClarkPilot/sub-01
mkdir /ufrc/davidclark/share/ClarkPilot/sub-01/Raw
mkdir /ufrc/davidclark/share/ClarkPilot/sub-03
mkdir /ufrc/davidclark/share/ClarkPilot/sub-03/Raw

cp -r MRI_files /ufrc/davidclark/share/ClarkPilot/sub-01/Raw &
cp -r MRI_files /ufrc/davidclark/share/ClarkPilot/sub-03/Raw
chmod -R 775 sub-01 &
chmod -R 775 sub-03 
echo "cleaning up took $SECONDS SECONDS"