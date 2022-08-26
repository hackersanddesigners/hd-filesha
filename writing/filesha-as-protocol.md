---
title: fileSHA as protocol
---

## Why fileSHA

```
#!/bin/bash

# init: remove existing data and initialize new game-session

# create file to keep track of chosen members
if [ ! -e ./.members ]; then
  touch ./.members
else 
  rm ./.members && touch ./.members
fi

# create moderation folder where to move emails
# from `<mlmmj>/<list>/moderation`
if [ ! -d ./moderation ]; then
  mkdir ./moderation
else 
  rm -rf ./moderation && mkdir ./moderation
fi

# delete .game-over mark
rm -rf ./.game-over
```

caption: `init`. instructions to kick-off the game.

*fileSHA* was one of the H&D meetups organized during 2021 as part of the activities program of the year. It consisted of an email, turn-based game using a mailing-list software: think of a chat program happening over emails. You send a message to the list's email address and that message is sent to everyone else in the list. We carried out the game by using file-sharing as the activity, in which a random participant would receive a prompt email to share a file in whatever way they'd prefer, and the next random participant would need to get that file (sometimes by coordinating with the previous user) and then decide how to use that input source with their own chosen file. Each time, no one else in the list would know what was going on except the two randomly chosen participants.

The project was born out of our shared curiosity and fascination with mailing-lists and their role in bringing communities together. An all-too-common frustration we've been having in the last 5-10 years when engaging with or contributing to a certain online community — be it a group of people gathered around a shared love for a music genre, a team collaborating on the development of a coding framework or a discussion board around space exploration — is the sudden and abrupt disappearance of the space hosting that community; that place does not exist anymore because the software "is gone" (the website is down, or it's being sold and the rules of the game have changed). This prompted the question: *what else is possible and available and that we might have forgotten?*

To be clear, this is not an exercise in software nostalgia.

Another reason stems from André’s endless fascination for a piece of software called `git`. This is what propelled the Linux project to be a viable, internet based, multiplayer effort. `git` uses emails as the main format to collaborate on a project, which means: mailing-lists.

What can a mailing-list afford? Looking up on the www for examples of old mailing-lists, we found for instance [The cryptography archives](https://www.metzdowd.com/pipermail/cryptography/). The list goes back to 1970 (probably a Linux bug), and then up to the beginning of the 2000s. Would this have been possible with something like the now (2022) well known Discord software, an expressly "community" oriented web service? Does this have to do with Discord per se, or with the composition and evolution of the HTTP [^http] protocol?

[^http]: the HyperText Transfer Protocol. What's used to build websites and have them accessible online over the internet.

These points given, we dreamt of working with the email protocol and mailing-list, instead of the web. What's the UI offered by a mailing-list? How easy is it to join one? Which types of interactions can be designed in this space and what "social etiquette" can be established, or stretched, or ignored?

We decided to pick file sharing as the activity to carry out in the email-based game as it connects hand-in-hand with another interest of ours: peer2peer [^p2p] computing. Most p2p file-sharing software demands both users to be online at their computer at the same time, which introduces a nice requirement in the context of a non real-time technique like emails: human coordination. Another reason to go with file-sharing is that it points to the access and archivability option of actually exchanging files instead of using cloud-based or streaming software, where instead files are accessed and "live" only online. As much as emails are easily copyable, shareable and archivable, file-sharing provides similar capabilities.

[^p2p]: Expressly: when two computers directly communicate with each other over the network without a third, usually “bigger” computer acting as intermediary. Classic example s file torrenting, but also LAN parties and self-hosted email server are (or used to be) common examples.

## Game as protocol

Following is described the game in a protocollary format. While it's been originally performed using emails, we will try to distill and extract most of its components in a such a way that it can be repeated with a different setup. Eg, the technical constraints can be replaced and chosen at will.

Here the original code repository with instructions: <https://github.com/hackersanddesigners/hd-filesha>.

This is a chain-based game, so the more people who join it, the better. While 3 people would be the minimum, probably 5-6 is a preferred size.

fileSHA is an *exquisite-corpse* game, to which we added two more elements:

- semi-randomness [^semi-randomness] of the next player being chosen by the game
- "secrecy" between the two players exchanging the snowballing outcome

```
#!/bin/bash

LIST=$1

# TODO add check in case $LIST is empty string or not being passed

# save to variable list of address from specified mlmmj-list
# double trick: 
# - the stdout result from the mlmmj command is flattened from a multiline print
#   to a one line of values divided by empty space *when* saved to a variable
# - we can wrap this value directly inside an array `R=()`, and let bash array
#   to split the string by empty space

ORIGINLIST=($(sudo /usr/bin/mlmmj-list -L /var/spool/mlmmj/$LIST))

# loop over full member-list and create a new array with members
# not found in ./members; those have been randomly chosen already
# fairly dumb approach but works fine

CHOSEN=$(<./.members)

LISTADDRESS=()
for member in "${ORIGINLIST[@]}"; do
  
  # check if current member is NOT present in $CHOSEN (use `!`)
  # see <https://stackoverflow.com/a/231298>
  if [[ ! $CHOSEN =~ $member ]]; then
    LISTADDRESS+=($member)
  fi
   
done

# pick a random member from the list
# and append it do .members
# -gt => greater than; see <https://askubuntu.com/a/1042664>
SIZE=${#LISTADDRESS[@]}

if [ $SIZE -gt 0 ]; then
  IDX=$((RANDOM % $SIZE))

  echo ${LISTADDRESS[$IDX]} >> ./.members
  echo ${LISTADDRESS[$IDX]}
else
  echo "$SIZE"
fi
```

caption: `pick-random-address`. instructions to pick the next random player from the subscription list.

[^semi-randomness]: By this we mean that the game would pick someone from the list of participants who was not being already chosen. Plus, in a computer system, there seems to be only semi-randomness as an option anyway.

We also specifically tried to come up with an activity to perform during the game that would introduce extra degrees of "complexity". For instance, the game ticks at every 72 hours, when a new player is semi-randomly selected from the list. As well as by sometimes choosing, while playing the game, file-sharing techniques that require real-time coordination between participants (eg being online at the computer at the same time or through a certain period of time).

The two technologies that we chose are partly or completely asynchronous (file-sharing and emails), which helps to create friction within a linear-time framework.

This is the list of rules:

- setup a way for people interested in the game to join

In our case the list remained open also while the game was being played, meaning that effectively someone could join during the game, both extending the game duration as well as being semi-randomly chosen by the game to be the next participant

- setup a system to randomly pick the next player

We did it via computer software using a semi-random function. Further rules can be added to it, for instance whether a participant join early or later on in the process.

- setup a game clock and a time interval for it

We opted for 72 hours in a software asynchronous setting, and it turned out to be too little time to perform the player's tasks: receive the file; add, remove and / or extend it; pick a file-sharing method; share it to the next player.

- pick a way for the two selected players to exchange information privately

We broke the main benefit of using mailing-list software, which is to send to everyone in the list the same message posted to it. We also exploited email software by re-writing the email address of the new sender before manually sending the email posted to the list to the next randomly chosen player, therefore breaking temporal continuity.

- choose an exchange activity to do during the game

We went with file-sharing for reasons explained above. The fact that it could be interpreted quite widely, added more unforeseen elements to the gameplay which we though could improve the overall strict linear-time experience.

- kick-off the game as the host

Start the chain of "exchange-activity" transformation by setting an interesting example. Eg, if file-sharing, pick a file and way of sharing that can stir fun engagement.

- keep participants up to date

If the clock interval is large, eg at least bigger than a few hours of total gameplay, it might be a good idea to keep everyone posted about what's going on, while they are not actively playing. Of course if this happens in the same room, then it's probably not necessary.

- provide ways to ask for “help“ or access the rules of the game at any time

One side effect of using a mailing-list software was to be able to use the standard feature of asking for “help / info“ about the list: eg, how to unsubscribe, how to access previous messages, etc. We used that info text to provide the basic rules of the game instead, as well as which files have been shared so far. Though not like the help screen of a videogame, we were pointing to the same direction.

```
#!/bin/bash

LIST_PATH=$1
LIST_NAME=$(basename $LIST_PATH)

LIST_SENDER=$(<./.list-sender)
LIST_PREFIX=$(<$LIST_PATH/control/prefix)

# read moderator email list from file and break multiline text into one line
# (this is how `mailx` receives multiple recipients
MODERATORS=$(tr '\n' ' ' < "$LIST_PATH/control/owner")

GAME_OVER="game over! all subscribers have been chosen as list contributors!"
ERROR_CHAIN="An error happened; the chain order broke probably due to a mismatch in the .member list; please check!"
ERROR_NOPOST="No email has been received yet, run parse-email after a message has been posted to the list"

# check if there's any email held in /moderation
# we could check if $EMAIL_FN is an empty string,
# but it seems like eagerly asking for more troubles
MOD_N=$(ls "$LIST_PATH/moderation" | wc -l)

if [ "$MOD_N" == "0" ]; then

    echo "no email held in moderation, checking subscribers list..."
    CHOSEN_SIZE=$(./check-member $LIST_NAME) 

    if [ "$CHOSEN_SIZE" == "0" ]; then

      # check if game-over email was sent already
      if [ -e ./.game-over ]; then

	exit 1

      else

	touch ./.game-over

	echo "$GAME_OVER"
      	echo "$GAME_OVER" | mailx -a "From: $LIST_SENDER" -s "$LIST_PREFIX Game Over" $MODERATORS

      fi

    else
      # something might have happen, eg contributor did not send email within
      # x-time, or other things...
      # move on with the next contributor, if any is left
      # check latest email received, which we moved to ./moderation/
      # send message to next chosen contributor, and pray the gods

      EMAIL_FN=$(ls -t "./moderation" | head -n1)
      if [ -z "$EMAIL_FN" ]; then

	echo "$ERROR_NOPOST"
	echo "$ERROR_NOPOST" | mailx -a "From: $LIST_SENDER" -s "$LIST_PREFIX Error: no post" $MODERATORS

	exit 1

      else 
        EMAIL_PATH="./moderation/$EMAIL_FN"

        MEMBERS_LAST=$(tail -n1 .members)
     
        # pick next contributor
        CONTRIBUTOR_NEXT=$(./pick-random-address $LIST_NAME)
        echo "Next contributor (1) => $CONTRIBUTOR_NEXT" 

        # `-o` is the OR operator
        if [ "$CHOSEN_SIZE" == "0" -o -z "$CONTRIBUTOR_NEXT" ]; then
          echo "$ERROR_CHAIN"

          # send email error
          echo "$ERROR_CHAIN" | mailx -a "From: $LIST_SENDER" -s "$LIST_PREFIX Error" $MODERATORS

        else
     
          # replace `To:` address
          sed -i "s/^To: .*$/To: $CONTRIBUTOR_NEXT/" $EMAIL_PATH

          # and send email to this address
          /usr/sbin/sendmail -t $CONTRIBUTOR_NEXT < $EMAIL_PATH

        fi
      fi
     
    fi

else
    # at least one message is present in `<mlmmj>/<list>/moderation`

    # fetch latest submitted email filename
    # <https://stackoverflow.com/a/1015687>
    EMAIL_FN=$(ls -t "$LIST_PATH/moderation" | head -n1)
    EMAIL_PATH="$LIST_PATH/moderation/$EMAIL_FN"
    
    MEMBERS_LAST=$(tail -n1 .members)
    FROM=$(sed -n 's/^From:.*<\(.*\)>$/\1/p' $EMAIL_PATH)

    SENDER=$(<"$LIST_PATH/control/listaddress")

    # check if $MEMBERS_LAST is empty string (eg no contributor has been chosen yet)
    if [ -z "$MEMBERS_LAST" ]; then

	# check if it is the first message in the chain
	# by checking list of chosen members
      	CHOSEN=$(<./.members)
      	CHOSEN_SIZE=${#CHOSEN[@]}

	echo "CHOSEN => $CHOSEN"
	echo "CHOSEN_SIZE => $CHOSEN_SIZE"

      	# check if list of chosen members equals to 1
      	if [ $CHOSEN_SIZE -eq 1 ]; then

	  # mv file out of /moderation to current dir
      	  mv $EMAIL_PATH ./moderation/.

      	  # add address from first received email to chosen list
      	  echo "$FROM" >> ./.members

	  # update list of file-sharing methods shared so far
	  ./get-subject-line $LIST_PATH

      	  # pick next contributor
      	  CONTRIBUTOR_NEXT=$(./pick-random-address $LIST_NAME)
	  echo "Next contributor (2) => $CONTRIBUTOR_NEXT" 
    
	  # replace `From:` and `To:` addresses
      	  sed -i "s/^From: .*$/From: <$SENDER>/" "./moderation/$EMAIL_FN"
      	  sed -i "s/^To: .*$/To: $CONTRIBUTOR_NEXT/" "./moderation/$EMAIL_FN"
    
      	  # and send email to this address
      	  /usr/sbin/sendmail -t $CONTRIBUTOR_NEXT < "./moderation/$EMAIL_FN"

	else
	  echo "something went particularly wrong, exit"
	  exit 1
	fi
    
    elif [ "$MEMBERS_LAST" == "$FROM" ]; then
    
      # pick next contributor
      CONTRIBUTOR_NEXT=$(./pick-random-address $LIST_NAME)

      # `-o` is the OR operator
      if [ -z "$CONTRIBUTOR_NEXT" ]; then
        echo "An error happened; the chain order broke probably due to a mismatch in the .member list; please check!"

      elif [ "$CONTRIBUTOR_NEXT" == "0" ]; then

	# check if game-over email was sent already
      	if [ -e ./.game-over ]; then

	  exit 1

      	else

	  touch ./.game-over

	  echo "$GAME_OVER"
      	  echo "$GAME_OVER" | mailx -a "From: $LIST_SENDER" -s "$LIST_PREFIX Game Over" $MODERATORS

        fi

      else
        echo "Next contributor (3) => $CONTRIBUTOR_NEXT" 
    
        # mv file out of /moderation to current dir
        mv $EMAIL_PATH ./moderation/.

	# update list of file-sharing methods shared so far
	./get-subject-line $LIST_PATH
    
	# replace `From:` and `To:` addresses
        sed -i "s/^From: .*$/From: <$SENDER>/" "./moderation/$EMAIL_FN"
        sed -i "s/^To: .*$/To: $CONTRIBUTOR_NEXT/" "./moderation/$EMAIL_FN"
    
        # and send email to this address
        /usr/sbin/sendmail -t $CONTRIBUTOR_NEXT < "./moderation/$EMAIL_FN"

     fi
    
    else
      ERROR_MISMATCH="$MEMBERS_LAST differs from $FROM. This means the user who sent the email does not match with the latest email being added to .members."
      echo "$ERROR_MISMATCH"

      echo "$ERROR_MISMATCH" | mailx -a "From: $LIST_SENDER" -s "$LIST_PREFIX Error" $MODERATORS

    fi

fi
```

caption: `parse-email`. instructions to read an incoming email held in moderation.

A closing remark on the often critiqued (or just scorned off) set of hydraulic metaphors used in computer programming by “engineers“ to talk about software that recontextualizes that domain specific language:

> Geologists have uncovered one such mechanism: rivers acting as veritable hydraulic computers (or at least, sorting machines). Rivers transport rocky materials from their point of origin (a previously created mountain subject to erosion or weathering) to the place in the ocean where these materials will accumulate. In this process, pebbles of variable size, weight and shape tend to react differently to the water transporting them.
> [...]
> Once the raw materials have been sorted out into more or less homogenous groupings deposited at the bottom of the sea (that is, once they have become sedimented), a second operation is necessary to transform these loose collections of pebbles into an entity of a higher scale: a sedimentary rock. This operation consists in cementing the sorted components together into a new entity with emergent properties of its own, that is, properties such as overall strength and permeability that cannot be ascribed to the sum of the individual pebbles.

Zero News Datapool, Manuel DeLanda, The Geology Of Morals. Source: <http://www.t0.or.at/delanda/geology.htm>

Software architectures like those of a mailing-list allow for *necroposting*: no shame in resurrecting 6 months or 10 years old conversations, because it’s at best experienced as a collective sedimentation process which belongs as much to you if you find your own entry point in these past five minutes as to those who wrote about it for months a decade earlier. Rivers as computers!
