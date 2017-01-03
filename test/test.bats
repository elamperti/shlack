#!/usr/bin/env bats

##
## Helper functions
##

function get_payload_item() {
  echo "$2" | grep -Ev '^Slack hook URL' | sed "s/.*\"$1\": \"//;s/\",.*//;s/\"\}//"
}


##
## Basic tests
##

@test "exit correctly after sending a message" {
  run ./shlack.sh --debug --text="test" --hook="http://hooks.slack.com/services/almost/legit/hook"
  [ "$status" -eq 0 ]
}

@test "fail without a hook URL" {
  run ./shlack.sh --debug --hook="" --text="test"
  [ "$status" -eq 1 ]
}

@test "fail without a defined message" {
  run ./shlack.sh --debug --hook="foo"
  [ "$status" -eq 1 ]
}

##
## Emoji tests
##

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

