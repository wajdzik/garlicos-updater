Write-Output 'Hello world'
$SettingsObject = Get-Content -Path .\garlicos-psupdater.cfg | ConvertFrom-Json
$workingDir = ".\tmp\garlicOS\" 
$saveDir = ".\garlicOS\saves\"
New-Item -ItemType "directory" -Path "$workingDir" -Force
New-Item -ItemType "directory" -Path "$saveDir" -Force
# Set-Location "$workingDir"

# wget https://www.patreon.com/file?h=76561333&i=13803801
# wget https://www.patreon.com/file?h=76561333&i=13803801
# wget unzip 

Write-Output "# Updating misc"
.\adb shell mount -o rw,remount /misc
if ("true" -ne $SettingsObject.resetCfg)
{
    .\adb -s $SettingsObject.adbDeviceId shell cp -v /misc/boot_logo.bmp.gz /misc/current_boot_logo.bmp.gz
}
.\adb -s $SettingsObject.adbDeviceId push .\misc\ /misc/   
if ("true" -ne $SettingsObject.resetCfg)
{
    .\adb -s $SettingsObject.adbDeviceId shell mv /misc/current_boot_logo.bmp.gz /misc/boot_logo.bmp.gz
}

Write-Output "# Updating cfw"

if ("true" -ne $SettingsObject.resetCfg)
{
    .\adb -s "$adbDeviceId" shell cp -v /mnt/mmc/CFW/retroarch/.retroarch/retroarch.cfg /mnt/mmc/CFW/retroarch/.retroarch/current_retroarch.cfg
    write-output "part 1 done"
    .\adb -s "$adbDeviceId" shell cp -rv /mnt/mmc/CFW/retroarch/.retroarch/assets /mnt/mmc/CFW/retroarch/.retroarch/current_assets
    write-output "part 2 done"
    .\adb -s "$adbDeviceId" shell cp -rv /mnt/mmc/CFW/skin /mnt/mmc/CFW/current_skin
    write-output "part 3 done"
}
write-output "start CFW"
.\adb -s "$adbDeviceId" push --sync .\roms\CFW\ /mnt/mmc/
write-output "Done CFW"
if ("true" -ne $SettingsObject.resetCfg)
{
    .\adb -s "$adbDeviceId" shell mv /mnt/mmc/CFW/retroarch/.retroarch/current_retroarch.cfg /mnt/mmc/CFW/retroarch/.retroarch/retroarch.cfg
    .\adb -s "$adbDeviceId" shell mv /mnt/mmc/CFW/retroarch/.retroarch/current_assets/* /mnt/mmc/CFW/retroarch/.retroarch/assets
    .\adb -s "$adbDeviceId" shell mv /mnt/mmc/CFW/current_skin/* /mnt/mmc/CFW/skin
}

Write-Output "# Updating roms"
.\adb -s "$adbDeviceId" push  .\roms\Roms\* /mnt/mmc/ 
.\adb -s "$adbDeviceId" push .\roms\Roms\* /mnt/SDCARD/

Write-Output "# Saving saves"
.\adb -s "$adbDeviceId" pull --sync /mnt/SDCARD/Saves "$saveDir"
.\adb -s "$adbDeviceId" pull --sync -a /mnt/mmc/Saves "$saveDir"
Write-Output "# End"

.\adb -s "$adbDeviceId" reboot
