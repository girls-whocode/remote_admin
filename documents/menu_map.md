# Remote Admin v(2.0)

## Main Menu
The main entry point for interacting with the system.

* ☁️ Remote Systems: Navigate to the Remote Systems Menu for host-specific tasks.
* 🏣 Local System: Navigate to the Local Systems Menu for local machine operations.
* ⚙️ Settings: Navigate to the Application Settings Menu for configuring the app.
* ❓ Help Manual: Display the Help Manual for the main menu.
* ⏹️ Exit: Exit the application.

## Remote Systems Menu
Triggered from the Main Menu to perform remote actions on servers

* 🆎 Enter a Host: Input the host you wish to work with.
* 📂 Server Databases: Navigate to the Server Database Menu to load or modify host databases.
* 🗳️ Load from SSH Config: Load host information from the SSH configuration.
* 🔙 Return to System Menu: Navigate back to the Main Menu.
* ❓ Help Manual: Display the Help Manual for the Remote Systems Menu.
* ⏹️ Exit: Exit the application.

## Local Systems Menu
Triggered from the Main Menu to perform local actions on this server

* 🏥 Run a Diagnostic: Execute diagnostics on the local machine.
* 💻 Check Resources: Overview of system resources.
* 📷 Create a Snapshot: Create a snapshot of the current system state.
* 💡 System Information: Display detailed system information.
* 🛠️ Check for Errors: Perform error checks on the local system.
* 🔄 Check for Updates: Check for available system updates.
* 🔙 Return to System Menu: Navigate back to the Main Menu.
* ❓ Help Manual: Display the Help Manual for the Local Systems Menu.
* ⏹️ Exit: Exit the application.

## Settings Menu
Triggered from the Main Menu to modify the operation of this application

* 🧠 Interactive Config: Navigate through an interactive configuration process.
* 📝 Edit Config: Manually edit the application's configuration file.
* 📝 Edit SSH Config: Manually edit the SSH configuration file.
* 🧖 Change Username: Update the username used by the application.
* 🆔 Change Identity: Update the identity file used for SSH.
* 🔙 Return to System Menu: Navigate back to the Main Menu.
* ❓ Help Manual: Display the Help Manual for the Application Settings Menu.
* ⏹️ Exit: Exit the application.

## Action Menu
Triggered after selecting a host or database in the Remote Systems Menu.

* 🐚 Shell into Systems: Open an SSH shell into the selected host(s).
* 📶 Test Connection: Test SSH connectivity to the selected host(s).
* 🔑 Copy SSH Key: Copy SSH keys to the selected host(s).
* 🔄 Refresh Subscription Manager: Refresh subscription details on the selected host(s).
* 🏥 Run a Diagnostic: Execute diagnostics on the selected host(s).
* 💻 Check Resources: Overview of host system resources.
* 📷 Create a Snapshot: Create a snapshot of the selected host(s).
* 💡 System Information: Display detailed system information for the selected host(s).
* 🛠️ Check for Errors: Perform error checks on the selected host(s).
* 🔄 Check for Updates: Check for available updates for the selected host(s).
* 🚀 Deploy Updates: Deploy updates to the selected host(s).
* 📋 Copy File: Copy a file to the selected host(s).
* 📥 Get File: Retrieve a file from the selected host(s).
* 🛡️ Vulnerability Scan: Perform a vulnerability scan on the selected host(s).
* 🔃 Reboot Host: Reboot the selected host(s).
* ⏹️ Shutdown Host: Shutdown the selected host(s).
* 🔙 Return to System Menu: Navigate back to the Remote Systems Menu.
* ❓ Help Manual: Display the Help Manual for the Action Menu.
* ⏹️ Exit: Exit the application.

## Server Database Menu
Triggered from the Remote Menu to select a list of servers for remote operations.

* 📂 Load a Database: Load a host database for actions.
* ✨ Create a Database: Create a new host database.
* ✏️ Modify a Database: Edit an existing host database.
* 🗑️ Delete a Database: Delete an existing host database.
* 🔙 Return to System Menu: Navigate back to the Remote Systems Menu.
* ❓ Help Manual: Display the Help Manual for the Server Database Menu.
* ⏹️ Exit: Exit the application.

## Database Modification Menu
Triggered from the Database Menu to make changes to a server database.

* 🆕 Add a Server
* ❌ Remove a Server
* 🛠️ Modify a Server
* ✏️ Edit a DB File
* 🔙 Return to Database Menu: Navigate back to the Database Menu.
* ❓ Help Manual
* ⏹️ Exit the application

# Remote Admin v(2.0) Flowchart

Main Menu --> Remote Systems Menu --> Action Menu
            --> Local Systems Menu
            --> Settings Menu

Remote Systems Menu --> Enter a Host --> Action Menu
                     --> Server Databases --> Load a Database --> Action Menu
                                         --> Create a Database --> Database Modification Menu
                     --> Load from SSH Config --> Action Menu
                     --> Return to System Menu --> Main Menu

Local Systems Menu --> Run a Diagnostic --> Local Systems Menu
                   --> Check Resources --> Local Systems Menu
                   --> Create a Snapshot --> Local Systems Menu
                   --> System Information --> Local Systems Menu
                   --> Check for Errors --> Local Systems Menu
                   --> Check for Updates --> Local Systems Menu
                   --> Return to System Menu --> Main Menu

Settings Menu --> Interactive Config
               --> Edit Config
               --> Edit SSH Config
               --> Change Username
               --> Change Identity
               --> Return to System Menu --> Main Menu

Server Databases --> Load a Database --> Action Menu
                --> Create a Database --> Database Modification Menu
                --> Modify a Database --> Database Modification Menu
                --> Delete a Database --> Server Databases

Database Modification Menu --> Add a Server --> Database Modification Menu
                          --> Remove a Server --> Database Modification Menu
                          --> Modify a Server --> Database Modification Menu
                          --> Edit a DB File --> Database Modification Menu
                          --> Return to Database Menu --> Server Databases
