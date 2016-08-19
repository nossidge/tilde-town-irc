#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# irc_html.rb
# Read the IRC logs from the database, into html tables by month, then day.
################################################################################

require_relative 'database.rb'
require_relative 'tilde_users.rb'

################################################################################

# Convert y/m/d to unix date.
#   puts udate('20150202')
#   puts udate(2015, 2, 2)
def udate(*args)
  if args.length == 1
    udate(args[0][0..3], args[0][4..5], args[0][6..7])
  else
    Date.new(args[0].to_i, args[1].to_i, args[2].to_i).to_time.to_i
  end
end

# Get filename from timestamp.
def irc_file_name(yyyymmdd, prefix = '')
  output_dir = prefix + yyyymmdd[0..5]
  "#{output_dir}#{File::SEPARATOR}irc_#{yyyymmdd}.html"
end

# Create month directory if not exists.
def irc_file_name_mkdir(yyyymmdd, prefix = '')
  output_dir = prefix + yyyymmdd[0..5]
  Dir.mkdir(output_dir) unless File.exists?(output_dir)
  "#{output_dir}#{File::SEPARATOR}irc_#{yyyymmdd}.html"
end

################################################################################

# Surround plaintext hyperlinks with <a> tags.
# Surrounds anything starting with http or www.
# If the url is too long, then truncate it.
# Only handles one link per string.
class String
  def anchor_links!
    def private_anchor_links(text,link_regex)
      max_url_len = 80
      replace_matched = matched = text.match(link_regex).to_s
      if matched.length >= max_url_len
        replace_matched = matched[0..max_url_len] + '...'
      end
      text.sub!(matched,"<a href='#{matched}'>#{replace_matched}</a>")
    end

    # To prevent replacing 'www.'... inside existing 'http://'...
    if self =~ /(https?:\/\/[^\s]+)/
      self.replace private_anchor_links(self,/(https?:\/\/[^\s]+)/)
    elsif self =~ /(www.[^\s]+)/
      self.replace private_anchor_links(self,/(www.[^\s]+)/)
    end
  end
end

################################################################################

# Write to the output file, using a template.
def write_log_html_file(filename, page_title, h2_title, table_head, table_body, users)
  File.open(filename, 'w') do |fo|
    File.open(File.join(File.dirname(__FILE__), 'irc_template.html'), 'r') do |fi|
      output = fi.read
      output = output.gsub('../resources/', 'resources/') if filename == '../index.html'
      output = output.gsub('<!-- @PAGE_TITLE -->', page_title)
      output = output.gsub('<!-- @H2_TITLE -->', h2_title)
      output = output.gsub('<!-- @USER_LIST -->', users)
      output = output.gsub('<!-- @TABLE_HEAD -->', table_head)
      output = output.gsub('<!-- @TABLE_ROWS -->', table_body)
      output = output.gsub('<!-- @CREATE_DATE -->', Time.now.strftime('%Y/%m/%d %H:%M:%S'))
      fo.puts output
    end
  end
end

################################################################################

# Write to the file.
$chat_by_date = get_chat_by_date
def write_chat_to_html(date_yyyymmdd)
  date = Time.at(udate(date_yyyymmdd)).to_datetime
  
  html_tr = "<tr id='ROW_ID' class='USER'>" +
            "<td class='t' onmousedown='highlightRowClick(this)' " +
                "onmouseover='highlightRow(this)'>TIME</td>" +
            "<td class='u'>USER</td>" +
            "<td class='c'>TEXT</td></tr>"

  rows = []
  users = []
  row_id = 0
  $chat_by_date[date_yyyymmdd].to_a.each do |row|
    row_id += 1
    
    # ToDo: Subtract an hour due to BST.
    time_stamp = Time.at(row[0] - 3600).to_datetime.strftime('%Y/%m/%d %H:%M:%S')
    
    # Assign human readable variable names.
    user_name = row[1].downcase
    chat_text = row[2]
    
    # Add username to the array.
    users << user_name
    
    # Fix string encoding issues.
    if ! chat_text.valid_encoding?
      chat_text = chat_text.encode('UTF-16be', :invalid=>:replace, 
          :replace=>'?').encode('UTF-8')
    end
    user_name = CGI.escapeHTML user_name
    chat_text = CGI.escapeHTML chat_text

    # Hyperlink anything starting with http or www.
    chat_text.anchor_links!

    # Add row to the array.
    out = html_tr
    out = out.sub('ROW_ID',row_id.to_s)
    out = out.sub('TIME',time_stamp)
    out = out.gsub('USER',user_name)
    out = out.sub('TEXT',chat_text)
    rows << out
  end

  # Separate humans from robots.
  tilde_users = TildeUsers.new(users)
  userlist_html = ''

  # Format human list as html spans.
  if not tilde_users.humans.empty?
    userlist_html += 'humans: ' + tilde_users.html_spans_humans
  end

  # Add a bots row, if there are any.
  if not tilde_users.robots.empty?
    userlist_html += '<br>robots: ' + tilde_users.html_spans_robots
  end

  # Create table header.
  table_h = "        <tr>" +
            "          <th class='ht'>Time</th>" +
            "          <th class='hu'>User</th>" +
            "          <th class='hc'>Chat</th>" +
            "        </tr>"

  # Write to the output file, using a template.
  write_log_html_file(
    irc_file_name_mkdir(date_yyyymmdd,'../'),
    "IRC #{date.strftime('%Y/%m/%d')}",
    "<a href='../index.html'>Tilde Town IRC</a> - #{date.strftime('%Y/%m/%d - %A')}",
    table_h,
    rows.join("\n        "),
    userlist_html
  )
end

################################################################################

# Get a list of all dates in the database.
sql_select =
  "SELECT DISTINCT strftime('%Y%m%d', timeStamp, 'unixepoch') FROM tblFullLogs"
dates_yyyymmdd = $db.execute(sql_select).map(&:first)

# For each date, make an HTML document.
dates_yyyymmdd.each do |d|
  write_chat_to_html(d)
end

# For each date, add to a row array for the index.html.
html_tr = "<tr id='ROW_ID'>" +
          "<td class='td_date'>TIME</td>" +
          "<td class='td_day'>DAY</td>" +
          "<td class='td_lines'>LINES</td>" +
          "<td class='td_users'>USERS</td>" +
          "<td class='td_usernames'>USERNAMES</td></tr>"

# Get hashes of database data.
users_by_date = get_user_count_by_date
lines_by_date = get_line_count_by_date

# Add a row for each date.
rows = []
row_id = 0
dates_yyyymmdd.each do |d|
  date = Time.at(udate(d)).to_datetime
  row_id += 1

  # Get the users and lines on that day.
  users = users_by_date[d]
  lines = lines_by_date[d]

  # Class to separate the humans from the robots.
  tilde_users = TildeUsers.new(users)

  # Add row to the array.
  out = html_tr
  out = out.sub('ROW_ID',row_id.to_s)
  out = out.sub('TIME',"<a href='#{irc_file_name(d)}'>#{date.strftime('%Y/%m/%d')}</a>")
  out = out.sub('DAY',date.strftime('%A'))
  out = out.gsub('LINES',lines.to_s)
  out = out.gsub('USERS',tilde_users.humans.size.to_s)
  out = out.gsub('USERNAMES',tilde_users.html_spans_humans)
  rows << out
end

# Create table header.
table_h = "<tr>" +
        "\n          <th class='th_date'>Date</th>" +
        "\n          <th class='th_day'>Day</th>" +
        "\n          <th class='th_lines'>Lines</th>" +
        "\n          <th class='th_users'>Users</th>" +
        "\n          <th class='th_usernames'>Usernames</th>" +
        "\n        </tr>"

write_log_html_file(
  "../index.html",
  "Tilde Town IRC",
  "Tilde Town IRC - Index",
  table_h,
  rows.join("\n        "),
  ''
)

################################################################################
