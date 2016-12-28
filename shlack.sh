#!/bin/bash

# Params: message [bot_name [emoji_icon [channel]]]
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

