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
    else
      echo "Welcome back, $USERNAME! You have played  games, and your best game took  guesses."
    fi
    # start number guess game
  fi
fi

guess_game() {
  SECRET_NUMBER=$1
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
}
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo "SECRET_NUMBER: $SECRET_NUMBER"
guess_game $SECRET_NUMBER