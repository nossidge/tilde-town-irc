#!/bin/bash

# Download the most recent IRC log file from the tilde.town server.
# Replace 'nossidge' with your tilde.town username.
# (You'll have to run this ad-hoc if you have a password on your SSH key)
scp nossidge@tilde.town:~jumblesale/irc/log irc_log_`date +%Y%m%d`.txt

# Use the above IRC log to create a SQLite database.
ruby make_database.rb irc_log_`date +%Y%m%d`.txt

# Use the database to generate an IRC HTML file for each date.
ruby make_html.rb

# Ramdomly generate colours for each user and save to "resources/irc.css"
ruby make_css.rb
