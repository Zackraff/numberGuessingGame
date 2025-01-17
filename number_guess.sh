#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~Number Guessing Games~~~~\n"

echo -e "Enter your username: "

read USERNAME

CHECK_USERNAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME';")
CHECK_PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")

if [[ -z $CHECK_USERNAME ]] 
  then
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_NEW_USERNAME=$($PSQL "INSERT INTO players (username) VALUES ('$USERNAME');")
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN players USING(player_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(inputed_number) FROM games LEFT JOIN players USING(player_id) WHERE username='$USERNAME'")

    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

GUESS_COUNT=0

echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS

until [[ $USER_GUESS == $SECRET_NUMBER ]]
do

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS

      ((GUESS_COUNT++))

    else
      if [[ $USER_GUESS < $SECRET_NUMBER ]]
        then
           echo "It's higher than that, guess again:"
           read USER_GUESS
           ((GUESS_COUNT++))
        else
          echo "It's lower than that, guess again:"
          read USER_GUESS
          ((GUESS_COUNT++))
      fi
  fi

done

((GUESS_COUNT++))

PLAYER_ID_RESULT=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(player_id, inputed_number, secret_number) VALUES ($PLAYER_ID_RESULT, $GUESS_COUNT, $SECRET_NUMBER)")

echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job\!