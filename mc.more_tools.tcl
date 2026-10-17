##
# More Tools v3.0.2
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This is not a "cool" script, it's a tools script for other scripters to use and/
# or learn with.  If you are reading this because another script told you that you
# have to load this script so that it can work properly, then do so -- there is
# nothing to configure/ setup here.
##

##
# The history log has been moved to the very bottom of this script.
##

##
# Moretools version changes rules.
##
# Variable 'mc_moretools(numversion)' == <major><minor><bug>
#
# 1) Each subset consists of 3 integers, zerofill.
#    Example;
#      4.1.1 is wrong, should be 004001001
# 2) A complete `numversion` consists of 9 integers total.
# ----------
# Variable 'mc_moretools(version)' == v<major>.<minor>[.<bug>]
#
# 1) 'version''s regular expression:
#     v([1-9][0-9]{0,2})\.([1-9][0-9]{0,2}|0)(\.([1-9][0-9]{0,2}))?$ -> maj min - bug
# 2) If bug version is 0 (000 in `numversion`), it is dropped.
#    Examples;
#      v4.1.0 is wrong, should be v4.1 .
#      v1.2.00 is wrong, should be v1.2 .
# 3) Unlike numversion, subsets are not zerofill.
#    Example;
#      v0004.01.100 is wrong, should be v4.1.1 .
# 4) A complete `version` consists of no more than 12 characters (3 integers maximum
#    per subset) and no less than 4 characters (1 integer maximum per subset, with
#    the beta subset and it's pre pending period drop able if beta equals zero).
# ----------
# Individual command versions == v<major>.<minor>
#
# 1) <major> is increased if it breaks backwards compatibility.
# 2) <minor> increased if rule 1 doesn't apply.
# ----------
# Overall:
#
# 1) Major only changes if something in the script has changed that can break a
#    script feeding off of this.
#    Examples include;
#      - A proc is removed.
#      - Arguments of a proc are changed.
#      - Return of a proc is changed.
#      - The changing of standards such as version rules (to such a degree a script
#        could malfunction because of it).
# 2) Bug changes when something is modified that has no effect on a proc's arguments
#    nor returns.
#    Examples include;
#      - The re code of a proc to be more efficient, at the same time keeping the
#        argument and return standards formerly proposed.
#      - Documentation changes.
# 3) Every other instance is a Minor level change; things that will not break a
#    script but do not apply as a bug level change.
#    Examples include;
#      - The addition of a new proc.
##
catch {unset mc_moretools}
array set mc_moretools [list   version    v3.0.2      \
                               numversion 003000002   \
                               loaded     0           ]

# mc_moretools(loaded) is set to zero here, near top, and near the bottom it get's
# set to 1.  If your a scripture looking to base your script off the load of this
# script, you can utilize that.
# Example;
#   if {[lindex [array get mc_moretools loaded]] != "1"} {
#   	# mc.moretools isn't loaded.  Yes I did this as != "1" on purpose, it could
#     # equal 1, 0, or "".  1 being loaded, and the other two being not loaded.
#   }

##
# Tools (TCL Procedures)
##
#

# 2list <text>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Ensure <text> is in list format.  If <text> is already in list format then
#       nothing is converted.  If <text> is in string format, will convert to list
#       format.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     example:
#       2list {abc "def hi"jk} => abc {"def} hi\"jk
#       2list {abc {"def} hi\"jk} => abc {"def} hi\"jk
#     credit:
#     return:
#       - <test> in list format.
proc 2list {{args ""}} {
	badargs $args 1 1 "text"
	unlist $args text

	return [expr {([catch {llength $text}])?[split $text]:$text}]
}


# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Checks to ensure the llength of the <args> list never exceeds <max_llength>
#       nor goes below <min_llength>.
#     dependencies (other than eggdrop provided commands):
#     example:
#       badargs $args 1 2 "?arg1? arg2"
#     credit:
#       Eggdrop development team, they have a similar thing for there C code.
#     returns:
#       - 0, llength of <args> falls within <min_llength> and <max_llength>.
#       - 1, if badargs is executed at top-level stack.
#       - Otherwise, an error with the supplied <argNames> as part of its message;
#           wrong # args: should be "command_name <argNames>"
#         The command_name is automatically found and doesn't need to be supplied.
proc badargs {{args ""}} {
	if {[llength $args] < 4} {
		error {
			wrong # args: should be "badargs args min_llength max_llength argNames"
		}
	}

	set index 0
	foreach varName [list args min max names] {
		set check_$varName [lindex $args $index]
		incr index
	}

	if {[regexp -- {([^0-9])} $check_min -> bad]} {
		error "bad number \"$bad\" in: $check_min"
	}
	if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
		error "bad number \"$bad\" in: $check_max"
	}

	# Make sure $check_args is in list format, if not then make it so.
	# Were not going to use 2list here, don't want to evoke a 'too many nested calls
	# to Tcl_EvalObj' error since '2list' uses on this proc.
	if {[catch {llength $check_args} llength]} {
		set check_args [split $check_args]
		set llength $check_args
	}

	if {($llength < $check_min) || (($llength != "end") && ($llength > $check_max))} {
		if {[info level] == "1"} {return 1}
		error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
	}; return 0
}


# chanflag <channel> <flag>
#     version:
#       v3.1
#     information (mc.moretools command):
#       Check to see if <flag> is enabled or disabled for <channel>.  The 'get'
#       option for the 'channel' command, provided by eggdrop in version 1.6.11, does
#       the same as this command.  Because of that, this command will try and query
#       'channel' command first (is faster); if it receives an error then it will
#       proceed with my code.  <flag> includes custom setudef flags as well as the
#       standard ones provided by eggdrop.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       chanflag #abc123 protectops => 0
#       chanflag #abc123 mc.spamcheck => 1
#     credit:
#     returns:
#       - 0 if disabled or invalid <flag>.
#       - 1 if enabled.
proc chanflag {{args ""}} {
	badargs $args 2 2 "channel flag"
	unlist $args channel flag

	if {![validchan $channel]} {error "no such channel record"}

	# Try the 'channel' commands' 'get' option first, it's faster since it is written
	# in C by the eggdrop development team.
	if {![catch {channel get $channel $flag} output]} {return $output}

	set temp(chaninfo) [string tolower [channel info $channel]]
	if {[lsearch -exact $temp(chaninfo) +[string tolower $flag]] >= "0"} {return 1}
	return 0
}


# chanint <channel> <flag>
#     version:
#       v3.2
#     information (mc.moretools command):
#       Obtain the integer <flag> value for <channel>.  The 'get' option for the
#       'channel' command, provided by eggdrop in version 1.6.11, does the same as
#       this command.  Because of that, this command will try and query 'channel'
#       command first (is faster); if it receives an error then it will proceed with
#       my code.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The '2list' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       chanint #abc123 mc.limit_users => 0
#     credit:
#     returns:
#       - Numberical value of <integer_flag> for <channel>.
#       - -1 if invalid <integer_flag>.
proc chanint {{args ""}} {
	badargs $args 2 2 "channel integer_flag"
	unlist $args channel flag

	set flag [string tolower $flag]

	if {![validchan $channel]} {error "no such channel record"}

	# Try the 'channel' commands' 'get' option first, it's faster since it is written
	# in C by the eggdrop development team.
	if {![catch {channel get $channel $flag} output]} {return $output}

	foreach chaninfo [string tolower [channel info $channel]] {
		# Using 2list here because it's only in string format.  I told the eggdrop
		# development team of this error, but have yet to see them fix it.
		set chaninfo [2list $chaninfo]

		set name [join [expr {([info tclversion] >= "8.1")?
			[lrange $chaninfo 0 end-1]:
			[lrange $chaninfo 0 [expr [llength $chaninfo]-2]]}]]

		if {$name == $flag} {return [lindex $chaninfo end]}
	}; return -1
}


# clist2list <clist>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Decompress <clist>.  A compressed index consists of <start>-<stop>.  If
#       <stop> is less than <stop>, it is removed from the list.  <start> and <stop>
#       must be of the same type.  There are 3 types; integers, small cased letters,
#       capital cased letters.  If <start> and <stop> do not consist of the same
#       type, then it's left alone.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The '2list' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       clist2list [list 2-4 a c-e A C-E] => 2 3 4 a c d e A C D E
#       clist2list [list 1 d-b 3 7-5] => 1 3
#       clist2list [list 4 1-B 3] => 4 1-B 3
#     credit:
#       RS at http://mini.net/tcl/526.
#     returns:
#       - Uncompressed list.
proc clist2list {{args ""}} {
	badargs $args 1 1 "clist"
	unlist $args clist

	# Ensure clist is in list format, if not then make it so.
	set clist [2list $clist]

	array set map [list   a  1   b  2   c  3   d  4   e  5 \
	                      f  6   g  7   h  8   i  9   j 10 \
	                      k 11   l 12   m 13   n 14   o 15 \
	                      p 16   q 17   r 18   s 19   t 20 \
	                      u 21   v 22   w 23   x 24   y 25 \
	                      z 26                             \
	                                                       \
	                       1 a    2 b    3 c    4 d    5 e \
	                       6 f    7 g    8 h    9 i   10 j \
	                      11 k   12 l   13 m   14 n   15 o \
	                      16 p   17 q   18 r   19 s   20 t \
	                      21 u   22 v   23 w   24 x   25 y \
	                      26 z]

	set re_syntax {^(([0-9]+-[0-9]+)|([A-Z]-[A-Z])|([a-z]-[a-z]))$}
	set res {}
	foreach i $clist {
		if {[regexp $re_syntax $i -> range a b c]} {
			set range [split $range -]
			set start [lindex $range 0]
			set stop  [lindex $range 1]
			switch -- [expr {($a!="")?1:($b!="")?2:($c!="")?3:4}] {
				1 {
					for {set j $start} {$j <= $stop} {incr j} {
						lappend res $j
					}
				}
				2 {
					set j $map([string tolower $start])
					for {} {$j <= $map([string tolower $stop])} {incr j} {
						lappend res [string toupper $map($j)]
					}
				}
				3 {
					for {set j $map($start)} {$j <= $map($stop)} {incr j} {
						lappend res $map($j)
					}
				}
			}
		}	else {lappend res $i}
	}; return $res
}


# ctcp <nick|channel> <command [text]>
#     version:
#       v1.3
#     information (mc.moretools command):
#       Send a CTCP <command> to <nick|channel>.  <command [text]> should be in
#       string format, using a white space to separate the <command> from [text] (as
#       opposed to list formatting it).  If <command> is 'PING', case insensitive,
#       and [text] isn't supplied; text will automatically be filled in to current
#       unix time.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       ctcp #abc123 PING
#       ctcp #abc123 "MP3 Eagles - Greatest Hits (Volume 2) - Hotel California.mp3"
#     credit:
#     returns:
#       - Nothing.
proc ctcp {{args ""}} {
	badargs $args 2 2 {nick|channel "command ?text?"}
	unlist $args dest text
	unlist [2list $text] command {args ""}

	set command [string toupper $command]
	set text [unlist $args]

	if {($command == "PING") && ([string trim $text] == "")} {
		set text [clock seconds]
	}; putserv "PRIVMSG $dest :\001$command $text\001"
}


# dccchat <nick>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Sends a DCC Chat invitation to <nick>.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'ctcp' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - 0, if no 'listen' telnet ports are setup.
#       - 1, on success.
proc dccchat {{args ""}} {
	badargs $args 1 1 "nick"
	unlist $args nick

	foreach item [dcclist TELNET] {
		set hand [lindex $item 1]
		if {($hand != "(users)") && ($hand != "(telnet)")} {continue}
		set port [lindex [lindex $item 4] 1]
		ctcp $nick "DCC CHAT chat [myip] $port"
		return 1
	}; return 0
}


# commify <number>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Turn <number> into a standard comma formatted string.  If <number> is an
#       invalid real number, it is returned unformatted.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       commify 5165956161615684.5191 => 5,165,956,161,615,684.5191
#       commify -5000 => -5,000
#     credits:
#     returns:
#       - <number> is returned unformatted, if invalid real number.
#       - <number> is returned after being put into comma format, if valid real
#         number.
proc commify {{args ""}} {
	badargs $args 1 1 "number"
	unlist $args number

	if {[regexp -- {[^0-9+-. ]} $number]} {return $number}
	set re_syntax [expr {([info tclversion] < "8.1")?
		{^([-+]?[0-9]+)([0-9][0-9][0-9])}:
		{^([-+]?\d+)(\d{3})}}]
	while {[regsub $re_syntax $number {\1,\2} number]} {}
	return $number
}


# filter [switch] <text>
#     version:
#       v3.0
#     information (mc.moretools command):
#       This filters special characters within <text>.  In other words, adds a \
#       in front of each \, {, }, [, ], and ".  This should be used for doing strange
#       things as string glob searching through a list (faster than winding through
#       the list), otherwise proper list<>string formatting is urged.
#       Valid switches:
#         -regexp  - Filter <text> in preparation for <text> to be used in a regular
#                    expression.
#         -tcl     - Filter special TCL characters in <text>.
#         --       - Marks the end of switches.
#       If no switch is specified, -tcl is assumed.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#     examples:
#       filter -tcl {TCL+T]<} => TCL+T\]<
#       filter -regexp {TCL+T]<} => TCL\+T\]<
#
#       # This example is to show why -- is given as a switch.
#       filter -- {-TCL+T]<} => -TCL+T\]<
#       filter {-TCL+T]<} =>
#         Tcl error: bad switch "-TCL+T]<": must be -regexp, -tcl, or --
#       # If there is a chance that <text> is going to start with a -, then
#       # utilize the -- switch.
#     credits:
#       - Back in 1997-1998 I found this command in bass' bseen TCL script for
#         eggdrop, however it's been modified since there.
#     returns:
#       - <text> after filtered.
proc filter {{args ""}} {
	badargs $args 1 2 "?switch? text"

	set switches ""
	set valid [join "-regexp -tcl {or --}" ", "]
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i; break} {
		if {![regexp -- {^-(regexp|tcl|-)$} $arg -> switch]} {
			error "bad switch \"$arg\": must be $valid"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	set switch [expr {($switches == "")?"tcl":[lindex $switches 0]}]
	set text [lindex $args $i]

	switch -- $switch {
		tcl {set re_syntax {([][\\\{\}\"])}}
		regexp {set re_syntax {([][\\*+?{},():.^$=!|])}}
		default {error "bad switch \"$switch\":  must be $valid"}
	}
	regsub -all -- $re_syntax $text {\\\1} text

	return $text
}


# findip [switch] <text>
#     version:
#       v2.0
#     information (mc.moretools command):
#       Weed out all logical IP address' within <text>.  If no switch is specified,
#       it will default to the -- switch.
#       Switches:
#         -overlap  Starts the next ip search point at next ip atom of the ip found.
#         --        Starts the next ip search point after ip found.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       findip "test1.2.3.4.5this6.7.8.9.0line" => 1.2.3.4 6.7.8.9
#       findip -overlap "test1.2.3.4.5this6.7.8.9.0line" =>
#         1.2.3.4 2.3.4.5 6.7.8.9 7.8.9.0
#
#       # This example is to show why -- is given as a switch.
#       findip -- "-test1.2.3.4.5this6.7.8.9.0line" => 1.2.3.4 6.7.8.9
#       findip "-test1.2.3.4.5this6.7.8.9.0line"
#         Tcl error:  bad switch "-test1.2.3.4.5this6.7.8.9.0line": must be -overlap,
#                     or --
#       # If there is a chance that <text> is going to start with a -, then
#       # utilize the -- switch.
#     credits:
#     returns:
#       - A list of IP address' found in <text>.
proc findip {{args ""}} {
	badargs $args 1 2 "?switch? text"
	unlist $args text

	set switch ""
	if {[string match -* $text]} {
		if {![regexp -- {^-(overlap|-)$} $text -> switch]} {
			error "bad switch \"$text\": must be -overlap, or --"
		}
		if {$switch == "-"} {set switch ""}
		set text [lindex $args 1]
	}

	if {[info tclversion] < "8.1"} {
		set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
		set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
	} else {
		set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
		set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
	}
	set re_syntax $re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2

	set ips ""
	while {[regexp -- $re_syntax $text ip]} {
		lappend ips $ip
		set text [string range $text [string first $ip $text] end]
		switch -- $switch {
			overlap {set text [string range $text [string first .   $text] end]}
			default {set text [string range $text [string length $ip     ] end]}
		}
 	}; return $ips
}


# findpartyusers <handle!ident@host.domain>
#     version:
#       v2.0
#     information (mc.moretools command):
#       Find users on the partyline that match <handle!ident@host.domain>.
#       <handle!ident@host.domain> can contain wild cards.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - A list of users found in <handle[@bot]> format.  If handle is on local bot,
#         [@bot] isn't specified.
proc findpartyusers {{args ""}} {
	badargs $args 1 1 "handle!ident@host.domain"
	unlist $args hostmask

	set hostmask [string tolower $hostmask]
	global botnet-nick
	set list ""
	foreach user [whom *] {
		set handle [lindex $user 0]
		set nuhost [string tolower $handle![lindex $user 2]]
		if {[string match $hostmask $nuhost]} {
			set bot [lindex $user 1]
			lappend list $handle[expr {($bot == ${botnet-nick})?"":"@$bot"}]
		}
	}; return $list
}


# findnicks <nick!ident@host.domain> [channel]
#     version:
#       v2.0
#     information (mc.moretools command):
#       Obtain a list of nicks that match <handle!ident@host.domain>.
#       <handle!ident@host.domain> can contain wild cards.  If channel isn't
#       specified, all channels are evaluated.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - A list of nicks found in <nick[@channel]> format.  If [channel] was
#         specified, then [@channel] isn't returned.
proc findnicks {{args ""}} {
	badargs $args 1 2 "nick!ident@host.domain ?channel?"
	unlist $args hostmask channel

	set hostmask [string tolower $hostmask]

	if {$channel == ""} {set channels [channels]} \
	elseif {![validchan $channel]} {error "no such channel record"} \
	else {set channels [list $channel]}
	set origional_channel $channel

	set list ""
	foreach channel $channels {
		foreach user [chanlist $channel] {
			set nuhost [string tolower $user![getchanhost $user $channel]]
			if {[string match $hostmask $nuhost]} {
				lappend list $user[expr {($origional_channel != "")?"":"@$channel"}]
			}
		}
	}; return $list
}


# getchanhost <nick> [channel]
#     version:
#       v2.0
#     information (mc.moretools command):
#       Find the uhost of <nick>.  On older eggdrops, pre version 1.4.2, this command
#       uses the channel argument as a mandatory argument rather than optional.  On
#       newer bots it is optional.  Regardless of what bot version you run, this will
#       make the channel field optional.  This proc is good for fixing this error,
#       which only occurs with old bots and new scripts;
#         TCL error: wrong # args: should be "getchanhost nickname channel"
#       This is basically a command to help provide backwards compatibility.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - The found uhost, 'ident@host.domain' (if any).
if {$numversion < "1040200"} {
	if {[info commands getchanhost:origional] == ""} {
		# Keep in mind that the 'getchanhost' command may not be the original one as we
		# want it to be, but we will take what we can get since there is no way to
		# counteract this.
		rename getchanhost getchanhost:origional
	}
	proc getchanhost {{args ""}} {
		badargs $args 1 2 "nick ?channel?"
		unlist $args nick channel

		if {$channel == ""} {set channels [channels]} \
		elseif {![validchan $channel]} {error "no such channel record"} \
		else {set channels [list $channel]}

		foreach channel $channels {
			if {[onchan $nick $channel]} {
				return [getchanhost:origional $nick $channel]
			}
		}; return ""
	}
}

# i18n <type> [name]
#     version:
#       v1.0
#     information (mc.moretools command):
#       Get the opposite name of [name] pertaining to the <type>.  By opposite, I'm
#       referring to short or long name.  <type> is one of country or language.
#       [name] can consist of the short name or long name, case insensitive.  If
#       [name] isn't specified; a list of <type> is returned, with sub list entries
#       of short name, long name.  There are way to many [names] to list here, review
#       the actually command for a list.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       i18n country "united states" => US
#       i18n country us => United States
#       i18n language fr => French
#       i18n language romanian => ro
#     credits:
#       Richard Suchenwirth at http://mini.net/tcl/527.html
#     returns:
#       - List of <types>, if no [name] argument.
#       - Short name of [name], if [name] is long.
#       - Long name of [name], if [name] is short.
proc i18n {{args ""}} {
	badargs $args 1 2 "type ?name?"
	unlist $args type name

	if {$type == "country"} {
		set list [list \
			AD "Andorra"                        AE "United Arab Emirates" \
			AF "Afghanistan"                    AG "Antigua and Barbuda" \
			AI "Anguilla"                       AL "Albania" \
			AM "Armenia"                        AN "Netherlands Antilles" \
			AO "Angola"                         AQ "Antarctica" \
			AR "Argentina"                      AS "American Samoa" \
			AT "Austria"                        AU "Australia" \
			AW "Aruba"                          AZ "Azerbaijan" \
			BA "Bosnia and Herzegowina"         BB "Barbados" \
			BD "Bangladesh"                     BE "Belgium" \
			BF "Burkina Faso"                   BG "Bulgaria" \
			BH "Bahrain"                        BI "Burundi" \
			BJ "Benin"                          BM "Bermuda" \
			BN "Brunei Darussalam"              BO "Bolivia" \
			BR "Brazil"                         BS "Bahamas" \
			BT "Bhutan"                         BV "Bouvet Island" \
			BW "Botswana"                       BY "Belarus" \
			BZ "Belize"                         CA "Canada" \
			CC "Cocos (Keeling) Islands"        CF "Central African Republic" \
			CG "Congo"                          CH "Switzerland" \
			CI "Cote d'Ivoire"                  CK "Cook Islands" \
			CL "Chile"                          CM "Cameroon" \
			CN "China"                          CO "Colombia" \
			CR "Costa Rica"                     CU "Cuba" \
			CV "Cape Verde"                     CX "Christmas Island" \
			CY "Cyprus"                         CZ "Czech Republic" \
			DE "Germany"                        DJ "Djibouti" \
			DK "Denmark"                        DM "Dominica" \
			DO "Dominican Republic"             DZ "Algeria" \
			EC "Ecuador"                        EE "Estonia" \
			EG "Egypt"                          EH "Western Sahara" \
			ER "Eritrea"                        ES "Spain" \
			ET "Ethiopia"                       FI "Finland" \
			FJ "Fiji"                           FK "Falkland Islands (Malvinas)" \
			FM "Micronesia, Federated States Of" FO "Faroe Islands" \
			FR "France"                         FX "France, Metropolitan" \
			GA "Gabon"                          GB "United Kingdom" \
			GD "Grenada"                        GE "Georgia" \
			GF "French Guiana"                  GH "Ghana" \
			GI "Gibraltar"                      GL "Greenland" \
			GM "Gambia"                         GN "Guinea" \
			GP "Guadeloupe"                     GQ "Equatorial Guinea" \
			GR "Greece"                 GS "South Georgia and The South Sandwich Islands" \
			GT "Guatemala"                      GU "Guam" \
			GW "Guinea-Bissau"                  GY "Guyana" \
			HK "Hong Kong"                      HM "Heard and Mc Donald Islands" \
			HN "Honduras"                       HR "Croatia" \
			HT "Haiti"                          HU "Hungary" \
			ID "Indonesia"                      IE "Ireland" \
			IL "Israel"                         IN "India" \
			IO "British Indian Ocean Territory" IQ "Iraq" \
			IR "Iran"                           IS "Iceland" \
			IT "Italy"                          JM "Jamaica" \
			JO "Jordan"                         JP "Japan" \
			KE "Kenya"                          KG "Kyrgyzstan" \
			KH "Cambodia"                       KI "Kiribati" \
			KM "Comoros"                        KN "Saint Kitts and  Nevis" \
			KP "Korea, Democratic People's Republic Of" KR "Korea, Republic Of" \
			KW "Kuwait"                         KY "Cayman Islands" \
			KZ "Kazakhstan"                     LA "Lao People's Democratic Republic" \
			LB "Lebanon"                        LC "Saint Lucia" \
			LI "Liechtenstein"                  LK "Sri Lanka" \
			LR "Liberia"                        LS "Lesotho" \
			LT "Lithuania"                      LU "Luxembourg" \
			LV "Latvia"                         LY "Libyan Arab Jamahiriya" \
			MA "Morocco"                        MC "Monaco" \
			MD "Moldova, Republic Of"           MG "Madagascar" \
			MH "Marshall Islands"         MK "Macedonia, The Former Yugoslav Republic Of" \
			ML "Mali"                           MM "Myanmar" \
			MN "Mongolia"                       MO "Macau" \
			MP "Northern Mariana Islands"       MQ "Martinique" \
			MR "Mauritania"                     MS "Montserrat" \
			MT "Malta"                          MU "Mauritius" \
			MV "Maldives"                       MW "Malawi" \
			MX "Mexico"                         MY "Malaysia" \
			MZ "Mozambique"                     NA "Namibia" \
			NC "New Caledonia"                  NE "Niger" \
			NF "Norfolk Island"                 NG "Nigeria" \
			NI "Nicaragua"                      NL "Netherlands" \
			NO "Norway"                         NP "Nepal" \
			NR "Nauru"                          NU "Niue" \
			NZ "New Zealand"                    OM "Oman" \
			PA "Panama"                         PE "Peru" \
			PF "French Polynesia"               PG "Papua New Guinea" \
			PH "Philippines"                    PK "Pakistan" \
			PL "Poland"                         PM "St. Pierre and Miquelon" \
			PN "Pitcairn"                       PR "Puerto Rico" \
			PT "Portugal"                       PW "Palau" \
			PY "Paraguay"                       QA "Qatar" \
			RE "Reunion"                        RO "Romania" \
			RU "Russian Federation"             RW "Rwanda" \
			SA "Saudi Arabia"                   SB "Solomon Islands" \
			SC "Seychelles"                     SD "Sudan" \
			SE "Sweden"                         SG "Singapore" \
			SH "St. Helena"                     SI "Slovenia" \
			SJ "Svalbard and Jan Mayen Islands" SK "Slovakia (Slovak Republic)" \
			SL "Sierra Leone"                   SM "San Marino" \
			SN "Senegal"                        SO "Somalia" \
			SR "Suriname"                       ST "Sao Tome and Principe" \
			SV "El Salvador"                    SY "Syrian Arab Republic" \
			SZ "Swaziland"                      TC "Turks and Caicos Islands" \
			TD "Chad"                           TF "French Southern Territories" \
			TG "Togo"                           TH "Thailand" \
			TJ "Tajikistan"                     TK "Tokelau" \
			TM "Turkmenistan"                   TN "Tunisia" \
			TO "Tonga"                          TP "East Timor" \
			TR "Turkey"                         TT "Trinidad and Tobago" \
			TV "Tuvalu"                         TW "Taiwan" \
			TZ "Tanzania, United Republic Of"   UA "Ukraine" \
			UG "Uganda"                         UM "United States Minor Outlying Islands" \
			US "United States"                  UY "Uruguay" \
			UZ "Uzbekistan"                     VA "Vatican State" \
			VC "Saint Vincent and The Grenadines" VE "Venezuela" \
			VG "Virgin Islands (British)"       VI "Virgin Islands (U.S.)" \
			VN "Viet Nam"                       VU "Vanuatu" \
			WF "Wallis and Futuna Islands"      WS "Samoa" \
			YE "Yemen"                          YT "Mayotte" \
			YU "Yugoslavia"                     ZA "South Africa" \
			ZM "Zambia"                         ZR "Zaire" \
			ZW "Zimbabwe"]
	} elseif {$type == "language"} {
		set list [list \
			aa "Afar"                           ab "Abkhazian" \
			af "Afrikaans"                      am "Amharic" \
			ar "Arabic"                         as "Assamese" \
			ay "Aymara"                         az "Azerbaijani" \
			ba "Bashkir"                        be "Byelorussian" \
			bg "Bulgarian"                      bh "Bihari" \
			bi "Bislama"                        bn "Bengali" \
			bo "Tibetan"                        br "Breton" \
			ca "Catalan"                        co "Corsican" \
			cs "Czech"                          cy "Welsh" \
			da "Danish"                         de "German" \
			dz "Bhutani"                        el "Greek" \
			en "English"                        eo "Esperanto" \
			es "Spanish"                        et "Estonian" \
			eu "Basque"                         fi "Finnish" \
			fj "Fiji"                           fo "Faroese" \
			fr "French"                         fy "Frisian" \
			ga "Irish"                          gl "Galician" \
			gn "Guarani"                        gu "Gujarati" \
			ha "Hausa"                          hi "Hindi" \
			hr "Croatian"                       hu "Hungarian" \
			hy "Armenian"                       ia "Interlingua" \
			ie "Interlingue"                    ik "Inupiak" \
			in "Indonesian"                     is "Icelandic" \
			it "Italian"                        iw "Hebrew" \
			ja "Japanese"                       ji "Yiddish" \
			jv "Javanese"                       ka "Georgian" \
			kk "Kazakh"                         kl "Greenlandic" \
			km "Cambodian"                      kn "Kannada" \
			ko "Korean"                         ks "Kashmiri" \
			ku "Kurdish"                        ky "Kirghiz" \
			la "Latin"                          ln "Lingala" \
			lo "Laothian"                       lt "Lithuanian" \
			lv "Latvian"                        mg "Malagasy" \
			mi "Maori"                          mk "Macedonian" \
			ml "Malayalam"                      mn "Mongolian" \
			mo "Moldavian"                      mr "Marathi" \
			ms "Malay"                          mt "Maltese" \
			my "Burmese"                        na "Nauru" \
			ne "Nepali"                         nl "Dutch" \
			no "Norwegian"                      oc "Occitan" \
			om "Afan(Oromo)"                    or "Oriya" \
			pa "Punjabi"                        pl "Polish" \
			ps "Pashto"                         pt "Portuguese" \
			qu "Quechua"                        rm "Rhaeto-romance" \
			rn "Kurundi"                        ro "Romanian" \
			ru "Russian"                        rw "Kinyarwanda" \
			sa "Sanskrit"                       sd "Sindhi" \
			sg "Sangho"                         sh "Serbo-croatian" \
			si "Singhalese"                     sk "Slovak" \
			sl "Slovenian"                      sm "Samoan" \
			sn "Shona"                          so "Somali" \
			sq "Albanian"                       sr "Serbian" \
			ss "Siswati"                        st "Sesotho" \
			su "Sundanese"                      sv "Swedish" \
			sw "Swahili"                        ta "Tamil" \
			te "Telugu"                         tg "Tajik" \
			th "Thai"                           ti "Tigrinya" \
			tk "Turkmen"                        tl "Tagalog" \
			tn "Setswana"                       to "Tonga" \
			tr "Turkish"                        ts "Tsonga" \
			tt "Tatar"                          tw "Twi" \
			uk "Ukrainian"                      ur "Urdu" \
			uz "Uzbek"                          vi "Vietnamese" \
			vo "Volapuk"                        wo "Wolof" \
			xh "Xhosa"                          yo "Yoruba" \
			zh "Chinese"                        zu "Zulu"]
	} else {
		error "bad type \"$type\": must be country, or language"
	}
	set index [lsearch -exact [string tolower $list] [string tolower $name]]
	return [expr {
		($name == "") ? $list :
		($index == "-1") ? "" :
		($index % 2) ? [lindex $list [expr $index-1]] :
		[lindex $list [expr $index+1]]}]
}


# islinked <bot>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Determin if <bot> is currently linked to local bot.  This command was
#       introduced to eggdrop in version 1.4.2.  Regardless of what bot version you
#       run, this code will ensure the command works on your eggdrop bot.  This proc
#       is good for fixing this error, which only occurs with old bots and new
#       scripts;
#         Tcl error: invalid command name "islinked"
#       This is basically a command to help provide backwards compatibility.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - 0, if <bot> is not currently linked.
#       - 1, if <bot> is currently linked.
if {$numversion < "1040200"} {
	proc islinked {{args ""}} {
		badargs $args 1 1 "bot"
		unlist $args bot

		set bot [string tolower $bot]
		return [expr {([lsearch -exact [string tolower [bots]] $bot] == "-1")?0:1}]
	}
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.0.1
#     information (mc.moretools command):
#       Masks <nick!ident@host.domain> by <type>.  If [type] is not specified, then 5
#       is assumed.
#       Valid types are:
#         0 - *!user@host.domain
#         1 - *!*user@host.domain
#         2 - *!*@host.domain
#         3 - *!*user@*.domain
#         4 - *!*@*.domain
#         5 - nick!user@host.domain
#         6 - nick!*user@host.domain
#         7 - nick!*@host.domain
#         8 - nick!*user@*.domain
#         9 - nick!*@*.domain
#       You can also specify a type of 10-19 which corresponds to types 0-9, using
#       this sub rule;  If host.domain is a(n)-
#         name - Instead of using a * wildcard to replace portions of the
#                host.domain, it replaces the numbers in the host.domain with a '?'
#                (question mark) wildcard.
#         ip   - It will mask as normal, with no '?' (question mark) replacements as
#                does hostname.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       maskhostbytype MC_8!mc8@austin001.rr.com 3 => *!*mc8@*.rr.com
#       maskhostbytype MC_8!mc8@austin001.rr.com 13 => *!*mc8@austin???.rr.com
#     credits:
#       mIRC - using its numbering system for [type].
#     returns:
#       - <nick!user@host.domain> masked accordingly.
proc maskhostbytype {{args ""}} {
	badargs $args 1 2 "nick!ident@host.domain ?type?"
	unlist $args nuhost type


	set type [expr {($type == "")?5:$type}]
	if {![regexp -- {^1?[0-9]$} $type]} {
		set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
		error "bad type \"$type\": must be [join $valid ", "]"
	}

	# Define the maximum length the ircd allows for an ident.  Standard is 9, however I
	# made it to a variable incase someone wants to change it up.
	set ident_max-length 9

	# Define the maximum length the ircd allows for a hostname/ ip.  Standard is 63,
	# however I made it to a variable incase someone wants to change it up.
	set host_max-length 63

	if {![regexp -- {^(.*[^!])!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
		error "invalid nick!ident@host.domain: $nuhost"
	}

	set maskhost 1
	if {[string length $type] == "2"} {
		# Type must be 10-19.
		if {[info tclversion] < "8.1"} {
			set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
			set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
		} else {
			set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
			set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
		}
		set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

		if {![regexp -- $re_syntax $host]} {
			regsub -all -- {[0-9]} $host ? host
			set maskhost 0
		}; set type [string index $type 1]
	}

	# Previous version used regexp instead of these string matches.  String match in
	# this case is ~3 microseconds faster.
	if {[string match {[0-4]} $type]} {set nick *}
	if {[string match {[2479]} $type]} {set ident *}
	if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
	if {[string match {[3489]} $type] && $maskhost} {
		set host [lindex [split [maskhost $host] @] end]
	}

	if {[set length [string length $ident]] > ${ident_max-length}} {
		set ident *[string range $ident [expr $length-${ident_max-length}] end]
	}
	if {[set length [string length $host]] > ${host_max-length}} {
		set host *[string range $host [expr $length-${host_max-length}] end]
	}

	return $nick!$ident@$host
}


# math <option> <numbers>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Perform a mathematical function, specified by <option>, on the list of
#       <numbers>.
#       Valid <option>s are:
#         average  - Average of <numbers>.
#         add      - Same as `sum`.
#         largest  - Largest number out of <numbers>.
#         smallest - Smallest number out of <numbers>.
#         subtract - Sun (subtraction) of <numbers>.
#         sum      - Sum (addition) of <numbers>.
#         f2c      - Convert Fahrenheit to Celsius.
#         c2f      - Convert Celsius to Fahrenheit.
#         ft2m     - Convert Feet to Meters.
#         m2ft     - Convert Meters to Feet.
#         mi2km    - Convert Miles to Kilometers.
#         km2mi    - Convert Kilometers to Miles.
#         << There are so many conversion possibilities I can add, e-mail me if you
#            have one you want me to add. >>
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       math average "1 2 4 6 8 16" => 6.16666666667
#       math largest "1 2 4 6 8 16" => 16
#       math smallest "1 2 4 6 8 16" => 1
#       math subtract "1 2 4 6 8 16" => -35
#       math sum "1 2 4 6 8 16" => 37
#     credits:
#       RS at http://mini.net/tcl/526, for the idea of average.
#       http://www.onlineconversion.com/
#     returns:
#       - Appropriate mathematical output.
proc math {{args ""}} {
	badargs $args 2 2 "option numbers"
	unlist $args option numbers

	# Ensure $numbers is in list format.
	set numbers [2list $numbers]

	# Remove comma's within numbers, if there.
	set numbers [replace -- $numbers [list , ""]]

	if {[regexp -- {([^0-9 \.])} [join $numbers] -> bad]} {
		error "bad number \"$bad\" in: [join $numbers]"
	}

	switch -- $option {
		average {
			if {[catch {expr ([join $numbers +])/[llength $numbers].} return]} {
				error "error during average calculation of \"[join $numbers]\": $return"
			}; return $return
		}
		add {
			if {[catch {expr [join $numbers +]} return]} {
				error "error during add calculation of \"[join $numbers]\": $return"
			}; return $return
		}
		dec2lbin {
			unlist $numbers dec
			set lbin ""
			for {set index 1} {$index < $dec} {incr index $index} {}
			for {} {$index > 0} {set index [expr $index/2]} {
				if {$dec >= $index} {
					lappend lbin $index
					incr dec -$index
				}
			}; return $lbin
		}
		largest {
			if {[catch {lsort -real $numbers} return]} {
				error "error during largest calculation of \"[join $numbers]\": $return"
			}; return [lindex $return end]
		}
		smallest {
			if {[catch {lsort -real $numbers} return]} {
				error "error during smallest calculation of \"[join $numbers]\": $return"
			}; return [lindex $return 0]
		}
		subtract {
			if {[catch {expr [join $numbers -]} return]} {
				error "error during subtraction calculation of \"[join $numbers]\": $return"
			}; return $return
		}
		sum {
			if {[catch {expr [join $numbers +]} return]} {
				error "error during sum calculation of \"[join $numbers]\": $return"
			}; return $return
		}
		f2c {
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr (5/9.)*($in-32)]
		}
		c2f {
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr 1.8*$c+32]
		}
		ft2m {
			# 1  Meter = 3.28084  Feet
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr $in/3.28084]
		}
		m2ft {
			# 1  Feet = 0.3048  Meters
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr $in/0.3048]
		}
		mi2km {
			# 1  Kilometers = 0.621371  Miles
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr $in/0.621371]
		}
		km2mi {
			# 1  Miles = 1.609344  Kilometers
			unlist $numbers {in 0}
			if {[regexp -- {([^0-9.])} $in -> bad]} {error "bad number \"$bad\" in: $in"}
			return [expr $in/1.609344]
		}
		default {
			set options "average add largest smallest subtract {or sum}"
			error "bad option \"$option\": must be [join $options ", "]"
		}
	}
}


# mirc_format <text>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Convert <text> into mIRC compliant text (regarding control characters).
#       Valid control characters:
#         ^b for bold
#         ^u for underline
#         ^r for reverse
#         ^k for color
#         ^o for plain
#       The ^ in these are actually ^'s and not the control key.  An open color code
#       should be followed by a foreground color number and an optional comma then
#       background color number, such as <foreground[,background]>.
#       Valid color numbers are;
#         0 white       6 purple       12 light blue
#         1 black       7 orange       13 pink
#         2 blue        8 yellow       14 grey
#         3 green       9 light green  15 light grey
#         4 light red  10 cyan
#         5 brown      11 light cyan
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'replace' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       % mirc_format "^k4color^k ^bbold^b ^uunderline^u"
#       4color bold underline
#     credits:
#     returns:
#       - <text> after converted.
proc mirc_format {{args ""}} {
	badargs $args 1 1 "text"
	unlist $args text

	return [replace -- $text [list ^b \002 ^k \003 ^o \017 ^r \026 ^u \037]]
}


# mirc_strip [switches] <text>
#     version:
#       v1.0
#     information (mc.moretools command):
#       Strip mIRC compliant control codes from <text>.
#       Valid switches:
#         -bold      Strip the bold control code.
#         -color     Strip the color control code (and color specific numbers).
#         -plain     Strip the plain control code.
#         -reverse   Strip the reverse control code
#         -underline Strip the underline control code
#         --         Marks the end of switches.
#       If no switches are specified, then -all is assumed.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'replace' command from mc.moretools.
#     examples:
#       set text "\002bold\002 \00304,00color\003 \026reverse\026 \037underline\037"
#       mirc_strip $text => bold Red on white Reverse Underline
#       mirc_strip -bold $text => bold 04,00Red on white Reverse Underline
#       mirc_strip -color -underline $text => bold Red on white Reverse Underline
#
#       # This example is to elaborate on why -- is given as a switch.
#       set text "-text_\002text\002_text-"
#       mirc_strip -bold -- $text => -text_text_text-
#       mirc_strip -bold $text =>
#         Tcl error: bad switch "-text_text_text-": must be -bold, -color,
#                    -reverse, -underline, or --
#       # If there is a chance that <text> is going to start with a -, then
#       # utilize the -- switch.
#     credits:
#     returns:
#       - <text> after stripped of the appropriate control codes.
proc mirc_strip {{args ""}} {
	badargs $args 1 7 "?switches? text"
	set switches ""
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
		if {![regexp -- {^-(all|bold|color|reverse|underline|-)$} $arg -> switch]} {
			set valid "-all -bold -color -reverse -underline {or --}"
			error "bad switch \"$arg\": must be [join $valid ", "]"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	if {$switches == ""} {set switches all}
	set arg [lindex $args $i]
	badargs [lrange $args $i end] 1 1 "?switches? text"

	set all [expr {([lsearch -exact $switches all] >= 0) ? 1 : 0}]
	set list ""
	if {$all} {
		set list [list \002 "" \017 "" \026 "" \037 ""]
	} else {
		if {[lsearch -exact $switches bold] >= 0} {lappend list [list \002 ""]}
		if {[lsearch -exact $switches plain] >= 0} {lappend list [list \017 ""]}
		if {[lsearch -exact $switches reverse] >= 0} {lappend list [list \026 ""]}
		if {[lsearch -exact $switches underline] >= 0} {lappend list [list \037 ""]}
	}
	if {$all || ([lsearch -exact $switches color] >= 0)} {
		regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $arg "" arg
	}
	set arg [replace -- $arg [join $list]]

	return $arg
}


# msg <nick|channel> <text>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Send a PRIVMSG to <nick|channel> stating <text>.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - Nothing.
proc msg {{args ""}} {
	badargs $args 2 2 "nick|channel text"
	unlist $args dest text

	putserv "PRIVMSG $dest :$text"
}


# notice <nick|channel> <text>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Send a NOTICE to <nick|channel> stating <text>.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - Nothing.
proc notice {{args ""}} {
	badargs $args 2 2 "nick|channel text"
	unlist $args dest text

	putserv "NOTICE $dest :$text"
}


# replace [switches] <text> <substitutions>
#     version:
#       v1.3
#     information (mc.moretools command):
#       Replaces characters in <text> based on the key-value pairs in
#       <substitutions>. <substitutions> is a list of key value key value ... as in
#       the form returned by array get. Each instance of a key in the <text> will be
#       replaced with its corresponding value. Both key and value may be multiple
#       characters. Replacement is done in an ordered manner, so the key appearing
#       first in the list will be checked first, and so on. If using TCL 8.1 or
#       greater; <text> is only iterated over once, so earlier key replacements will
#       have no affect for later key matches.
#       Switches:
#         -nocase   Matching is done without regard to case differences.
#         --        Marks the end of switches.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The '2list' command from mc.moretools.
#     examples:
#       replace abcdefg [list cd xyz]  => abxyzefg
#       replace abcdefg [list a A b B c C d D]  => ABCDefg
#       replace abcdefg [list d " the middle "] => abc the middle efg
#
#       # This example is to show why -- is given as a switch.
#       replace -- -aa-bb-cc "-a -A -b -B -c -C" => -Aa-Bb-Cc
#       replace -aa-bb-cc "-a -A -b -B -c -C" =>
#         Tcl error: bad switch "-aa-bb-cc": must be -nocase, or --
#       # If there is a chance that <text> is going to start with a -, then
#       # utilize the -- switch.
#     credits:
#     returns:
#       - <text> after replacements of keys with values from substitutions have been
#         done.
proc replace {{args ""}} {
	badargs $args 2 4 "?switches? text substitutions"
	set switches ""
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
		if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
			error "bad switch \"$arg\": must be -nocase, or --"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
	set text [lindex $args $i]
	set substitutions [lindex $args [expr $i+1]]
	badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

	# Check to see if $substitutions is in list format, if not make it so.
	set substitutions [2list $substitutions]

	if {[info tclversion] >= "8.1"} {
		return [expr {($nocase)?
			[string map -nocase $substitutions $text]:
			[string map $substitutions $text]}]
	}

	set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
	foreach {a b} $substitutions {
		regsub -all -- $re_syntax $a {\\\1} a
		if {$nocase} {regsub -all -nocase -- $a $text $b text} \
		else {regsub -all -- $a $text $b text}
	}; return $text
}

# sendemail <from> <to> <subject> <body> [headers] [-wait]
#     version:
#       v1.3
#     information (mc.moretools command):
#       Send an e-mail to <to>.
#       <from> should be in this format: [list "Full Name" "from@address.com"]
#       <to> should be in this format: [list "Full Name_1" "from@address.com_1" \
#                                            "Full Name_2" "from@address.com_2" \
#                                             ...]
#         As you can see, <to> can contain multi addresses, unlike <from>.
#       [headers] should be in this format: [list "header 1" "header 2" ...]
#       [-wait], if you specify '-wait' then the proc will not be asynchronous,
#         meaning it will wait for the e-mail send to finish before returning
#         (thought up for CGI use).
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       set from [list "Carl M. Gregory (MC_8)" "mc8-pass@purehype.net"]
#       set to   [list "Jeff Fisher (guppy)"    "guppy@techmonkeys.org" \
#                       "Eggdrop Development"    "eggdev@eggheads.org"]
#       set subject "guppy broke eggdrop!"
#       set body "Welp, guppy did it again!\
#               \n\
#               \nHe broke eggdrop.\
#               \n ..."
#       set headers [list "Content-Type: text/plain"]
#       sendemail $from $to $subject $body $headers -wait
#     credits:
#     returns:
#       - Nothing.
set mc_moretools(smtp_server) smtp.server.com  ;# What's the smtp server's address?
set mc_moretools(smtp_port) 25                 ;# What's the smtp port?

# You can set this to emulate another SMTP client.
set mc_moretools(xmailer) "Send eMail procedure by MC_8 (Carl M. Gregory) - http://mc.purehype.net/ - TCL [info tclversion] ([info patchlevel])."

proc sendemail {{args ""}} {
	badargs $args 4 6 "from to subject body ?headers? ?-wait?"
	unlist $args from to subject body headers wait

	global mc_moretools

	if {($wait == "") && ($headers == "-wait")} {
		set wait -wait
		set headers ""
	}
	if {$wait == "-wait"} {
		if {[catch {socket $mc_moretools(smtp_server) $mc_moretools(smtp_port)} sid]} {
			error "cannot create socket: $sid"
		}
		set mc_moretools(:vwait:$sid) 1
	} else {
		set sid [socket -async $mc_moretools(smtp_server) $mc_moretools(smtp_port)]
	}
	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "sendemail_fileevent $sid timeout"]
	fileevent $sid readable [list sendemail_fileevent $sid $tout $from $to $subject \
		$body $headers]
	if {$wait == "-wait"} {vwait mc_moretools(:vwait:$sid)}
}
proc sendemail_fileevent {{args ""}} {
	set optional "?from? ?to? ?subject? ?body? ?headers?"
	badargs $args 2 7 "socket_id timeout_after_id $optional"
	unlist $args sid tout from to subject body headers

	global mc_moretools

	set last_command_a :temp:$sid:last_command
	if {$tout == "timeout"} {
		catch {unset mc_moretools($last_command_a)}
		catch {unset mc_moretools(:vwait:$sid)}
		close $sid
		error "timeout connecting to SMTP server"
	}
	if {[eof $sid]} {
		catch {unset mc_moretools($last_command_a)}
		catch {unset mc_moretools(:vwait:$sid)}
		close $sid
		return
	}
	after cancel $tout
	if {![info exists mc_moretools($last_command_a)]} {
		set mc_moretools($last_command_a) ""
	}
	set last_command $mc_moretools($last_command_a)
	gets $sid line
	set line [split $line]
	set rfc [lindex $line 0]
	set info [join [lrange $line 1 end]]
	switch -- $rfc {
		221 {
			switch -- $last_command {
				QUIT {
					catch {unset mc_moretools($last_command_a)}
					catch {unset mc_moretools(:vwait:$sid)}
					close $sid
					return
				}
				default {sendemail_def_error}
			}
		}
		220 {
			switch -- $last_command {
				"" {sendemail_puts $sid "EHLO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		250 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "MAIL From:<[lindex $from 1]>"}
				HELO {sendemail_puts $sid "MAIL From:<[lindex $from 1]>"}
				MAIL {
					set addy [lindex $to 1]
					set mc_moretools(:temp:$sid:last_to) 1
					sendemail_puts $sid "RCPT To:<$addy>"
				}
				RCPT {
					set last_to_a :temp:$sid:last_to
					set last_to $mc_moretools($last_to_a)
					if {$last_to >= [expr [llength $to]-1]} {
						catch {unset mc_moretools(:temp:$sid:last_to)}
						sendemail_puts $sid "DATA "
						return
					}
					incr mc_moretools($last_to_a) 2
					incr last_to 2
					set addy [lindex $to $last_to]
					sendemail_puts $sid "RCPT To:<$addy>"
				}
				DATA_d {
					sendemail_puts $sid "QUIT"
				}
				default {sendemail_def_error}
			}
		}
		354 {
			switch -- $last_command {
				DATA {
					foreach {name addy} $to {
						puts $sid "To: \"$name\" <$addy>"
					}
					puts $sid "From: \"[lindex $from 0]\" <[lindex $from 1]>"
					puts $sid "Subject: $subject"
					foreach header $headers {
						puts $sid $header
					}
					puts $sid "X-Mailer: $mc_moretools(xmailer)"
					puts $sid "X-Originating-Host: [info hostname]"
					puts $sid ""
					foreach line [split $body \n] {
						regsub -- ^\\. $line .. line
						puts $sid $line
					}
					puts $sid .
					flush $sid
					set mc_moretools($last_command_a) DATA_d
				}
				default {sendemail_def_error}
			}
		}
		421 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "HELO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		500 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "HELO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		501 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "HELO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		}
		502 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "HELO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		554 {
			switch -- $last_command {
				EHLO {sendemail_puts $sid "HELO [info hostname]"}
				default {sendemail_def_error}
			}
		}
		default {sendemail_def_error}
	}
}
proc sendemail_puts {sid command} {
	global mc_moretools
	puts $sid $command
	set mc_moretools(:temp:$sid:last_command) [lindex [split $command] 0]
	flush $sid
}
proc sendemail_def_error {} {
	uplevel 1 {error "unknown reply, '$rfc' to '$last_command'; $info"}
}


# str <text> <times>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Repeat <text> <times> times.  'str' is short for string repeat.  The 'repeat'
#       subcommand of 'string' was introduced in TCL version 8.1; this command access
#       that command if appropriate TCL version is found.  Otherwise, my code is
#       initialized.  This is here more as a backwards compatibility command.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#       str abc 0 =>
#       str abc 2 => abcabc
#       str abc 4 => abcabcabcabc
#       str "ho " 3 => ho ho ho
#     credits:
#     returns:
#       - <string> repeated <times> times.
proc str {{args ""}} {
	badargs $args 2 2 "text times"
	unlist $args text times

	if {[regexp -- {([^0-9])} $times -> bad]} {
		error "bad number \"$bad\" in: $times"
	}

	if {[info tclversion] >= "8.1"} {return [string repeat $text $times]}

	for {set i 1; set return ""} {($i <= $times) && ($times > 0)} {incr i} {
		append return $text
	}; return $return
}


# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
#     information (mc.moretools command):
#       Unlist <argsList> into corresponding [varName]'s.  [varName1] will contain
#       the value of <argsList>'s index of 0, [varName2] will contain the value of
#       <argsList>'s index of 1, and so on.  If no [varNames]'s are given then the
#       <argsList> will be returned in string format, assuming <argsList> is already
#       in list format.  If no [varName]'s are given and <argsList> is in string
#       format already, then <argsList> is returned unchanged.  The number of
#       [varName]'s that are set depend on the llength of <argsList>;  say <argList>
#       has an llength of 3, and you specify 4 [varName]'s, only the first 3 of those
#       [varName]'s will be set.  Say <argList> has an llength of 3 and you specify 2
#       [varName]'s, both [varName]'s are set and the second index of <argList> is
#       forgotten.  If the [varName] is 'args', it will contain a list of <argList>
#       from the list index point it's at to the end.
#       << This was difficult to explain, e-mail me corrections if you wish. >>
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#     examples:
#       % unlist [list "index 0" "index 1"] varName1 varName2
#       2
#       % puts "$varName1, $varName2"
#       index 0, index 1
#
#       % # This states only 2 were indexed, which means that varName3 was never set.
#       % unlist [list "index 0" "index 1"] varName1 varName2 varName3
#       2
#
#       % # Reverse, only the first 2 indexes messed with since there are only 2
#           available varName's to put them into.
#       % unlist [list "index 0" "index 1" "index 2"] varName1 varName2
#       2
#
#       % # Turn a list into a string.
#       % set list [list "index 0" "index 1" "index 2"]
#       {index 0} {index 1} {index 2}
#       % unlist $list
#       index 0 index 1 index 2
#
#       % # Try and turn a list into a string, but it's already a string.
#       % set list "\{index 0 \{index 1\}\{ index 2\}"
#       {index 0 {index 1}{ index 2}
#       % unlist $list
#       {index 0 {index 1}{ index 2}
#
#     credits:
#     returns:
#       - Number of <argsList> index's distributed to [varName], if [varName] is
#         specified.
#       - Convert of <argsList> to string format (nothing changes if already string
#         format), if no [varName]'s are specified.
proc unlist {{args ""}} {
	badargs $args 1 end "argsList ?varName varName ...?"
	set argList [lindex $args 0]
	set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
	set argNames [lrange $args 1 end]
	if {![llength $argNames]} {
		return [expr {(![catch {llength $argList}])?
			[join $argList]:$argList}]
	}
	for {set index 0} {$index < [llength $argNames]} {incr index 1} {
		set argName     [lindex $argNames $index]
		set argListItem [lindex $argList  $index]

		set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
		set setTo   [lindex $argName_ 1]
		set argName [lindex $argName_ 0]

		if {$argName == ""} {continue}

		upvar 1 $argName var

		if {[expr $index+1] > [llength $argList]} {
			if {[llength $argName_] == "2"} {set var $setTo}
		} else {
			if {$argName == "args"} {
				set var [lrange $argList $index end]
				incr index [expr [llength $var]-1]
			} else {set var $argListItem}
		}
	}; return $index
}


# url <option> <text>
#     version:
#       v1.0
#     information (mc.moretools command):
#       This will either encode or decode <text> in HTTP's URL standards of using
#       %<hex> for non a-zA-Z0-9 characters.
#       Valid options are:
#         decode - decode <text>.
#         encode - encode <text>.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#       The 'filter' command from mc.mroetools.
#       The 'replace' command from mc.mroetools.
#     examples:
#       % set query "Test+%21@%23%24%25%5E%26*%28%29_-%2B%3D"
#       Test+%21@%23%24%25%5E%26*%28%29_-%2B%3D
#       % set encode [url encode $query]
#       Test%2B%2521%40%2523%2524%2525%255E%2526%2A%2528%2529%5F%2D%252B%253D
#       % url decode $encode
#       Test+!@#$%^&*()_-+=
#     credits:
#       dw
#     returns:
#       - <text> after (de|en)code`d.
proc url {{args ""}} {
	badargs $args 2 2 "option text"
	unlist $args option text

	switch -- $option {
		decode {
			set text [replace -- $text [list + " " %25 %]]
			set i [string length $text]
			while {([regexp -- {%([0-9][0-9A-F])} $text match hex]) && !($i < 0)} {
				set with [format %c 0x$hex]
				regsub -all -- $match $text [expr {($with == "&"?"\\&":$with)}] text
				incr i -1
			}
		}
		encode {
			set text [replace -- $text [list % %25]]
			set i [string length $text]
			while {[regexp {[^a-zA-Z0-9%]} $text toh] && ($i >= 0 )} {
				scan $toh %c dec
				regsub -all -- [set x [filter -regexp $toh]] $text "%[format %X $dec]" text
				incr i -1
			}
		}
		default {
			error "bad option \"$option\": must be decode, or encode"
		}
	}; return $text
}


# which <executable_file>
#     version:
#       v1.1
#     information (mc.moretools command):
#       Try and locate the path of the given <executable_file>.  This will search
#       through the given environment PATH's.  Same idea as the *nix/bsd 'which'
#       command... just done in TCL to be OS independent.
#     dependencies (other than eggdrop provided commands):
#       The 'badargs' command from mc.moretools.
#       The 'unlist' command from mc.moretools.
#     examples:
#     credits:
#     returns:
#       - Path to the <executable_file>.
proc which {{args ""}} {
	badargs $args 1 1 "executable_file"
	unlist $args file

	global env

	set separator [expr {([info exists env(OS)] &&
		[string match *windows* [string tolower $env(OS)]])?";":":"}]

	foreach path ". [split $env(PATH) $separator]" {
		set long_file [file join $path $file]
		if {[file executable $long_file]} {
			return $long_file
		}
	}; return ""
}

#
##

set mc_moretools(loaded) 1

putlog "More Tools $mc_moretools(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v3.0.2 (9.29.02)
#  MC_8 - KrE80r - Upgraded 'maskhostbytype' tcl command.  Is now compatable with
#                  TCL8.0.  v2.0 -> v2.0.1  (bugzilla # 167)
#
# v3.0.1 (09.13.02)
#  MC_8   -     - Further upgraded 'sendemail' tcl command.  EHLO and HELO wasn't
#                 following standards, was sending the smtp's server domain name
#                 rather than the client's.  v1.2 -> v1.3
#  MC_8   - Wcc - Upgraded the 'sendemail' tcl command to properly support esmtp
#                 servers as well as smtp servers.  v1.2 -> v1.3
#  fudded -     - Fixed some spelling errors.
#  MC_8   -     - Fixed many spelling errors.
#
# v3.0 (07.20.02)
#  MC_8 - - Added the 'unlist' command.  none -> v1.0
#  MC_8 - - Added the 'url' command.  none -> 1.0
#  MC_8 - - Upgraded the 'which' command.  v1.0 -> v1.1
#  MC_8 - - Upgraded the 'str' command.  v1.0 -> v1.1
#  MC_8 - - Upgraded the 'sendemail' command.  v1.1 -> v1.2
#  MC_8 - - Upgraded the 'notice' command.  v1.0 -> v1.1
#  MC_8 - - Upgraded the 'msg' command.  v1.0 -> v1.1
#  MC_8 - - Changed the 'masktype' commands' name to 'maskhostbytype'.  Also upgraded
#           the 'maskhostbytype' command.  v1.3 -> 2.0
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded the 'islinked' command.  v1.0 -> v1.1
#  MC_8 - - Removed the 'gethost' command, use the 'getchanhost' command instead.
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded the 'getchanhost' command.  A restart, as opposed to a rehash,
#           is suggested, but not required, if upgrading this command.  v2.0 -> v2.1
#  MC_8 - - Renamed the 'findnick' command to 'findnicks' since it's dealing with
#           finding more than 1.  Also upgraded the 'findnicks' command. v1.1 -> v2.0
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Changed the 'findhand' command's name to 'findpartyusers' and upgraded
#           the 'findhand' command.  v1.0 -> v2.0
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded the 'findip' command.  v1.1 -> v2.0
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Changed the 'filt' command's name to 'filter' and upgraded the 'filter'
#           command.  v2.1 -> v3.0
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded the 'dccchat' command.  v1.0 -> v1.1
#  MC_8 - - Upgraded the 'ctcp' command.  v1.2 -> v1.3
#  MC_8 - - Upgraded the 'chanint' command.  v3.1 -> v3.2
#  MC_8 - - Upgraded the 'chanflag' command.  v3.0 -> v3.1
#  MC_8 - - Added 'math' command.  none -> v1.0
#             |- Removed the 'lowest' command, use the 'math' command instead.
#             `- Removed the 'biggest' command, use the 'math' command instead.
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded the 'action' command, use the 'ctcp' command instead.
#           v1.0 -> v1.1
#  MC_8 - - Added the 'badargs' command.  none -> v1.0
#  MC_8 - - Removed variables 'moretools' and 'moretools_version', using `version`
#           and `version` within the 'mc_moretools' array instead now.  And for the
#           load checking, use `loaded`.
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Upgraded replace command, added optional switches -nocase, and --.  Also
#           made it case sensitive by default (not -nocase); if you were using TCL
#           8.1 or greater then it would automatically do -nocase.  v1.2 -> v1.3
#  MC_8 - - Added 'mirc_format' command.  none -> v1.0
#             |- Removed the 'bold' command, use the 'mirc_format' command instead.
#             |- Removed the 'color' command, use the 'mirc_format' command instead.
#             |- Removed the 'reverse' command, use the 'mirc_format' command
#             |  instead.
#             |- Removed the 'normal' command, use the 'mirc_format' command instead.
#             `- Removed the 'uline' command, use the 'mirc_format' command instead.
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Added the 'mirc_strip' command.  none -> v1.0
#             |- Removed the 'strip:normal" command, use the 'mirc_strip' command
#             |  instead.
#             |- Removed the 'strip:color" command, use the 'mirc_strip' command
#             |  instead.
#             |- Removed the 'strip:bold" command, use the 'mirc_strip' command
#             |  instead.
#             |- Removed the 'strip:all" command, use the 'mirc_strip' command
#             |  instead.
#             |- Removed the 'strip:reverse" command, use the 'mirc_strip' command
#             |  instead.
#             `- Removed the 'strip:uline" command, use the 'mirc_strip' command
#                instead.
#           *** POTENTIAL INCOMPATIBILITY ***
#  MC_8 - - Cleaned up the 'gethost' command.  v1.1 -> v1.2
#  MC_8 - - Added the 'i18n' command.  none -> v1.0
#  MC_8 - - Added the 'clist2list' command.  none -> v1.0
#  MC_8 - - Added the 'dec2comma' command.  none -> v1.0
#
# v2.4.2 (07.15.02)
#  MC_8 - Wcc - Upgraded 'strip:all' command to support TCL 8.0.  v1.1 -> v1.2
#  MC_8 - Wcc - Upgraded 'strip:bold' command to support TCL 8.0.  v1.0 -> v1.1
#  MC_8 - Wcc - Upgraded 'strip:color' command to support TCL 8.0.  v1.0 -> v1.1
#  MC_8 - Wcc - Upgraded 'strip:uline' command to support TCL 8.0.  v1.0 -> v1.1
#  MC_8 - Wcc - Upgraded 'strip:normal' command to support TCL 8.0.  v1.0 -> v1.1
#  MC_8 - Wcc - Upgraded 'strip:reverse' command to support TCL 8.0.  v1.0 -> v1.1
#
# v2.4.1 (07.05.02)
#  MC_8 - Paladin - Upgraded 'replace' to support TCL 8.0, also changed some code
#                   around to make it more efficient.  v1.1 -> v1.2
#  MC_8 - Paladin - Upgraded 'filt' to support TCL 8.0.  v2.0 -> v2.1
#  MC_8 - Paladin - Updated 'chanint' to work with TCL 8.0.  v3.0 -> v3.1
#
# v2.4 (07.03.02)
#  MC_8 - - Moved history to the bottom, too long.
#  MC_8 - - Upgraded chanflag to utilize 'channel get' if available.  'channel get'
#           was introduced in eggdrop 1.6.11.  v2.1 -> v3.0
#  MC_8 - - Upgraded chanint to utilize 'channel get' if available.  'channel get'
#           was introduced in eggdrop 1.6.11.  v2.0 -> v3.0
#
# v2.3 (07.02.02)
#  MC_8 - - Cleaned up some bs from the 'sendemail' command.
#             1) Chagned the _puts command from sendmail to sendemail.
#             2) Forgot a '$sid' in a 'puts', therefor it was putting the body as the
#                header (no blank line dividing them).
#  MC_8 - - Added the [-wait] option to the 'sendemail' command, makes it non async
#           and waits for the e-mail to send.  This is useful if your using it in
#           CGI.  v1.0 -> v1.1
#
# v2.2 (07.01.02)
#  MC_8 - - Added 'sendemail' command.  v1.0
#
# v2.1.1 (06.18.02)
#  MC_8 -        - Fixed conversion of string->list format for channel variable
#                  within the gethost command.  v1.0 -> v1.1
#  MC_8 -        - Fixed conversion of string->list format for channel variable
#                  within the getchanhost command.  old -> v2.0
#  MC_8 -        - Fixed conversion of string->list format for channel variable
#                  within the findnick command.  v1.0 -> v1.1
#  MC_8 -        - Fixed 'can't read "string": no such variable' within findip
#                  command.  v1.0 -> v1.1
#  MC_8 -        - Fixed string->list format error in ctcp command.  v1.1 -> v1.2
#  MC_8 - Jürgen - Upgraded masktype command, was giving error 'couldn't set
#                  variable "temp"'.  v1.2 -> v1.3
#
# v2.1 (04.24.02)
#  MC_8 - - Added 'dccchat' and 'normal' command.  none -> v1.0
#  MC_8 - - Upgraded 'chanflag' proc, defaults to 0 rather than the other way
#           around.  v2.0 -> v2.1
#  MC_8 - - Upgraded 'masktype' proc, fixed some minor errors.
#             o If ident@host == test@me@192.168.0.1, it would set ident to
#               'test' and host to 'me@192.168.0.1'.
#             o Types *1,3,6,8 is support to remove the ident's first ~.  It was
#               removing all continues (from left) ~'s.
#             o A little more efficient, by caching some commands.
#           v1.1 -> v1.2
#  MC_8 - - Added the 'normal' character code to 'strip:all' proc.  v1.0 -> v1.1
#  MC_8 - - Added the 'strip:normal' proc.  -> v1.0
#
# v2.0.2 (03.17.02)
#  MC_8 - - Fixed error in masktype proc; if type is 10-19 and the host is an ip
#           and it has a 255 in any of the 4 atoms- it would be treated as a
#           host rather than an ip.  v1.0 -> v1.1
#  MC_8 - - Fixed listing error in 'ctcp' proc. v1.0 -> v1.1
#  MC_8 - - Re coded the action fix filter proc's.
#  MC_8 - - Upgraded chanflag proc to v2.0, faster.
#  MC_8 - - Upgraded 'chanint' proc to v2.0, faster.
#  MC_8 - - Fixed 'couldn't compile regular expression pattern' problem with
#           replace proc.
#  MC_8 - - Fixed set x bug in color proc.
#
# v2.0.1 (11.11.01)
#  MC_8 - - Fixed 'missing close-brace' startup crash error for the 'findnick'
#           proc.
#  MC_8 - - 'replace' will not try and utilize string map, if error (older
#           version of tcl don't support it), it will go with the home grown
#           procedure.
#
# v2.0 (11.05.01)
#  MC_8 - - Rewrote all proc's.  If you used this script previously, please
#           re-review the proc's you use for some have changed it's output
#           format... and some have been removed (other proc's take there
#           place).
#
# v1.3.1 (08.31.01)
#  MC_8 - - Fixed special character handling of botnet action fix.
#
# v1.3 (02.01.01)
#  MC_8 - - Fixed casing problem with findchanuser procedure.
#  MC_8 - - Added 'chanflagison'.
#
# v1.2 (08.14.00)
#  MC_8    - - Found a little problem with 'maskhost' proc.  If you specified
#              ident@host it would return !@.
#  FireEgl - - Added which proc.
#  MC_8    - - Added 'gethost' proc.
#  MC_8    - - Changed 'dnslookup' to resolve, 1.5.3 and up carry there own
#              dnslookup proc.
#
# v1.1.9 (04.05.00)
#  MC_8 - - Fixed maskhost a bit, the server was doing it's own strange masking
#           to long ident's and hosts.  Only effects things above the numbers of
#           <nick>!9@36.  Undernet does the masking to it ok, but EfNet just
#           fucks it to hell, making something like bla.bla.com into *bla.bl to
#           get it to fit (cutting off the wrong side). ANYHOW, it is fixed.
#  MC_8 - - Fixed special character return bug proc 'findchanuser'.
#
# v1.1.8 (11-23-99) -not published yet
#  MC_8 - ZARPO - Eggdrop1.4.0+ has removed it's own internal time proc and let
#                 TCL take over on time call's.  This is evidently going to
#                 create errors with old scripts.  I simply rewrote it back to
#                 the way it use to be when eggdrop1.3.28- took control.  And
#                 no, will not conflict on higher/ lower bot versions!
#  MC_8 -       - Added on source putlog responses on everything the bot catches
#                 and re-proc's.  (I like to know what the scripts are
#                 changing.)
#  MC_8 -       - Added the latest action.fix tcl code.
#
# v1.1.7 (10-30-99)
#  MC_8 - VaultX - Eggdrop1.3.29+RC2 for some reason did not have the date proc,
#                  on source now tests to see if the date proc is there and
#                  doesn't contain errors.  If needed moretools re-wrights the
#                  proc date.
#  MC_8 -        - Made realtime non reliant on alltools.
#
# v1.1.6 (10-20-99)
#  MC_8 - m8s - 'masktype' proc wasn't masking correctly.
#  MC_8 -     - Added masktype's 10-19.
#  MC_8 -     - Made testip non dependent on alltools script (found alltools
#               error).
#
# v1.1.5 (10-12-99)
#  MC_8 - - Added 'finduserchan'.
#  MC_8 - - Modified lremove to work better.
#  MC_8 - - Fixed returns of []'d characters not to return as {[]'d}.
#  MC_8 - - Adjusted replace and lremove.
#
# v1.1.4 (10-09-99)
#  MC_8 - - Added 'findchanuser', 'masktype' and 'replace'.
#
# v1.1.3 (09-28-99)
#  MC_8 - - Added 'str'.
#  MC_8 - - Cleaned up the definition section for the proc's.
#  MC_8 - - Fixed a typo in the 'ctcp' proc.
#
# v1.1.2 (08-08-99)
#  MC_8 - - Fixed some bugs on the 'findip' proc.
#
# v1.1.1
#  MC_8 - - Added 'notice', 'msg', 'ctcp', 'bold', 'uline', 'reverse' and
#           'color'.
#
# v1.1.0
#  MC_8 - - Added 'isparty' and 'islink'.
#
# v1.0.1
#  MC_8 - - Changed return output for 'dnslookup'.
#
# v1.0
#  MC_8 - - Initial Release.
##
