#!/bin/bash

# Shlack, a Bash script to send messages to Slack
# Copyright (C) 2016  Enrico Lamperti
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

function post_to_slack () {
  # Parse arguments using getopt
  local long_options="message:,text:,channel:,botname:,icon:,hook:,debug"
  # shellcheck disable=SC2155
  local parsed_opts=$(getopt --longoptions="${long_options}" --name="Shlack" -- "$0" "$@") 
  if [[ $? -ne 0 ]]; then
    echo "Error parsing arguments"
    return 1 # error parsing
  fi
  eval set -- "${parsed_opts}"

  # Declare variables we'll need later
  local debug_mode=false
  local slack_message=""
  local slack_channel=""
  local slack_bot_name=""
  local slack_icon=""
  local slack_hook_url=""

  # Go through the parsed opts until '--' is found
  while true; do
    case "$1" in
      --text|--message)
        slack_message="$2"
        shift 2
        ;;
      --channel)
        slack_channel="$2"
        shift 2
        ;;
      --botname)
        slack_bot_name="$2"
        shift 2
        ;;
      --icon)
        slack_icon="$2"
        shift 2
        ;;
      --hook)
        slack_hook_url="$2"
        shift 2
        ;;
      --debug)
        debug_mode=true
        shift
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  # Check if there's a hook already defined
  if [ -z "${slack_hook_url}" ]; then
    # Try to use env variable SLACK_URL
    if [ -n "${SLACK_URL}" ]; then
      slack_hook_url="${SLACK_URL}"
    else
      # Last try: a .slack-hook file with the hook in it
      if [ -f ".slack-hook" ]; then
        slack_hook_url=$(cat .slack-hook)
      else
        echo "Slack hook is undefined."
        echo "Check shlack documentation at https://github.com/elamperti/shlack#setup"
        return 1
      fi
    fi
  fi

  # The message is a required parameter
  if [ -z "${slack_message}" ]; then
    # Try to read message from stdin
    local tmp_stdin=""
    while read -r line; do
      tmp_stdin="${tmp_stdin}${line}\n"
    done < /dev/stdin

    if [ -n "${tmp_stdin}" ]; then
      slack_message="${tmp_stdin}"
    else
      echo "Payload must contain a message."
      return 1
    fi
  fi

  # Normalize icon string so it has colons around it
  if [ -n "${slack_icon}" ]; then
    # shellcheck disable=SC2001
    slack_icon=":$(echo "${slack_icon}"|sed 's/^://;s/:$//'):"
  fi

  # Fill payload with data
  read -r -d '' slack_payload <<EOM
    {
      "channel": "${slack_channel}",
      "username": "${slack_bot_name}",
      "icon_emoji": "${slack_icon}",
      "text": "${slack_message}"
    }
EOM

  # Remove empty data (everything that ends up with "")
  # shellcheck disable=SC2001
  slack_payload=$(echo "${slack_payload}"|sed 's/\"[a-z_]*\":\ \"\",//gi')

  # Convert payload to one line
  slack_payload=${slack_payload//$'\n'/}
  slack_payload=${slack_payload//  /}

  # Debug mode prints payload without actually posting to slack
  if [ "${debug_mode}" = true ]; then
    echo "Slack hook URL: ${slack_hook_url}"
    echo "Payload: ${slack_payload}"
    return 0
  fi

  # Post to slack!
  curl -X POST --data "payload=${slack_payload}" "${slack_hook_url}"
}

# If the script is called directly invoke post_to_slack 
[[ "${BASH_SOURCE[0]}" != "$0" ]] || post_to_slack "$@"
