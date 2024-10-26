# ARROW v(2.0)

## Arrow's Bin Folder Files

### ra_actions.sh

This file is for the actions to be performed when a different action is selected.

#### setup_action()

Type: Function

Description: To recreate the screen, define default variables once the screen is to be recreated.

Usage: setup_action "{screen header}"

#### finish_action()

Type: Function
Description: To close the screen's actions.
Usage: finish_action

---

### ra_close.sh

A script is responsible for finalizing the script execution and cleaning up resources.

#### bye()

Type: Function
Description: This function is responsible for finalizing the script execution and cleaning up resources.
Steps:

1. Calculates and displays the total runtime of the script.
2. Logs debugging, informational, and critical events.
3. Unsets all the variables used during the script execution.
4. Exits the script successfully.

Globals:

- ra_start_time: The time the script started, used to calculate runtime.
- app_name: The name of the application or script.
- elapsed_time_formatted: Formatted string of total runtime.
- critical_count, error_count, warn_count, note_count, info_count: Counters for various types of log events.
- assigned_vars: An array of variable names that should be unset.

Returns:
  None. Exits the script with status 0.

---

### ra_colors.sh

A script to assign commonly used colors to ANSI code.

#### assign_colors()

Type: Function
Description: This function assigns color codes to variables based on the value of the 'color_output' variable. The color codes are ANSI escape sequences for terminal color formatting.

---

