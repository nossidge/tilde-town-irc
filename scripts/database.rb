#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# database.rb
# Read the IRC log table from the database.
################################################################################

require 'cgi'
require 'date'
require 'sqlite3'

$db_file = 'irc.db'
$db = SQLite3::Database.new($db_file)

################################################################################

# Get a list of all users in the database.
def get_users
  $db.execute('SELECT DISTINCT user_name FROM irc').map(&:first).sort
end

# Get a list of all dates in the database.
def get_dates
  $db.execute( %[
    SELECT DISTINCT
      strftime('%Y%m%d', datetime_unix, 'unixepoch')
    FROM irc
  ] ).map(&:first)
end

# Get a hash of user counts by date string in form "yyyymmdd".
def get_user_count_by_date
  users_by_date = Hash.new { |h, k| h[k] = [] }
  $db.execute( %[
    SELECT strftime('%Y%m%d', datetime_unix, 'unixepoch'), lower(user_name)
    FROM irc
    GROUP BY strftime('%Y%m%d', datetime_unix, 'unixepoch'), lower(user_name)
  ] ).each do |i|
    users_by_date[ i[0] ] << i[1]
  end
  users_by_date
end

# Get a hash of chat line counts by date string in form "yyyymmdd".
def get_line_count_by_date
  lines_by_date = {}
  $db.execute( %[
    SELECT strftime('%Y%m%d', datetime_unix, 'unixepoch'), COUNT(chat_text)
    FROM irc
    GROUP BY strftime('%Y%m%d', datetime_unix, 'unixepoch')
  ] ).each do |i|
    lines_by_date[ i[0] ] = i[1]
  end
  lines_by_date
end

# Get a hash of all chat lines by date string in form "yyyymmdd".
def get_chat_by_date
  chat_by_date = Hash.new { |h, k| h[k] = [] }
  $db.execute( %[
    SELECT strftime('%Y%m%d', datetime_unix, 'unixepoch'),
           datetime_unix, user_name, chat_text
    FROM irc
  ] ).each do |i|
    chat_by_date[ i[0] ] << [ i[1] , i[2] , i[3] ]
  end
  chat_by_date
end

################################################################################
