#!/bin/bash
PSQL="psql --username=alextm90 --dbname=number_guess -t --no-align -c"

# create random number
RAN_NUMBER=$((1 + $RANDOM % 1000))

# get username from user
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# check database for username
if [[ -z $USER_ID ]]
then 
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
NEW_PLAYER=$USERNAME
else
# variables for old player
RETURN_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
echo -e "\nWelcome back, $RETURN_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

counter=1
# ask user for number
GUESS_NUM () {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  else
  echo -e "\nGuess the secret number between 1 and 1000:\n"
  fi
  read GUESS

# if guess not a number
  if [[ ! $GUESS =~ [0-9] ]]
  then
  GUESS_NUM "That is not an integer, guess again:"
  fi

# if guess is incorrect
  if [[ $GUESS != $RAN_NUMBER ]]
  then
    if [[ $GUESS -gt $RAN_NUMBER ]]
    then
    ((counter++))
    GUESS_NUM "It's lower than that, guess again:"
    elif [[ $GUESS -lt $RAN_NUMBER ]]
    then
    ((counter++))
    GUESS_NUM "It's higher than that, guess again:"
    fi
  fi
}
GUESS_NUM

# if guess is correct
if [[ $GUESS == $RAN_NUMBER ]]
then
echo -e "\nYou guessed it in $counter tries. The secret number was $RAN_NUMBER. Nice job!\n"
fi

# insert data
if [[ $NEW_PLAYER ]]
then
INSERT_NEW_PLAYER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$NEW_PLAYER', 1, $counter)")
else
  if [[ $counter -lt $BEST_GAME ]]
  then
  INSERT_OLD_PLAYER=$($PSQL "UPDATE users SET best_game = $counter, games_played = $GAMES_PLAYED + 1 WHERE username = '$USERNAME'")
  else
  INSERT_OLD_PLAYER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED + 1 WHERE username = '$RETURN_USER'")
  fi
fi
