#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# make_database.rb
# Read the IRC logs to the database.
# Should be run with the IRC log file as an argument.
#   ruby make_database.rb irc_log_`date +%Y%m%d`.txt
################################################################################

require_relative 'database.rb'

################################################################################

# Read the IRC log file in.
def chat_log_to_sql_import_format(file_to_read)
  file_to_write = 'temp_sql_import.txt'
  File.open(file_to_write, 'w') do |fo|
    File.open(file_to_read, 'r').each_line do |line|
      array = line.gsub('"', '""').delete("\n").split("\t")
      if array
        if array.length >= 3
          
          # Human readable variable names.
          time_stamp = array[0]
          user = array[1].downcase
          chat_text = array[2..-1].join("\t")
          
          # Sanitise the users a wee bit.
          user = case user
            when 'jumblesal'   ; 'jumblesale'
            when 'endorphan'   ; 'endorphant'
            when 'minerobbe'   ; 'minerobber'
            when 'staplebut'   ; 'staplebutter'
            when 'brightclo'   ; 'brighty'
            when 'is_the'      ; 'brighty'
            else               ;  user
          end
          
          # Output using tab separators.
          fo.puts "#{time_stamp}\t\"#{user}\"\t\"#{chat_text}\""
        end
      end
    end
  end
  file_to_write
end

################################################################################

# Create the database using the file as stdin. This is the quickest way.
def create_database(sql_import = 'temp_sql_import.txt')
  
  # Delete any existing database.
  $db.close
  File.delete($db_file)
  
  # Write SQL and SQLite instructions to temp file.
  # Import to database.
  # Delete temp file.
  sql = %Q~CREATE TABLE IF NOT EXISTS tblFullLogs (timeStamp DATETIME, userName TEXT, chatText TEXT) ;
    .separator "\t"
    .import #{sql_import} tblFullLogs
  ~.gsub('    ','')
  File.open('temp_sql_import.sql','w') { |fo| fo.write sql }
  `sqlite3 #{$db_file} < temp_sql_import.sql`
  File.delete('temp_sql_import.sql')
  File.delete(sql_import)
end

################################################################################

# Run the methods to generate the database.
chat_log_to_sql_import_format ARGV[0]
create_database

################################################################################
