#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# make_css.rb
# Set a nice colour for each tildee. Assumes a dark background.
# You can run this as often as you like to find a nice one.
################################################################################

require_relative 'database.rb'

################################################################################

# Generate colours for each user.
css = []
get_users.each do |i|
  
  # Keep colour degree within certain better-looking bounds.
  # Bright green looks good on black, but bright blue or red do not.
  colour = 0
  loop do
    colour = rand(10..350)
    break if colour <= 220 or colour >= 260
  end
  
  css << "span.#{i}, tr.#{i} td.u { color: hsl(#{colour}, 100%, 50%); }"
  css << "tr.#{i}:hover, tr.#{i}.highlight { background-color: hsl(#{colour}, 100%, 50%);}"
  
  # Set hover text to black or white, depending on colour degree.
  if colour <= 40 or colour >= 190
    css << "tr.#{i}:hover td, tr.#{i}.highlight td { color: white; }"
  else
    css << "tr.#{i}:hover td, tr.#{i}.highlight td { color: #252525; }"
  end
end

################################################################################

# Write to the output file, using a template.
File.open('../resources/irc.css', 'w') do |fo|
  File.open(File.join(File.dirname(__FILE__), 'irc_template.css'), 'r') do |fi|
    output = fi.read
    output = output.gsub('/* USER_STYLES */', css.join("\n"))
    fo.puts output
  end
end

################################################################################
