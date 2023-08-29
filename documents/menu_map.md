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

```mermaid
graph LR
    A[Main Menu]
    B[Remote Systems Menu]
    C[Local Systems Menu]
    D[Settings Menu]
    E[Action Menu]
    F[Server Database Menu]
    G[Database Modification Menu]

    A -->|Select "Remote Systems"| B
    A -->|Select "Local System"| C
    A -->|Select "Settings"| D
    B -->|Enter a Host| E
    B -->|Server Databases| F
    B -->|Load from SSH Config| E
    B -->|Return to System Menu| A
    C -->|Run a Diagnostic| C
    C -->|Check Resources| C
    C -->|Create a Snapshot| C
    C -->|System Information| C
    C -->|Check for Errors| C
    C -->|Check for Updates| C
    C -->|Return to System Menu| A
    D -->|Interactive Config| D
    D -->|Edit Config| D
    D -->|Edit SSH Config| D
    D -->|Change Username| D
    D -->|Change Identity| D
    D -->|Return to System Menu| A
    E -->|Select Action| E
    F -->|Load a Database| E
    F -->|Create a Database| E
    F -->|Modify a Database| G
    F -->|Delete a Database| E
    G -->|Add a Server| G
    G -->|Remove a Server| G
    G -->|Modify a Server| G
    G -->|Edit a DB File| G
    G -->|Return to Database Menu| F
