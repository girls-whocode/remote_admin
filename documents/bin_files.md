# ARROW v(2.0)

## Arrow's Bin Folder Files

### ra_actions.sh

---

## `setup_action()`

**Type:** Function  

**Description:**  
The `setup_action` function initializes certain display and runtime variables, such as screen titles and counters, used for further interactions in the script. It also prepares a user interface with a header, footer, and a reset counter. If no argument is passed, the screen name defaults to **"Arrow 2.0"**; otherwise, it uses the provided argument as the screen name.

---

### **Usage:**  
```bash
setup_action [screen_name]
```

### **Parameters:**  
- **`screen_name`** (optional):  
  - The title displayed in the header section of the screen.
  - If no argument is provided, the function defaults to **"Arrow 2.0"**.
  
---

### **Global Variables Set by the Function:**  
- **`screen_name`**: Stores the name/title of the current screen.  
- **`hosts_no_connect`**: An empty array initialized to track hosts that could not connect.  
- **`counter`**: A general-purpose counter initialized to **0**.  
- **`host_counter`**: A secondary counter initialized to **1**.

---

### **Dependencies:**  
This function relies on external functions and variables for displaying headers and footers:

- **`header`**: Displays a formatted header (center-aligned in this case).  
  Usage: `header "center" "${screen_name}"`

- **`footer`**: Displays a footer with components aligned to the left or right.
  Usage:  
  ```bash
  footer "right" "${app_logo_color} v.${app_ver}" "left" "Press ESC to return to the menu"
  ```

- **Global Variables:**
  - **`app_logo_color`**: Contains the colorized logo text for the app.
  - **`app_ver`**: The version of the application.

---

### **Logic Flow:**  
1. **Determine Screen Name:**
   - If a **`screen_name`** argument is provided, it assigns it to the `screen_name` variable.
   - If no argument is passed, the screen name defaults to **"Arrow 2.0"**.

2. **Clear the Terminal:**  
   - The `clear` command is used to reset the terminal display.

3. **Render Header and Footer:**  
   - The `header` function displays the screen title at the center of the terminal.
   - The `footer` function displays the app version on the right and a prompt ("Press ESC to return to the menu") on the left.

4. **Initialize Variables:**  
   - **`hosts_no_connect`**: An empty array to store hosts that failed to connect.
   - **`counter`**: A generic counter initialized to **0**.
   - **`host_counter`**: Another counter initialized to **1**.

---

### **Example Workflow:**  
```bash
# Example 1: Default screen name
setup_action

# Output:
# Header: Arrow 2.0 (center-aligned)
# Footer: <app_logo_color> v.<app_ver> (right) | Press ESC to return to the menu (left)

# Example 2: Custom screen name
setup_action "System Monitor"

# Output:
# Header: System Monitor (center-aligned)
```

---

### **Potential Errors:**  
- **Missing Dependencies:** If the `header` or `footer` functions are not defined or improperly implemented, the function will raise an error or display an incorrect interface.
- **Global Variable Errors:** If `app_logo_color` or `app_ver` are not set, the footer may display incorrect information or raise an error.

---

### **ShellCheck Considerations:**  
This function uses global variables and external functions but does not contain dynamic or unsafe operations that require special ShellCheck directives.

---

### **Relevant Links:**  
- [Bash Arrays Documentation](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)  
- [Bash Clear Command](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-clear)

---

## `finish_action()`

**Type:** Function  

**Description:**  
The `finish_action` function summarizes the connection status of hosts, displaying how many hosts were successfully connected and how many failed. If any hosts could not connect, it prints the list of those hosts in a visually distinct format using color-coded output.

---

### **Usage:**  
```bash
finish_action
```

### **Parameters:**  
This function does not take any direct parameters but relies on the following global variables:

- **`counter`**: Tracks the number of hosts that failed to connect.
- **`host_counter`**: Counts the total number of hosts attempted for connection.
- **`hosts_no_connect`**: An array containing the names or IPs of hosts that failed to connect.
- **`light_red`**, **`light_blue`**, **`white`**, **`default`**: Color variables for styled output.

---

### **Logic Flow:**  
1. **Determine Singular or Plural Form:**  
   - If `counter` equals **1**, it sets `counted_hosts` to **"host"**.
   - Otherwise, it sets `counted_hosts` to **"hosts"** for plural form.

2. **Display Summary Message:**  
   - Prints the number of hosts connected and the number that failed, using color-coded output for clarity.

3. **Check for Failed Hosts:**  
   - If there are any hosts listed in `hosts_no_connect`, it:
     - Prints a message indicating the hosts that failed to connect.
     - Iterates through the `hosts_no_connect` array and prints each host in **light blue** color.

---

### **Example Workflow:**  
```bash
# Example 1: Single failed host
counter=1
host_counter=3
hosts_no_connect=("192.168.1.10")

finish_action

# Output:
# 3 hosts connected, 1 host could not connect
# Could not connect to:
# 192.168.1.10

# Example 2: Multiple failed hosts
counter=2
host_counter=5
hosts_no_connect=("192.168.1.10" "192.168.1.11")

finish_action

# Output:
# 5 hosts connected, 2 hosts could not connect
# Could not connect to:
# 192.168.1.10
# 192.168.1.11
```

---

### **Potential Errors:**  
- **Uninitialized Variables:**  
  If the color variables (`light_red`, `light_blue`, `white`, `default`) are not properly set, the output may contain unexpected color codes or errors.

- **Empty Array Check:**  
  The function ensures the `hosts_no_connect` array is non-empty before attempting to print its contents. If the array is missing or improperly initialized, it could cause issues.

---

### **ShellCheck Considerations:**  
- **Array Handling:** Ensure that the `hosts_no_connect` array is declared properly to avoid errors.
- **Quoting Variables:** The use of quotes around `${hosts_no_connect[@]}` is correct to handle spaces or special characters in hostnames/IPs.

---

### **Dependencies:**  
This function depends on the following global variables:
- **Color Variables:** `light_red`, `light_blue`, `white`, `default`
- **Counters:** `counter`, `host_counter`
- **Array:** `hosts_no_connect`

---

### **Relevant Links:**  
- [Bash Arrays Documentation](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)  
- [Bash printf Command](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-printf)

---

## `bye()`

**Type:** Function  

**Description:**  
The `bye` function gracefully terminates the script by logging final information about the run, unsetting variables used throughout the script, and exiting with a status code of **0** (indicating successful completion).

---

### **Usage:**  
```bash
bye
```

---

### **Logic Flow:**  
1. **Log Run Time and Status Messages:**  
   - Calls `end_time` with the starting time (`ra_start_time`) to calculate and log the total elapsed time.
   - Logs an **info** message that the application is closing, along with the formatted total runtime.
   - Logs a **notice** with a summary of critical events during the session, showing counts of various log levels.

2. **Unset Assigned Variables:**  
   - Unsets all variables used during the script by iterating through an array (`assigned_vars`) of variable names.

3. **Display Exit Message:**  
   - Prints a green-colored success message indicating the script exited successfully.

4. **Exit the Script:**  
   - Uses `exit 0` to terminate the script, indicating successful execution.

---

### **Dependencies:**  
- **`end_time "${ra_start_time}"`**: Calculates the elapsed runtime since the script started.
- **Logging Functions:**  
  - **`info`**: Logs informational messages.
  - **`debug`**: Logs debugging information (e.g., unsetting variables).
  - **`notice`**: Logs a summary of events with counts at different log levels.

---

### **Global Variables Used:**  
The function uses a wide range of global variables, all listed in the `assigned_vars` array for unsetting. Key variables include:  
- **Application & Config:** `app_name`, `app_ver`, `config_file`, `config_path`  
- **Timekeeping:** `ra_start_time`, `elapsed_time_formatted`  
- **Logging:** `critical_count`, `error_count`, `warn_count`, `note_count`, `info_count`  
- **Visuals & Colors:** `green`, `default`, along with other color-related variables like `light_red`, `light_blue`, and more.

---

### **Output Example:**  
```text
AppName closing - total run time: 2m 34s
---------] AppName closed 2024-10-26 09:45:12 3 Critical/1 Error/0 Warning/2 Notice/10 Information Events [---------
Exiting successfully!
```

---

### **Key Operations:**  
- **Unset Variables:**  
  ```bash
  for vars in "${assigned_vars[@]}"; do
      unset "${vars}"
  done
  ```
  This loop ensures that all variables declared in the `assigned_vars` array are cleaned up to prevent memory leaks or unintended usage.

- **Exit Command:**  
  ```bash
  exit 0
  ```
  The script exits with status **0**, signaling successful execution.

---

### **Potential Issues:**  
- **Unset Variables:** If a variable in the `assigned_vars` array was not previously declared, the `unset` command may return an error. However, this should not affect the function's behavior since `unset` ignores non-existent variables by default.
- **Time Calculation Dependencies:** The `end_time` function must be correctly defined and accessible to avoid errors during runtime logging.

---

### **ShellCheck Considerations:**  
- **Proper Unset Usage:** Using `unset` within a loop ensures that all specified variables are removed.  
- **Quotes for Variables:** Ensure that all variables are properly quoted to handle any spaces or special characters, especially within `for` loops and log messages.

---

### **Relevant Links:**  
- [Bash `unset` Command Documentation](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-unset)  
- [Bash `exit` Command Documentation](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html)

---

## `assign_colors()`

**Type:** Function  

**Description:**  
The `assign_colors` function configures color codes for terminal output. Depending on the value of the `cmd_color_output` variable, it assigns either ANSI color codes or default (non-colored) output. This function enables or disables colorized output based on user preferences or script settings.

---

### **Usage:**  
```bash
assign_colors
```

---

### **Logic Flow:**  
1. **Check `cmd_color_output` Setting:**  
   - If `cmd_color_output` is `"false"`, it sets `color_output` to `false`.
   - If `cmd_color_output` is `"true"`, it sets `color_output` to `true`.

2. **Assign Color Codes:**  
   - **If `color_output` is `true`:**  
     Assigns ANSI color codes to various variables for use throughout the script (e.g., `red`, `green`, `blue`).
   - **If `color_output` is `false`:**  
     Assigns neutral ANSI codes (`\033[0m`) to disable colorization.

3. **Debug Logging:**  
   - Logs whether the color codes were loaded or disabled via the `debug` function.

---

### **Dependencies:**  
- **Logging Function:**  
  - **`debug`**: Logs messages for debugging purposes (e.g., whether ANSI colors were loaded or not).

---

### **Global Variables Used:**  
- **`cmd_color_output`**: Controls whether colored output should be enabled or not.
- **`color_output`**: Stores the resulting state of the color configuration (either `true` or `false`).

---

### **Color Variables:**  
When `color_output` is enabled, these ANSI escape codes are assigned:  
- **Black:** `\033[0;30m`  
- **Red:** `\033[0;31m`  
- **Green:** `\033[0;32m`  
- **Yellow:** `\033[0;33m`  
- **Blue:** `\033[0;34m`  
- **Magenta:** `\033[0;35m`  
- **Cyan:** `\033[0;36m`  
- **Light Gray:** `\033[0;37m`  
- **Dark Gray:** `\033[1;30m`  
- **Light Red:** `\033[1;31m`  
- **Light Green:** `\033[1;32m`  
- **Light Yellow:** `\033[1;33m`  
- **Light Blue:** `\033[1;34m`  
- **Light Magenta:** `\033[1;35m`  
- **Light Cyan:** `\033[1;36m`  
- **White:** `\033[1;37m`  
- **Default:** `\033[0m` (resets to default terminal color)

If `color_output` is disabled, all the above variables are assigned `\033[0m` to neutralize any color effects.

---

### **Output Example:**  
```text
ANSI Colors loaded
```
or  
```text
ANSI Colors not loaded
```

---

### **Potential Issues:**  
- **Terminal Compatibility:** Some terminals may not fully support ANSI escape codes, which could result in unexpected display behavior.
- **Input Validation:** If `cmd_color_output` is set to anything other than `"true"` or `"false"`, the color output will remain unconfigured, which may confuse users.

---

### **ShellCheck Considerations:**  
- **Quotes for Conditionals:** Ensures that variable values (e.g., `"false"`) are enclosed in quotes to avoid unexpected behavior.  
- **Using `debug` Properly:** The debug messages are useful for tracking whether the color configuration was applied correctly.

---

### **Relevant Links:**  
- [Bash ANSI Color Codes](https://misc.flogisoft.com/bash/tip_colors_and_formatting)  
- [Bash Conditional Statements](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)

---

## `build_config()`

**Type:** Function  

**Description:**  
The `build_config` function generates a new configuration file using predefined variables. It organizes the configurations in a readable format and saves them to the specified path and filename. The function ensures that the application has a default configuration, either during the initial setup or if the configuration file needs to be regenerated.  

### **Usage:**  
```bash
build_config
```

### **Parameters:**  
This function does not take any direct parameters but relies on the following global variables:

- **`config_path`**: Directory path where the configuration file will be saved.
- **`config_file`**: Name of the configuration file (e.g., `config.cfg`).
- **`app_name`**: Name of the application (used in the configuration header).
- **`app_ver`**: Version of the application (included in the configuration header).
- **`default_editor`**: Default text editor to be specified in the configuration.
- **`color_output`**: Determines if the application output will use colors (`true` or `false`).
- **`username`**: Username of the current user.
- **`identity_file_location`**: Default path for SSH identity files.
- **`identity_file`**: Specifies an SSH identity file (can be left empty).
- **`port`**: SSH port (default is 22).
- **`logging`**: Default logging level.

### **Dependencies:**  
- **`info`**: External function used for logging informational messages.

### **Logic Flow:**  
1. The function logs an informational message indicating the creation of the configuration file.
2. It declares an array, `config_lines`, which contains:
   - A header indicating the app version and purpose of the configuration.
   - Key-value pairs representing the configuration variables and their values.
   - Comments explaining the different logging levels and their meaning.
3. It writes the configuration lines to the specified file using `printf`.

### **Output:**  
- The configuration file is saved at the path specified by the combination of **`config_path`** and **`config_file`**.

### **Configuration File Structure:**  
The generated file contains the following:

1. **Header:**
   ```
   # [app_name] v[app_ver] automated configurations
   ```

2. **Configuration Variables:**
   ```bash
   default_editor=nano
   color_output=true
   username=your_username
   identity_file_location="/home/user/.ssh"
   identity_file=""
   port=22
   ```

3. **Logging Level Descriptions:**

   ```
   # logging levels can be [critical, error, warning, notice, info, debug]
   # debug shows all messages
   # info shows all information, notices, warnings, errors, and critical
   # notice shows all notices, warnings, errors, and critical
   # warning shows all warnings, errors, and critical
   # error shows all errors and criticals
   # critical shows only critical
   # none will disable logging
   logging=info
   ```

### **Example Workflow:**  
```bash
# Example invocation
build_config

# Output in the configuration file (config.cfg):
# nano as the default editor, color output enabled, SSH identity settings, and default logging level set to 'info'
```

### **Potential Errors:**  
- **File Write Errors:** If the specified directory (`config_path`) does not exist or lacks write permissions, the function will fail to create the configuration file.
- **Missing Dependencies:** If the `info` function is not defined, the logging message will cause an error.

### **ShellCheck Directives:**  
This function doesn’t require any special ShellCheck directives as there are no dynamic sourcing operations or potentially unsafe practices.

### **Relevant Links:**  
- [Bash `declare` Command Documentation](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-declare)
- [Bash `printf` Command Documentation](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-printf)

---

## `config()`

**Type:** Function  

**Description:**  
The `config` function ensures the proper handling of a configuration file. It first checks for the existence of the specified configuration file within a given path. If found, it loads the settings by sourcing the file. If the file is missing, the function generates a new configuration file with default settings, sources it, and logs the appropriate actions.

### **Usage:**  
```bash
config
```

### **Parameters:**  
The function does not take any parameters directly but relies on global variables:

- **`config_path`**: Directory path where the configuration file is expected to reside.
- **`config_file`**: Name of the configuration file (e.g., `config.cfg`).

### **Global Variables Set by the Function:**  
If the configuration file doesn't exist, the following default variables are initialized:

- **`default_editor`**: Default text editor (`nano`).
- **`color_output`**: Boolean value (`"true"`) to enable or disable color output.
- **`username`**: Username of the current user (fetched from the environment variable `USER`).
- **`identity_file_location`**: Default path for SSH identity files (`${HOME}/.ssh`).
- **`identity_file`**: Path to a specific SSH identity file (initially empty).
- **`port`**: Default SSH port (22).
- **`logging`**: Default logging level (`"info"`).

### **Dependencies:**  
- **`logging_level`**: External function to initialize log levels.
- **`info`**: External function used for informational logging.
- **`build_config`**: External function to create a configuration file with default settings.

### **Logic Flow:**  
1. **Configuration File Exists:**  
   - If the configuration file exists in the specified path:
     - It is sourced using `source "${config_path}/${config_file}"`.
     - The `logging_level` function is called to initialize log levels.
     - A log message is generated using `info` to indicate successful loading of the configuration file.

2. **Configuration File Does Not Exist:**  
   - Default settings are assigned to several variables.
   - The `build_config` function is called to create the configuration file.
   - The newly created configuration file is sourced.
   - The `logging_level` function is called again to initialize log levels.
   - A log message is generated using `info` to indicate that the configuration file was created and loaded.

### **Example Workflow:**  
```bash
# Example invocation
config

# If config file exists:
# Logs: "Configuration file found loading /path/to/config.cfg"

# If config file does not exist:
# Logs: "Created and loaded configuration file /path/to/config.cfg"
```

### **Potential Errors:**  
- **Sourcing Issues:** If the configuration file contains syntax errors, the `source` command may fail, leading to unexpected behavior.
- **Missing Dependencies:** If the `logging_level`, `info`, or `build_config` functions are not defined, the script will encounter errors.

### **ShellCheck Directives:**  
- `# shellcheck source=/dev/null`: This directive is used to suppress warnings from ShellCheck about dynamic file paths passed to `source`.

### **Relevant Links:**  
- [Bash `source` Command Documentation](https://www.gnu.org/software/bash/manual/bash.html#index-source)
- [ShellCheck Documentation](https://www.shellcheck.net/)

---

## `do_connection_test()`

**Type:** Function  

**Description:**  
The `do_connection_test` function performs a basic connectivity check to determine if the host at the given IP address (`host_ip`) is reachable. It uses the `ping` command to send a single packet to the host. The result of this test is stored in the `connection_result` variable, and a debug message logs whether the connection test succeeded or failed.  

**⚠ Work-in-Progress Notice:**  
This function is **under development**. While `ping` provides a simple reachability test, it is not always reliable as some hosts block ICMP traffic or respond inconsistently. Future iterations will explore more robust methods such as TCP/UDP port checks, SSH connection attempts, or HTTP requests.

---

### **Usage:**  
```bash
do_connection_test
```

---

### **Logic Flow:**  
1. **Send Ping Request:**
   - Sends a single ICMP echo request to the `host_ip` using:
     ```bash
     ping -c 1 "${host_ip}"
     ```
   - Standard output and error are redirected to `/dev/null` to suppress terminal output.
   
2. **Evaluate Ping Response:**
   - If the ping succeeds, it logs the success and sets `connection_result="true"`.
   - If the ping fails, it logs the failure and sets `connection_result="false"`.

---

### **Dependencies:**  
- **`ping` command:** Used to check network reachability of the target IP.
- **Logging Function:**
  - **`debug`**: Logs messages indicating whether the connection test succeeded or failed.

---

### **Global Variables Used:**  
- **`host_ip`**: The IP address of the host being tested.
- **`connection_result`**: Stores the result of the connectivity test (`"true"` or `"false"`).

---

### **Output Example:**  
If the connection succeeds:
```text
Connection test succeeded
```

If the connection fails:
```text
Connection test failed
```

---

### **Potential Issues & Limitations:**  
1. **Blocked ICMP Traffic:** Some hosts block ICMP echo requests (ping), leading to false-negative results.
2. **Network Latency:** High latency may cause ping to timeout even if the host is reachable.
3. **Firewalls:** Firewalls may filter ICMP traffic, giving misleading results.
4. **Host Configuration:** Some hosts may be configured to deprioritize or ignore ICMP packets.

---

### **Planned Improvements:**  
Future versions of this function will incorporate more reliable connection-testing methods, such as:  
- **TCP/UDP Port Probes:** Check if specific ports (e.g., SSH on port 22) are open.
- **SSH Connectivity Tests:** Verify if SSH connections to the host are successful.
- **HTTP/HTTPS Requests:** Test web server reachability using `curl` or `wget`.
- **Parallel Testing:** Use concurrent methods to speed up the process for multiple hosts.

---

### **ShellCheck Considerations:**  
- **Suppressing Output:** Redirecting output to `/dev/null` ensures clean terminal behavior.
- **Quotes for Variables:** Ensures that variable values (e.g., `host_ip`) are safely handled.

---

### **Relevant Links:**  
- [ICMP and Ping Explained](https://en.wikipedia.org/wiki/Ping_(networking_utility))  
- [Bash TCP Connection Testing Example](https://www.cyberciti.biz/faq/how-to-use-bash-to-test-the-connection-to-a-server/)  

---
