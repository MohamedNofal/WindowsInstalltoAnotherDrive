@echo off
REM InstallWindowsNVMe.bat
REM Automated script to install Windows from ISO to NVMe drive without USB

:: Check for administrative privileges
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo ************************************************************
    echo ERROR: This script must be run as an administrator!
    echo Right-click on the script and select "Run as administrator."
    echo ************************************************************
    pause
    exit /b 1
)

:: Step 1: Prompt for the path to the Windows ISO file
set "isoPath="
set /p "isoPath=Enter the full path to the Windows ISO file (e.g., D:\Win10.iso): "
if not exist "%isoPath%" (
    echo ERROR: The specified ISO file does not exist.
    pause
    exit /b 1
)

:: Mount the ISO file
echo Mounting ISO file...
PowerShell Mount-DiskImage -ImagePath "%isoPath%" >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo ERROR: Failed to mount the ISO file.
    pause
    exit /b 1
)

:: Get the drive letter of the mounted ISO
for /f "usebackq tokens=*" %%I in (`PowerShell -NoProfile -Command ^
    "Get-DiskImage -ImagePath '%isoPath%' | Get-Volume | Select -ExpandProperty DriveLetter"`) do (
    set "isoDrive=%%I:"
)

if "%isoDrive%"=="" (
    echo ERROR: Failed to obtain the drive letter of the mounted ISO.
    pause
    exit /b 1
)

echo ISO is mounted at %isoDrive%

:: Step 2: List disks and prompt for NVMe disk selection
echo Listing available disks:
diskpart /s "%~dp0ListDisks.txt"
echo.
echo WARNING: Selecting the wrong disk may result in data loss!
set /p "diskNumber=Enter the Disk Number of the NVMe drive to install Windows on: "

:: Confirm disk selection
echo You have selected Disk %diskNumber% as the target NVMe drive.
set /p "confirmDisk=Are you sure you want to proceed? This will erase all data on Disk %diskNumber% (Y/N): "
if /i not "%confirmDisk%"=="Y" (
    echo Operation cancelled by the user.
    pause
    exit /b 1
)

:: Step 3: Prepare the NVMe Drive using DiskPart script
echo Preparing the NVMe drive...
echo select disk %diskNumber% > "%~dp0DiskPartScript.txt"
echo clean >> "%~dp0DiskPartScript.txt"
echo convert gpt >> "%~dp0DiskPartScript.txt"
echo create partition efi size=100 >> "%~dp0DiskPartScript.txt"
echo format quick fs=fat32 label="System" >> "%~dp0DiskPartScript.txt"
echo assign letter=S >> "%~dp0DiskPartScript.txt"
echo create partition msr size=16 >> "%~dp0DiskPartScript.txt"
echo create partition primary >> "%~dp0DiskPartScript.txt"
echo format quick fs=ntfs label="Windows" >> "%~dp0DiskPartScript.txt"
echo assign letter=W >> "%~dp0DiskPartScript.txt"
diskpart /s "%~dp0DiskPartScript.txt"

if '%errorlevel%' NEQ '0' (
    echo ERROR: DiskPart encountered an error.
    pause
    exit /b 1
)

del "%~dp0DiskPartScript.txt"

:: Step 4: Apply the Windows Image using DISM
echo Applying Windows image to the NVMe drive...

:: Check if install.wim, install.esd, or install.swm exists
if exist "%isoDrive%\sources\install.wim" (
    set "installImage=%isoDrive%\sources\install.wim"
) else if exist "%isoDrive%\sources\install.esd" (
    set "installImage=%isoDrive%\sources\install.esd"
) else if exist "%isoDrive%\sources\install.swm" (
    set "installImage=%isoDrive%\sources\install.swm"
) else (
    echo ERROR: install.wim, install.esd, or install.swm not found in the ISO.
    pause
    exit /b 1
)

:: Prompt for Windows edition index
echo.
echo Listing available Windows editions:
dism /Get-WimInfo /WimFile:"%installImage%"
echo.
set /p "imageIndex=Enter the index number of the Windows edition to install: "

:: Apply the image
dism /Apply-Image /ImageFile:"%installImage%" /Index:%imageIndex% /ApplyDir:W:\
if '%errorlevel%' NEQ '0' (
    echo ERROR: DISM encountered an error while applying the image.
    pause
    exit /b 1
)

:: Step 5: Configure the Boot Environment
echo Configuring the boot environment...
W:\Windows\System32\bcdboot W:\Windows /s S: /f UEFI
if '%errorlevel%' NEQ '0' (
    echo ERROR: Failed to configure the boot environment.
    pause
    exit /b 1
)

:: Step 6: Unmount the ISO file
echo Unmounting the ISO file...
PowerShell Dismount-DiskImage -ImagePath "%isoPath%"

:: Step 7: Completion Message
echo.
echo ************************************************************
echo Windows installation files have been successfully deployed.
echo Please restart your computer and set the NVMe drive as the
echo first boot device in your BIOS/UEFI settings.
echo ************************************************************
pause

exit /b 0