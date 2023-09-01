#!/usr/bin/env bash
# title					:ARROW Logging System
# description		:
# author				:Jessica Brown
# date					:2022-04-21
# version				:3.0.0
# usage					:
# notes					:
# bash_version	:5.1.16(1)-release
# ==============================================================================

# Function Name: 
#   die
#
# Description: 
#   This function logs a critical failure message and exits the script.
#
# Steps:
#   1. Checks if the logging level is set to include critical failures.
#   2. Logs the failure message along with a timestamp in the log file.
#
# Globals:
#   - log_level: The logging level which determines if critical failures are logged.
#   - ra_log_file: The path to the log file where the message is written.
#
# Parameters:
#   - Takes a message string as an argument which specifies the failure reason.
#
# Returns:
#   None. Logs the message to a file but doesn't terminate the script.
die () {
  if [ ${log_level} -ge 1 ]; then
    local _message="${*} ** Exiting **";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[CRITICAL FAIL]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   critical
#
# Description: 
#   This function logs a critical event and increments the critical event counter.
#
# Steps:
#   1. Increments the counter tracking the number of critical events.
#   2. Checks if the logging level is set to include critical events.
#   3. Logs the critical message along with a timestamp in the log file.
#
# Globals:
#   - log_level: The logging level which determines if critical events are logged.
#   - ra_log_file: The path to the log file where the message is written.
#   - critical_count: A counter for the number of critical events.
#
# Parameters:
#   - Takes a message string as an argument which specifies the critical event.
#
# Returns:
#   None. Logs the message to a file but doesn't terminate the script.
critical () {
  ((critical_count += 1))
  if [ ${log_level} -ge 1 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[CRITICAL]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   error
#
# Description: 
#   Logs an error message and increments the error count.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#   - error_count: Counter for error events.
#
# Parameters:
#   - A message string specifying the error event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
error () {
  ((error_count += 1))
  if [ ${log_level} -ge 2 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[ERROR]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   warning
#
# Description: 
#   Logs a warning message and increments the warning count.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#   - warn_count: Counter for warning events.
#
# Parameters:
#   - A message string specifying the warning event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
warning () {
  ((warn_count += 1))
  if [ ${log_level} -ge 3 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[WARNING]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   notice
#
# Description: 
#   Logs a notice message and increments the notice count.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#   - note_count: Counter for notice events.
#
# Parameters:
#   - A message string specifying the notice event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
notice () {
  ((note_count += 1))
  if [ ${log_level} -ge 4 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[NOTICE]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   info
#
# Description: 
#   Logs an informational message and increments the info count.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#   - info_count: Counter for informational events.
#
# Parameters:
#   - A message string specifying the informational event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
info () {
  ((info_count += 1))
  if [ ${log_level} -ge 5 ]; then
    local _message="${*}"
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[INFO]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   debug
#
# Description: 
#   Logs a debug message.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#
# Parameters:
#   - A message string specifying the debug event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
debug () {
  if [ ${log_level} -ge 6 ]; then
    _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[DEBUG]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   success
#
# Description: 
#   Logs a success message.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#
# Parameters:
#   - A message string specifying the success event.
#
# Returns:
#   None. Logs the message but doesn't terminate the script.
success () {
  if [ ${log_level} -ge 1 ]; then
    _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[SUCCESS]:[${_message}]" >> "${ra_log_file}"
  fi
}

# Function Name: 
#   log
#
# Description: 
#   Logs a generic message.
#
# Parameters:
#   - A message string.
#
# Returns:
#   None. Outputs the message to stdout.
log() { 
  printf '%s\n' "$*"; 
}

# Function Name: 
#   fatal
#
# Description: 
#   Logs an error message and exits the script with status code 1.
#
# Globals:
#   - log_level: Determines the logging level.
#   - ra_log_file: Specifies the path to the log file.
#
# Parameters:
#   - A message string specifying the fatal event.
#
# Returns:
#   Exits the script with status code 1.
fatal() { 
  error "$@";
  exit 1; 
}

# Function Name: 
#   logging_level
#
# Description: 
#   Sets the logging level based on the value of the "logging" variable. 
#   It exports the determined level as the global variable "log_level."
#
# Steps:
#   1. Takes the value of the "logging" variable as input.
#   2. Uses a case statement to assign the corresponding numerical value 
#      to the "log_level" variable.
#   3. Exports the "log_level" variable.
#   4. Logs a debug message stating the assigned logging level.
#   5. Logs a success message indicating that the logging system is active.
#
# Globals:
#   - logging: Specifies the name of the logging level to be set.
#   - log_level: Assigned the numerical value corresponding to the logging level.
#
# Parameters:
#   None. Uses the global "logging" variable.
#
# Returns:
#   None. Sets the global "log_level" variable and logs debug and success messages.
logging_level() {
  case "${logging}" in
    debug)
      log_level=6
      ;;
    info)
      log_level=5
      ;;
    notice)
      log_level=4
      ;;
    warning)
      log_level=3
      ;;
    error)
      log_level=2
      ;;
    critical)
      log_level=1
      ;;
    none)
      log_level=0
      ;;
  esac

  export log_level
  debug "Log level assigned to ${logging}"
  success "Logging System Active"
}