#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# read the username
echo "Enter your username:"
read USERNAME

# remove the space from user input
USERNAME="${USERNAME#"${USERNAME%%[![:space:]]*}"}"
USERNAME="${USERNAME%"${USERNAME##*[![:space:]]}"}"

# limit the username less than 22 characters
if [[ ${#USERNAME} -gt 22 ]]
then
  # reread the username
  echo "The username cannot exceed 22 characters; please enter it again:"
  read USERNAME
else
  # username can not be empty
  if [[ -z $USERNAME ]]
  then
    # reread the username
    echo "The username cannot be empty; please enter it again:"
    read USERNAME
  # username is no problem
  else
    # check the username in database
    GET_USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

    # if can not get the username from database
    if [[ -z $GET_USERNAME_RESULT ]]
    then
      # insert the new username
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      #echo "insert into database: $INSERT_USER_RESULT"
      USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'");
      INSERT_RECORD_RESULT=$($PSQL "INSERT INTO records(user_id, score, times) VALUES($USERID, 0, 0)")
      SCORE=0;
      TIMES=0;
    else
      USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'");
      RECORD_RESULT=$($PSQL "SELECT score, times FROM records WHERE user_id='$USERID'");
      #echo "$RECORD_RESULT" | IFS='|' read SCORE TIMES
      IFS='|' read SCORE TIMES <<< "$RECORD_RESULT"
      echo "RECORD RESULT: $RECORD_RESULT"
      echo "USERID: $USERID; SCORE: $SCORE; TIMES: $TIMES"
      echo "Welcome back, $USERNAME! You have played $TIMES games, and your best game took $SCORE guesses."
    fi
  fi
fi


# generate random number
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo "SECRET_NUMBER: $SECRET_NUMBER"

TRIES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS
  ((TRIES++))
   # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  # Check if guess is correct
  elif [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    if [[ "$SCORE" -gt "$TRIES" || "$SCORE" -eq 0 ]]
    then
      SCORE=$TRIES
    fi
    TIMES=$((TIMES + 1))
    UPDATE_RECORDS_RESULT=$($PSQL "UPDATE records SET score=$SCORE, times=$TIMES WHERE user_id=$USERID");
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  # Check if guess is higher
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  # Check if guess is lower
  else
    echo "It's higher than that, guess again:"
  fi
done