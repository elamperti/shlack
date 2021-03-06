# Shlack [![Build Status](https://travis-ci.org/elamperti/shlack.svg?branch=master)](https://travis-ci.org/elamperti/shlack)

This simple script aims to ease the sending of [Slack](https://slack.com/) messages from CLI, and specially from (scripted) automated processes.

## Demo
<p align="center"><img src="https://cloud.githubusercontent.com/assets/910672/21553414/e9957f6e-cde6-11e6-92eb-d64f9822ef23.png" alt="Slack message sent with custom bot name and emoji icon" height="36" width="166"></p>

```shell
post_to_slack --text="This is a test!" --botname="My bot" --icon="robot_face" --channel="#general"
```

## Requirements
  - A Slack team, of course
  - Bash
  - curl

## Setup
  1. Clone this repository to your computer `git clone git@github.com:elamperti/shlack.git`
  2. Go to your Slack team's _Apps & Integrations_ and add "[Incoming WebHooks](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks)".
  3. Add a configuration for _Incoming WebHooks_. You can override some of this settings later (see [_Syntax_](#syntax)). 
  4. In the following page, copy the _Webhook URL_ (`https://hooks.slack.com/services/…`) and paste it into a file named `.slack-hook` in the folder from where Shlack will be called.
  5. See [_Usage_](#usage) section to learn how to post messages.

### A note on `.slack-hook`
The `.slack-hook` will be read from the current directory, which may be different from where Shlack is sourced. 
This enables you to use different URLs for different teams or situations according to the context (the directory) where it's being used.

## Usage
The script can be sourced or called directly (e.g. `$ shlack.sh --text "Hello world"`).
If you source it, use `post_to_slack` to post messages to Slack.

### Options
The following options are available:
  * `--text`: The message to post. If omitted will try to use stdin.
  * `--hook`: Slack hook URL. Overrides the `SLACK_URL` environment variable and `.slack-hook` file.
  * `--channel`: Channel or username. Defaults to the channel defined in the hook configuration.
  * `--botname`: The displayed nickname for the bot. Defaults to the name defined in the hook configuration. 
  * `--icon_url`: URL to an image to use as icon for the message.
  * `--icon`: Emoji to use as icon; colons around it aren't required. Overrides `icon_url`. Defaults to the icon defined in the hook configuration.
  * `--debug`: Prints hook URL and payload to stdout instead of posting to Slack.
  * `--silent`: Response won't be printed to stdout.
  * `--no-markdown`: Tells Slack the message must not be formatted as Markdown.

### Caveats
If a message wasn't defined using `--text`, Shlack will wait for input on stdin only for 2 seconds, otherwise the script would hang forever when stdin is empty.

## Testing
Tests are written in [Bats](https://github.com/sstephenson/bats), run `bats test` to execute them.

## License
Copyright (C) 2016  Enrico Lamperti
GNU GPL v2, see [LICENSE](./LICENSE) file for more information.
