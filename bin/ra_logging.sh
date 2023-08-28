#!/usr/bin/env bash
# title					:Remote Admin Logging System
# description			:
# author				:Jessica Brown
# date					:2022-04-21
# version				:3.0.0
# usage					:
# notes					:
# bash_version	:5.1.16(1)-release
# ==============================================================================

die () {
  if [ ${log_level} -ge 1 ]; then
    local _message="${*} ** Exiting **";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[CRITICAL FAIL]:[${_message}]" >> "${ra_log_file}"
  fi
}

critical () {
  if [ ${log_level} -ge 1 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[CRITICAL]:[${_message}]" >> "${ra_log_file}"
  fi
}

error () {
  if [ ${log_level} -ge 2 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[ERROR]:[${_message}]" >> "${ra_log_file}"
  fi
}

warning () {
  if [ ${log_level} -ge 3 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[WARNING]:[${_message}]" >> "${ra_log_file}"
  fi
}

notice () {
  if [ ${log_level} -ge 4 ]; then
    local _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[NOTICE]:[${_message}]" >> "${ra_log_file}"
  fi
}

info () {
  if [ ${log_level} -ge 5 ]; then
    local _message="${*}"
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[INFO]:[${_message}]" >> "${ra_log_file}"
  fi
}

debug () {
  if [ ${log_level} -ge 6 ]; then
    _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[DEBUG]:[${_message}]" >> "${ra_log_file}"
  fi
}

success () {
  if [ ${log_level} -ge 1 ]; then
    _message="${*}";
    echo "[$(LC_ALL=C date +"%Y-%m-%d %H:%M:%S")]:[SUCCESS]:[${_message}]" >> "${ra_log_file}"
  fi
}

log() { 
  printf '%s\n' "$*"; 
}

fatal() { 
  error "$@";
  exit 1; 
}

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
}