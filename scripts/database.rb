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

def get_users
  users = []
  $db.execute("SELECT DISTINCT userName FROM tblFullLogs") do |row|
    users << row[0]
  end
  users.sort
end

# Get a hash of user counts by date string in form "yyyymmdd".
def get_user_count_by_date
  users_by_date = Hash.new { |h, k| h[k] = [] }
  results = $db.execute(
      "SELECT strftime('%Y%m%d', timeStamp, 'unixepoch'), " +
        "lower(userName) FROM tblFullLogs " +
      "GROUP BY strftime('%Y%m%d', timeStamp, 'unixepoch'), lower(userName)")
  results.each do |i|
    users_by_date[ i[0] ] << i[1]
  end
  users_by_date
end

# Get a hash of chat line counts by date string in form "yyyymmdd".
def get_line_count_by_date
  lines_by_date = {}
  results = $db.execute(
      "SELECT strftime('%Y%m%d', timeStamp, 'unixepoch'), " +
        "COUNT(chatText) AS lines FROM tblFullLogs " +
      "GROUP BY strftime('%Y%m%d', timeStamp, 'unixepoch')")
  results.each do |i|
    lines_by_date[ i[0] ] = i[1]
  end
  lines_by_date
end

# Get a hash of all chat lines by date string in form "yyyymmdd".
def get_chat_by_date
  chat_by_date = Hash.new { |h, k| h[k] = [] }
  results = $db.execute(
      "SELECT strftime('%Y%m%d', timeStamp, 'unixepoch'), " +
        "timeStamp, userName, chatText " +
      "FROM tblFullLogs")
  results.each do |i|
    chat_by_date[ i[0] ] << [ i[1] , i[2] , i[3] ]
  end
  chat_by_date
end

################################################################################