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
  local slack_hook_url=""
  if [ -n "${SLACK_URL}" ]; then
    slack_hook_url="${SLACK_URL}"
  else
    if [ -f ".slack-hook" ]; then
      slack_hook_url=$(cat .slack-hook)
    else
      echo "Slack hook is undefined."
      exit 1
    fi
  fi

  local slack_message="$1"
  local slack_bot_name="$2"
    [ -z "${slack_bot_name}" ] && slack_bot_name="Bot"
  local slack_icon="$3"
    [ -z "${slack_icon}" ] && slack_icon="robot_face"
  slack_icon=":${slack_icon}:"
  local extra_payload=""

  if [ -n "$4" ]; then
    extra_payload="\"channel\": \"$4\","
  fi

  read -r -d '' slack_payload <<- EOM
    {
      ${extra_payload}
      "text": "${slack_message}",
      "username": "${slack_bot_name}",
      "icon_emoji": "${slack_icon}"
    }
EOM
  # Ugly formatting
  slack_payload=${slack_payload//$'\n'/}
  slack_payload=${slack_payload//  /}

  curl -X POST --data "payload=${slack_payload}" ${slack_hook_url}
}

