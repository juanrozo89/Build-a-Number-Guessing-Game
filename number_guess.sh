#!/bin/bash
# Randomn Number Guessing Game
# 2022 Juan Rozo

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c" # psql for querying database

# Initialize variables for updating user data
BEST_GAME=999
GAMES_PLAYED=0
COUNTER=1 # counts number of guesses

RANDOM_SECRET_NUM=$(shuf -i 1-1000 -n 1) # generate random secret number between 1 and 1000

echo "Enter your username:"
read USERNAME
OLD_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'") # query if user exists
if [[ -z $OLD_USER ]] # for new user
then
  # create new user in database
  CREATE_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else # for old user
  # update user info
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo Welcome back, $OLD_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

echo "Guess the secret number between 1 and 1000:"
read NUM_GUESSED
# while number isn't guessed, ask for new guesses:
while [[ $NUM_GUESSED != $RANDOM_SECRET_NUM ]]
do
  if [[ ! $NUM_GUESSED =~ ^[0-9]+$ ]] # input isn't an integer
  then
    echo "That is not an integer, guess again:"
  else # input is an integer
    ((COUNTER++)) 
    if [[ $NUM_GUESSED > $RANDOM_SECRET_NUM ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  read NUM_GUESSED
done

# when number is guessed, update user info:
if [[ $COUNTER < $BEST_GAME ]]
then
  BEST_GAME=$COUNTER
fi
((GAMES_PLAYED++))
UPDATE_DATA=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME';")

# conclude game
echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_SECRET_NUM. Nice job!"
