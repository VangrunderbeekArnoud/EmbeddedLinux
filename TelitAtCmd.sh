# !/bin/sh
## @copyright 2019 Arnoud Vangrunderbeek
## Author : Arnoud Vangrunderbeek
## Description :
## Simple script to send AT commands

PROGNAME=$(basename $0)
SLOG=logger.log
TMP="./.response"
MODEM=$1
CMD=$2

error_exit()
{

# Function for exit due to fatal program error
# Accepts 1 argument:
#    String containing the descriptive error message
# ---------------------------------------------------------

   # close fd 5 & 6
   exec 5<&-; exec 6<&-
   # delete tmp file
   rm -f $TMP
   echo "${PROGNAME}: Error: ${1:-"Unknown Error"}"
   echo "${PROGNAME}: Error: ${1:-"Unknown Error"}" >> $SLOG
   exit 1

}

get_response()
{

# ---------------------------------------------------------
# Function will send a command to the modem and store the
# result in RESPONSE.
# Accepts 1 argument:
#    String containing the command to send to the modem.
# ---------------------------------------------------------

   local ECHO        # create local variable inside function
   cat <&5 >$TMP &   # cat will read the response, then die on timeout
   echo "$1" >&5     # output the command to fd 5
   wait $!           # wait for cat background process to die ($! = PID of most recent backgroun
   exec 6<$TMP       # open fd 6 to read from TMP
   read ECHO <&6     # read fd 6
                     # if the first response not equal to cmd, bad response
   if [ "$ECHO" != "$1" ]
   then              #
      exec 6<&-      # close fd 6
      return 1       # return error
   fi                #
                     # actual response for AT commands is the 3th line
   read ECHO <&6     # read next line
   read RESPONSE <&6 # read actual response
   exec 6<&-         # close fd 6
   return 0          #

}

[[ $# -ne 2 ]] && error_exit "Usage: TelitAtCmd device command"
[[ -z $1 ]] && error_exit "Usage: TelitAtCmd device command"
[ ! -e $MODEM ] && error_exit "The device '$MODEM' does not exist!"

# create empty tmp file
: > $TMP || error_exit "Unable to create '${TMP}' file"

# set modem with timeout of 5/10 a second
stty -F "$MODEM" 9600 -echo igncr -icanon onlcr ixon min 0 time 5

# open modem on FD 5 rw
exec 5<>"$MODEM"

# send cmd to modem and read response
get_response "AT+CSQ" || error_exit "Bad response from telit modem"

# delete tmp file
rm -f $TMP || error_exit "Unable to remove '${TMP}'"

# close fd 5
exec 5<&-

# output the response
echo $RESPONSE
