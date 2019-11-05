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