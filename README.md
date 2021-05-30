# hd-filesha

this is an experiment in using the mailing-list format to create an *exquisite corpse*-like game.

we play with the mlmmj mailing-list software due to its simplicity and (open question) extensibility.

a series of (noob) shell scripts coupled with a cronjob, convert the typical mailing-list flow of "everyone receiving everything", with something different:

  - the first sender to the list initiate the chain
  - the message is kept on hold by the mailing list
  - a cronjob checks every x-time, picks the latest sent message and sends it to the next semi-randomly chosen subscribers in the list (the `From:` and `To:` values are replaced with <list@email.xyz> and next chosen contributor)
  - when the circle closes, the cronjb is stopped and a message to the list is sent to inform everyone the game is over


problems: 

  - replacing `From:` value in the email bothers email servers that rightly check DKIM signatures; email is delivered anyway, so its' good
  - ...

## usage

first run `./init` to create:

  - a file `.members` (tracking chosen subscribers)
  - a folder `moderation`, where incoming emails landing in `<mlmmj>/<lists>/moderation` are being moved to so to clear the queu for `mlmmj`

run parse-email with arg <full path to mlmmj list>, eg:

```
sudo ./parse-email /var/spool/mlmmj/filesha
```

ahem, running with sudo because need to interact with `mlmmj` files and using postfix's `sendmail`. maybe there's a better way, dunno — big noob here.

## setup

run `./init` before calling the main program (`parse-email`). then:

  - copy and rename `.list-sender.sample` to `.list-sender`, and set the desired email name and address
  - the `templates/` folder contains an example of mlmmj's Help template: this template is used by `get-subject-line` to update the list of "shared file-sharing methods"; all it does, is grepping through all the email received and retrieve the Subject line of each, then update the Help template accordingly; one could use this to update the Help or FAQ template

following, custom *control* settings in use for this mailing list (eg `/var/spool/mlmmj/<list>/control`, see [docs](http://mlmmj.org/docs/tunables/)):

- `customheaders`:
  - `List-Subscribe`: <mailto:listname+subscribe@lists.domain.nl>,
  - `List-Unsubscribe`: <mailto:listname+unsubscribe@lists.domain.nl>
  - these two custom headers tell email programs to display to the user a banner / UI element so that they can directly subscribe / unsubscribe from the list
- `footer`: custom footer including how to unsubcribe from the list
- `moderated`: *boolean*, eg mlmmj knows this is a moderated list
- `moderators`: email address list of moderators
- `notifymod`: *boolean*, mlmmj notifies moderators of any list activity
- `notifysub`: *boolean*, mlmmj notifes list subscribers of things (for eg when they post to the list that their message was received and waiting for approval)
- `prefix`: prefix to include at the beginning of the Subject line when someone posts to the list
- `subonlypost`: mlmmj allows only list subscribers to post to the list
