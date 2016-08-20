#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# tilde_users.rb
# Clean up certain users' details.
# Separate humans from robots.
################################################################################

class TildeUsers
  attr_reader :all_usernames, :humans, :robots

  @@known_bots = %w{banterbot cndorphbot cosnok demobot empirebot
                    funnybot kbot minerbot nb nodebot numberwang_bot
                    quote_bot rubot testbot tildebot topicbot umbot
                    waiterbot}
  @@ignore = %w{(.*) irssi weechat yourname}

  def initialize(all_usernames)
    @all_usernames = all_usernames.sort.uniq
    @humans = []
    @robots = []
    determine_usertypes
  end

  # Determine if human or robot, based on username.
  def determine_usertypes
    @all_usernames.each do |name|
      if @@ignore.include?(name)
      elsif @@known_bots.include?(name)
        @robots << name
      else
        @humans << name
      end
    end
  end

  # Fix for irc names not being tilde names.
  def tilde_name(name)
    case name
      when 'brightclo'   ; 'brighty'
      when 'is_the'      ; 'brighty'
      when 'DankRank'    ; 'dankrank'
      when 'endorphan'   ; 'endorphant'
      when 'epicmorph'   ; 'epicmorphism'
      when 'fivestarh'   ; 'fivestarhotel'
      when 'hardmath1'   ; 'kc'
      when 'hardmath123' ; 'kc'
      when 'jumblesal'   ; 'jumblesale'
      when 'Krowbar'     ; 'krowbar'
      when 'minerobbe'   ; 'minerobber'
      when 'mudskippe'   ; 'mudskipper'
      when 'mwelsh'      ; 'herschel'
      when 'nonononon'   ; 'nonononononono'
      when 'longshanx'   ; 'shanx'
      when 'staplebut'   ; 'staplebutter'
      when 'synergian'   ; 'synergiance'
      when 'Zeether'     ; 'zeether'
      else               ;  name
    end
  end

  # Return a string of html spans, one for each human.
  def html_spans_humans
    @humans.map do |user|
      "<span class='userlink #{user}'>" +
      "<a href='https://tilde.town/~#{tilde_name(user)}/'>#{user}</a>" +
      "</span>"
    end.join(' ')
  end

  # Return a string of html spans, one for each robot.
  def html_spans_robots
    @robots.map do |bot|
      "<span class='userlink #{bot}'>#{bot}</span>"
    end.join(' ')
  end
end

################################################################################
