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
* 🔙 Return to Main Menu: Navigate back to the Main Menu.
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
flowchart LR
    mm["Main Menu"] --> rm
    mm["Main Menu"] --> lm
    mm["Main Menu"] --> sm
    rm["☁️ Remote Menu"] --> rm_1
    rm["☁️ Remote Menu"] --> rm_2
    rm["☁️ Remote Menu"] --> rm_3
    lm["🏣 Local Menu"] --> lm_1
    lm["🏣 Local Menu"] --> lm_2
    lm["🏣 Local Menu"] --> lm_3
    lm["🏣 Local Menu"] --> lm_4
    lm["🏣 Local Menu"] --> lm_5
    sm["⚙️ Settings"] --> sm_1
    sm["⚙️ Settings"] --> sm_2
    sm["⚙️ Settings"] --> sm_3
    sm["⚙️ Settings"] --> sm_4
    sm["⚙️ Settings"] --> sm_5
    rm_2 --> sdm_1
    rm_2 --> sdm_2
    rm_2 --> sdm_3
    rm_2 --> sdm_4
    sdm_3 --> dmm_1
    sdm_3 --> dmm_2
    sdm_3 --> dmm_3
    sdm_3 --> dmm_4
    sdm_1 --> Actions
    rm_1 --> Actions
    rm_3 --> Actions

    subgraph Remote Menu
        rm_1("🆎 Enter a Host")
        rm_2("📂 Server Databases")
        rm_3("🗳️ Load SSH Config")
    end

    subgraph Local Menu
        lm_1("🏥 Run a Diagnostic")
        lm_2("💻 Check Resources")
        lm_3("📷 Create a Snapshot")
        lm_4("💡 System Information")
        lm_5("🛠️ Check for Errors")
        lm_6("🔄 Check for Updates")
    end

    subgraph Settings Menu
        sm_1("🧠 Interactive Config")
        sm_2("📝 Edit Config")
        sm_3("📝 Edit SSH Config")
        sm_4("🧖 Change Username")
        sm_5("🆔 Change Identity")
    end

    subgraph Server Database Menu
        direction TB
        sdm_1("📂 Load a Database")
        sdm_2("✨ Create a Database")
        sdm_3("✏️ Modify a Database")
        sdm_4("🗑️ Delete a Database")
    end

    subgraph Database Modifications
        dmm_1("🆕 Add a Server")
        dmm_2("❌ Remove a Server")
        dmm_3("🛠️ Modify a Server")
        dmm_4("✏️ Edit a DB File")
    end

    subgraph Actions
        direction TB
        am_1("🐚 Shell into Systems")
        am_2("📶 Test Connection")
        am_3("🔑 Copy SSH Key")
        am_4("🔄 Refresh Subscription Manager")
        am_5("🏥 Run a Diagnostic")
        am_6("💻 Check Resources")
        am_7("📷 Create a Snapshot")
        am_8("💡 System Information")
        am_9("🛠️ Check for Errors")
        am_10("🔄 Check for Updates")
        am_11("🚀 Deploy Updates")
        am_12("📋 Copy File")
        am_13("📥 Get File")
        am_14("🛡️ Vulnerability Scan")
        am_15("🔃 Reboot Host")
        am_16("⏹️ Shutdown Host")
    end
