# tilde-town-irc

by Paul Thompson - nossidge@gmail.com -
[tilde.town/~nossidge](https://tilde.town/~nossidge/)

View the IRC logs of the [tilde.town](https://tilde.town/) server offline from the
comfort of your own web browser.


## Usage

Once you've run the install and make code, open the generated file `index.html`.

Here's a screenshot of the index.
Pretty messy, but functional.
![IRC index](http://i.imgur.com/cFzOvO7.png "IRC index")

Here's a screenshot of the logs.
This is the most boring conversation I could find.
![IRC log 2015/04/02](http://i.imgur.com/hV9fFwF.png "IRC log 2015/04/02")

Each date has its own HTML log file, accessible by clicking the date on the left
column of the table.

Tables can be sorted by clicking the column header.
Rows can be highlighted by clicking on the left-most 'Time' column.
Clicking and dragging on multiple rows will highlight them all,
and subsequent sorting will not remove the highlighting.

At the top of each log, there is a list of all the usernames that chatted on
that day, sorted into 'humans' and 'robots' (e.g. 'cndorphbot', 'empirebot').
The humans are hyperlinked to their `www.tilde.town/~` pages, including swapping
out IRC names for tildee names. e.g. 'hardmath123 => kc', 'mwelsh => herschel'

URLs in chat text are properly hyperlinked too, provided they begin with 'http'
or 'www'. Super-long links are truncated so as not to break page flow.


## Dependencies

Requires Ruby, SQLite and the `sqlite3` Ruby gem.
Also requires you to be a member of tilde.town.


## Install

To get the code and run it:
```
git clone https://github.com/nossidge/tilde-town-irc.git
gem install sqlite3
```

All the code should be run from the `scripts` directory.

The file `make.sh` will run the below lines in order. You may have to run
the `scp` command ad-hoc if you have a password on your SSH key. (You may
have to rethink your approach to security if you do not have a password on
your SSH key.)

To get a copy of the lastest IRC logs (replace 'nossidge' with your name):
```
scp nossidge@tilde.town:~jumblesale/irc/log irc_log_`date +%Y%m%d`.txt
```

Use the above IRC log to create a SQLite database.
```
ruby make_database.rb irc_log_`date +%Y%m%d`.txt
```

Use the database to generate an HTML file with the logs for each date.
```
ruby make_html.rb
```

Ramdomly generate colours for each user and save to "resources/irc.css".
You can run this until you are happy with the randomly chosen colours.
```
ruby make_css.rb
```


## Are you going to put these HTML logs up on www.tilde.town somewhere?

Nope. The IRC logs are private, for members of tilde.town only.
This repository is just for converting them to an HTML form.
But if you are reading this, you should definitely think about
[joining us](http://goo.gl/forms/8IvQFTDjlo).
I'm pretty sure you'd like it. I super do.


## Thanks

- [~vilmibm](https://tilde.town/~vilmibm/) for the server.
- [~jumblesale](https://tilde.town/~jumblesale/) for the logs.
- [Stuart Langridge](http://www.kryogenix.org/code/browser/sorttable/)
for the table sorter JS.


## Licence

[GNU General Public License v3.0](http://www.gnu.org/licenses/gpl-3.0.txt)
