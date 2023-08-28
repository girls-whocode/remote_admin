
# Remote Admin (v2.0)

## Table of Contents

- [Overview](#overview)
- [Main Menu](#main-menu)
- [Remote Systems Menu](#remote-systems-menu)
- [Local Systems Menu](#local-systems-menu)
- [Application Settings Menu](#application-settings-menu)
- [Action Menu](#action-menu)
- [Screenshots](#screenshots)
- [Support and Contributions](#support-and-contributions)

---

## Overview
[NOTE *]: It is important to know, this is in EXTREME ALPHA State, most functions are not working, or have not been developed. Because I am building this for my job, I will be updating this daily. Last update: [AUG, 28th, 2023]

Remote Admin is a comprehensive tool designed for system administrators to remotely manage servers and local systems. Utilizing a sleek, menu-driven interface, the application allows you to perform various tasks with ease.

## Prerequisites
Bash shell environment

## Usage
./ra.sh

**Features:**
- Remote and local system diagnostics
- SSH key management
- System resource monitoring
- Automated updates
- Vulnerability scans

---

## Main Menu

<img src="documents/images/main_menu.png" alt="Main Menu" width="250px" style="float: right;" />

- **Remote Systems**: Navigate to the 'Remote Systems Menu'.
- **Local System**: Navigate to the 'Local Systems Menu'.
- **Settings**: Configure application settings.
- **Help Manual**: Access the built-in help manual.
- **Exit**: Close the Remote Admin application.

---

## Remote Systems Menu

<img src="documents/images/remote_menu.png" alt="Main Menu" width="250px" style="float: right;" />

- **Enter a Host**: Input the hostname for remote administration.
- **Load Server Database**: Import a pre-existing server database.
- **Load from SSH Config**: Load hosts from your SSH configuration.
- **Create a New Database**: Create a new server database.
  
---

## Local Systems Menu

<img src="documents/images/local_menu.png" alt="Main Menu" width="250px" style="float: right;" />

- **Run a Diagnostic**: Run diagnostic tests on your local system.
- **Check Resources**: Monitor system resources.
- **Create a Snapshot**: Create a system snapshot.
- **System Information**: View detailed system information.

---

## Application Settings Menu

<img src="documents/images/settings_menu.png" alt="Main Menu" width="250px" style="float: right;" />

- **Interactive Config**: Use the interactive configuration menu.
- **Edit Config**: Manually edit the config file.
- **Edit SSH Config**: Manually edit the SSH configuration.
- **Change Username**: Update the username for SSH connections.
- **Change Identity**: Update the identity file for SSH connections.

---

## Action Menu

![Action Menu Screenshot]

- **Shell into Systems**: SSH into selected remote systems.
- **Test Connection**: Test connection to the remote host.
- **Copy SSH Key**: Send your SSH key to the remote host.
- **Refresh Subscription Manager**: Refresh the remote system's subscription manager.
- **Deploy Updates**: Push security patches to remote systems.
- **Copy File**: Copy a file to the remote host.
- **Get File**: Retrieve a file from the remote host.
- **Vulnerability Scan**: Perform a vulnerability scan on the remote host.
  
---

## Screenshots

<img src="documents/images/system_status.png" alt="Main Menu" width="250px" style="float: right;" />
<img src="documents/images/help_menu.png" alt="Main Menu" width="250px" style="float: right;" />

---

## Support and Contributions

For support, please refer to the built-in Help Manual or open an issue. Contributions are welcome; please open a pull request to contribute.

---

## License
This script is released under the MIT License.