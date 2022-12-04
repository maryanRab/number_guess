#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
GLOBAL_GAMES_PLAYED=0
GLOBAL_BEST_GAME=1000
GUESS=0
ATTEMPTS=0

echo Enter your username:
read USERNAME

INFO_FROM_DB=$($PSQL "select * from games where username='$USERNAME'")
if [[ -z $INFO_FROM_DB ]]
then
  INSERTED_USERNAME=$($PSQL "insert into games(username,games_played,best_game) values('$USERNAME',0,1000)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo $INFO_FROM_DB | while IFS="|" read USERNAME_FROM_DB GAMES_PLAYED BEST_GAME
  do
    GLOBAL_BEST_GAME=$BEST_GAME
    GLOBAL_GAMES_PLAYED=$GAMES_PLAYED
    echo Welcome back, $USERNAME_FROM_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
fi

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $RANDOM_NUMBER

echo Guess the secret number between 1 and 1000:
until [[ $GUESS == $RANDOM_NUMBER ]]
do
  read GUESS  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    ((ATTEMPTS++))

    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo It\'s lower than that, guess again:
    fi

    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo It\'s higher than that, guess again:
    fi
  fi
done

echo You guessed it in $ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!

((GLOBAL_GAMES_PLAYED++))
if [[ $ATTEMPTS -lt $GLOBAL_BEST_GAME ]]
then
  GLOBAL_BEST_GAME=$ATTEMPTS
fi

RESULT=$($PSQL "UPDATE games set games_played=$GLOBAL_GAMES_PLAYED,best_game=$GLOBAL_BEST_GAME where username='$USERNAME'")
