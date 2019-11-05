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