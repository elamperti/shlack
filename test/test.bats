#!/usr/bin/env bats

# Helper functions
function query_shlack() {
  ./shlack.sh --debug "$@"
}

function get_payload_item() {
  echo "$2" | grep -oP "(?<=\"$1\": \").*?(?=\"(?:,|\}))"
}

##
## Basic tests
##

@test "exit correctly after sending a message" {
  run query_shlack --text="test" --hook="http://hooks.slack.com/services/almost/legit/hook"
  [ "$status" -eq 0 ]
}

@test "fail without a hook URL" {
  run query_shlack --hook=""
  [ "$status" -eq 1 ]
}

@test "fail without a defined message" {
  run query_shlack
  [ "$status" -eq 1 ]
}

##
## Emoji tests
##

@test "handle emoji surrounded by colons" {
  result=$(query_shlack --text="test" --icon=":banana:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":banana:" ]
}

@test "handle emoji without colons" {
  result=$(query_shlack --text="test" --icon="apple")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":apple:" ]
}

@test "handle emoji with uneven colons" {
  # Missing on left
  result=$(query_shlack --text="test" --icon="cherries:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":cherries:" ]
  
  # Missing on right
  result=$(query_shlack --text="test" --icon=":cherries")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":cherries:" ]
}

@test "support emojis with skin tone" {
  result=$(query_shlack --text="test" --icon=":wave::skin-tone-3:")
  emoji=$(get_payload_item "icon_emoji" "$result")
  [ "$emoji" = ":wave::skin-tone-3:" ]
}

