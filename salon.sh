#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~| Welcome to Simon's Hairsalon |~\n"

BOOKING() {
  echo -e "What service would you like to schedule?\n"

  #show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$AVAILABLE_SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done

  #choose service
  read SERVICE_ID_SELECTED
  CHOSEN_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #if input not a number, return to menu
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #if not a valid choice, return to menu 
    if [[ -z $CHOSEN_SERVICE ]]
    then
      BOOKING
    else
      #proceed with booking
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #add customer if new
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
      echo -e "\nAt what time would you like to come for your haircut?"
      read SERVICE_TIME
      #add the booking
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
      echo -e "I have put you down for a $CHOSEN_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  else
    BOOKING
  fi
}

BOOKING