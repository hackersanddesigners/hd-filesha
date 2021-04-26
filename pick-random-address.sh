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

echo $CHOSEN

LISTADDRESS=()
for member in "${ORIGINLIST[@]}"; do
  
  # check if current member is present in $CHOSEN
  # see <https://stackoverflow.com/a/231298>
  if [[ $CHOSEN =~ $member ]]; then
    echo "skip item => $member"
  else
    LISTADDRESS+=($member)
    echo "add item => $member"
  fi
   
done

# pick a random member from the list
# and append it do .members
# -gt => greater than; see <https://askubuntu.com/a/1042664>
SIZE=${#LISTADDRESS[@]}

if [ $SIZE -gt 0 ]; then
  IDX=$((RANDOM % $SIZE))
  echo "random pick => ${LISTADDRESS[$IDX]}"
  echo ${LISTADDRESS[$IDX]} >> ./.members
else
  echo "all members have been chosen, list-size is $SIZE"
fi

