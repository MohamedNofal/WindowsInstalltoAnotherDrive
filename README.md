# Windows install to another drive

This script automates the process of installing Windows from an ISO file directly to an NVMe drive without the need for a USB drive. It's designed for advanced users and system administrators who need to deploy Windows quickly and efficiently on systems with NVMe storage.

## Features

- Mounts Windows ISO files automatically
- Prepares NVMe drives for Windows installation
- Applies Windows image to the NVMe drive
- Configures UEFI boot environment
- Supports various Windows editions and versions

## Prerequisites

- Windows PE or Windows Recovery Environment
- Administrative privileges
- A Windows ISO file
- An NVMe drive (target for installation)

## Usage

1. Boot into Windows PE or Windows Recovery Environment.
2. Download or copy the script to your environment.
3. Run the script as administrator:InstallWindowsNVMe.bat


4. Follow the on-screen prompts to select the ISO file and target NVMe drive.

## Warning

This script will erase all data on the selected NVMe drive. Make sure to back up any important data before proceeding.

## Script Steps

1. Check for administrative privileges
2. Prompt for Windows ISO file path
3. Mount the ISO file
4. List available disks and prompt for NVMe disk selection
5. Prepare the NVMe drive using DiskPart
6. Apply the Windows image using DISM
7. Configure the UEFI boot environment
8. Unmount the ISO file

## Troubleshooting

If you encounter the error "install.wim or install.esd not found in the ISO", ensure that:
- The ISO file is not corrupted
- The ISO contains a valid Windows image
- The script has correctly detected the mounted ISO drive letter

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](https://github.com/yourusername/windows-nvme-install/issues) if you want to contribute.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Disclaimer

Use this script at your own risk. The authors are not responsible for any data loss or system damage that may occur from using this script.
