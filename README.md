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

run parse-email with arg <full path to mlmmj list>, eg:

```
sudo ./parse-email /var/spool/mlmmj/filesha
```

ahem, running with sudo because need to interact with `mlmmj` files and using postfix's `sendmail`. maybe there's a better way, dunno — big noob here.

the `init` script (called in `parse-email`), creates

  - a file `.members` (tracking chosen subscribers)
  - a folder `moderation`, where incoming emails landing in `<mlmmj>/<lists>/moderation` are being moved to so to clear the queu for `mlmmj`
