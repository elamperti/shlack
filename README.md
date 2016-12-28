# Shlack

This simple script aims to ease the sending of [Slack](https://slack.com/) messages from CLI, and specially from (scripted) automated processes.

## Screenshot
![Slack message sent with custom bot name and emoji icon](https://cloud.githubusercontent.com/assets/910672/21515488/0116c8ac-ccaf-11e6-8a66-93e4e9cdd01c.jpg)

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
Just source `shlack.sh` so the `post_to_slack` function is available, then call that function to post to Slack.

### Syntax

```
post_to_slack "Message to send" ["Bot name" ["emoji to customize icon" ["channel or username"]]]
```

  * The only thing you _really_ need in order to post is a **message**.
  * **Bot name** will default to "Bot"
  * **Icon** will default to `robot_face`. The emoji name should be written without `:`.
  * **Channel/Username** will default to the one set for the given hook configuration.

The syntax will evolve to named arguments (soon™).

### Example

```
post_to_slack "This is a Shlack test!" "Adalmiro Jacinto" "fishing_pole_and_fish" "#general"
```

## License
Copyright (C) 2016  Enrico Lamperti
GNU GPL v2, see [LICENSE](./LICENSE) file for more information.
