LIST=$1
# TODO add check in case $LIST is empty string or not being passed

# save to variable list of address from specified mlmmj-list
# double trick: 
# - the stdout result from the mlmmj command is flattened from a multiline print
#   to a one line of values divided by empty space *when* saved to a variable
# - we can wrap this value directly inside an array `R=()`, and let bash array
#   to split the string by empty space

LISTADDRESS=($(sudo /usr/bin/mlmmj-list -L /var/spool/mlmmj/$LIST))
SIZE=${#LISTADDRESS[@]}

echo "member 0 => ${LISTADDRESS[0]}"
echo "member 1 => ${LISTADDRESS[1]}"
echo "etc, of total $SIZE members..."

# pick random item from list
# keep track if item has already been picked before

IDX1=$(($RANDOM % $SIZE))
IDX2=$(($RANDOM % $SIZE -1))

if [ "$IDX2" = "$IDX1" ] ; then
  IDX2=$N1+1
fi

echo "random pick => ${LISTADDRESS[$IDX2]}"
