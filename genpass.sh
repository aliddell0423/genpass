#!/bin/sh

# set the args for dmenu
dmargs="-i -c -bw 4 -l 20 -g 2"

# create the account usernames folder if not already created
if [ ! -f .account_usernames ]; then touch $HOME/.account_usernames
fi

# prompt user to change a password or create a new one
change_pass=$(echo -e "Yes\nNo" | dmenu -p "Would you like to change an existing password?")

# List out the services you already have whether you answered yes or no. Or type in a new service.
if [ $change_pass == "Yes" ]; then
    service=$(ls $HOME/.password-store/ | dmenu -p "Type the service you wish to use" $dmargs )
else
    service=$(dmenu -p "Type the service you wish to use" $dmargs <&- )
fi

# use any username you have cached in the file
username=$(dmenu -p "Type the username for your service" $dmargs < $HOME/.account_usernames )

# if the username is a new addition, add it to the file
if ! grep "$username" $HOME/.account_usernames; then
       echo "$username" >> $HOME/.account_usernames
fi

# Generate the password, insert it to the database, then put it in your clipboard,
# delete it after 10 seconds. Pretty simple.
password=$(pwgen -y | head)
echo "$password" | pass insert -ef $service/$username;
echo $password | xclip -sel clip
pass git push
notify-send "Copied password to clipboard. Deleting in 10 seconds."
sleep 10
echo "" | xclip -sel clip
notify-send "Clipboard cleared."
