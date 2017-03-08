#!/usr/bin/env bats

##
## Helper functions
##

function get_payload_item() {
  echo -n "$2" | grep -Ev '^Slack hook URL' | grep -i "$1" | sed "s/.*\"$1\": \"//;s/\",.*//;s/\"\}//"
}


##
## Basic tests
##

@test "pass ShellCheck with no warnings" {
  if ! command -v 'shellcheck'; then
    skip "ShellCheck not found"
  fi

  run shellcheck shlack.sh
  [ "$status" -eq 0 ]
}

@test "exit correctly after sending a message" {
  run ./shlack.sh --debug --text="test" --hook="http://hooks.slack.com/services/almost/legit/hook"
  [ "$status" -eq 0 ]
}

@test "fail without a hook URL" {
  if [ -f ".slack-hook" ]; then
    skip ".slack-hook present"
  fi

  run ./shlack.sh --debug --hook="" --text="test"
  [ "$status" -eq 1 ]
}

@test "fail without a defined message" {
  run ./shlack.sh --debug --hook="foo"
  [ "$status" -eq 1 ]
}

@test "accept text from stdin" {
  result=$(echo -n "test" | ./shlack.sh --debug --hook="foo")
  message=$(get_payload_item "text" "$result")
  [ "$message" = "test" ]
}

@test "respond to post_to_slack calls after being sourced" {
  result=$(source shlack.sh; post_to_slack --debug --text="test" --hook="foo")
  message=$(get_payload_item "text" "$result")
  [ "$message" = "test" ]
}

@test "leave mrkdwn option undefined by default" {
  result=$(./shlack.sh --debug --hook="foo" --text="test")
  md_option=$(get_payload_item "mrkdwn" "$result")
  [ -z "$md_option" ]
}

@test "add option to disable markdown" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --no-markdown)
  md_option=$(get_payload_item "mrkdwn" "$result")
  [ "$md_option" = "false" ]
}

##
## Icon and emoji tests
##

@test "discard icon_url if emoji icon defined" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon_url="http://example.com/image.png" --icon=":confused:")
  icon_url=$(get_payload_item "icon_url" "$result")
  [ -z "$icon_url" ] 
}

@test "use icon_url if no emoji specified" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon_url="http://example.com/image.png")
  icon_url=$(get_payload_item "icon_url" "$result")
  [ "$icon_url" = "http://example.com/image.png" ]
}

@test "handle emoji surrounded by colons" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon=":banana:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":banana:" ]
}

@test "handle emoji without colons" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon="apple")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":apple:" ]
}

@test "handle emoji with uneven colons" {
  # Missing on left
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon="cherries:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":cherries:" ]
  
  # Missing on right
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon=":cherries")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":cherries:" ]
}

@test "support emojis with skin tone" {
  result=$(./shlack.sh --debug --hook="foo" --text="test" --icon=":wave::skin-tone-3:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":wave::skin-tone-3:" ]
}

