# Shlack

This simple script aims to ease the sending of [Slack](https://slack.com/) messages from CLI, and specially from (scripted) automated processes.

## Demo
![Slack message sent with custom bot name and emoji icon](https://cloud.githubusercontent.com/assets/910672/21515488/0116c8ac-ccaf-11e6-8a66-93e4e9cdd01c.jpg)
```
post_to_slack --text="This is a Shlack test!" --botname="Adalmiro Jacinto" --icon="fishing_pole_and_fish" --channel="#general"
```

## Requirements
  - A Slack team, of course
  - Bash
  - curl

## Setup
  1. Clone this repository to your computer `git clone git@github.com:elamperti/shlack.git`
  2. Go to your Slack team's _Apps & Integrations_ and add "[Incoming WebHooks](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks)".
  3. Add a configuration for _Incoming WebHooks_. It will ask you to which channel it has to post: this will be the default channel. You can override the destination channel from Shlack on each message you send.
  4. In the following page, copy the _Webhook URL_ (`https://hooks.slack.com/services/…`) and paste it into a file named `.slack-hook` in the folder from where Shlack will be called.
  5. Source `shlack.sh` and use the `post_to_slack` function as you need.

### A note on `.slack-hook`
The `.slack-hook` will be read from the current directory, which may be different from where Shlack is sourced. 
This enables you to use different URLs for different teams or situations according to the context (the directory) where it's being used.

## Usage
The script can be called directly (e.g. `$ shlack.sh --text "Hello world"`) or sourced. If you source it, the `post_to_slack` function becomes available.

### Syntax
The following options are available:
  * `--text`: **Required**. The message to post.
  * `--hook`: Slack hook URL. Overrides the `SLACK_URL` environment variable and `.slack-hook` file.
  * `--channel`: Channel or username. Defaults to the channel defined in the hook configuration.
  * `--botname`: The displayed nickname for the bot. Defaults to the name defined in the hook configuration. 
  * `--icon`: An emoji name; colons around it aren't required. Defaults to the icon defined in the hook configuration. 

## License
Copyright (C) 2016  Enrico Lamperti
GNU GPL v2, see [LICENSE](./LICENSE) file for more information.
