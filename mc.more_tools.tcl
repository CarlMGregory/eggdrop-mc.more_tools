##
# More Tools v2.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#
# My SVS Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This is not a "cool" script, it's a tools script for other
# scriptures to use and/ or learn with.
##

##
# History
##
# v2.1 (04.24.02)
#  MC_8 - Added 'dccchat' and 'normal' command.
#  MC_8 - Upgraded 'chanflag' proc, defaults to 0 rather than the other way
#         around.  v2.0 -> v2.1
#  MC_8 - Upgraded 'masktype' proc, fixed some minor errors.
#          o If ident@host == test@me@192.168.0.1, it would set ident to 'test'
#            and host to 'me@192.168.0.1'.
#          o Types *1,3,6,8 is support to remove the ident's first ~.  It was
#            removing all continues (from left) ~'s.
#          o A little more efficient, by caching some commands.
#         v1.1 -> v1.2
#  MC_8 - Added the 'normal' character code to 'strip:all' proc.  v1.0 -> v1.1
#  MC_8 - Added the 'strip:normal' proc.  -> v1.0
#
# v2.0.2 (03.17.02)
#  MC_8 - Fixed error in masktype proc; if type is 10-19 and the host is an ip
#         and it has a 255 in any of the 4 atoms- it would be treated as a host
#         rather than an ip.  v1.0 -> v1.1
#  MC_8 - Fixed listing error in 'ctcp' proc. v1.0 -> v1.1
#  MC_8 - Re coded the action fix filter proc's.
#  MC_8 - Upgraded chanflag proc to v2.0, faster.
#  MC_8 - Upgraded 'chanint' proc to v2.0, faster.
#  MC_8 - Fixed 'couldn't compile regular expression pattern' problem with
#         replace proc.
#  MC_8 - Fixed set x bug in color proc.
#
# v2.0.1 (11.11.01)
#  MC_8 - Fixed 'missing close-brace' startup crash error for the 'findnick' proc.
#  MC_8 - 'replace' will not try and utilize string map, if error (older version of
#         tcl don't support it), it will go with the home grown procedure.
#
# v2.0 (11.05.01)
#  MC_8 - Rewrote all proc's.  If you used this script previously, please
#         re-review the proc's you use for some have changed it's output
#         format... and some have been removed (other proc's take there place).
#
# v1.3.1 (08.31.01)
#  MC_8 - Fixed special character handling of botnet action fix.
#
# v1.3 (02.01.01)
#  MC_8 - Fixed casing problem with findchanuser procedure.
#  MC_8 - Added 'chanflagison'.
#
# v1.2 (08.14.00)
#  MC_8    - Found a little problem with 'maskhost' proc.  If you specified
#            ident@host it would return !@.
#  FireEgl - Added which proc.
#  MC_8    - Added 'gethost' proc.
#  MC_8    - Changed 'dnslookup' to resolve, 1.5.3 and up carry there own dnslookup #            proc.
#
# v1.1.9 (04.05.00)
#  MC_8 - Fixed maskhost a bit, the server was doing it's own strange masking to #         long ident's and hosts.  Only effects things above the numbers of
#         <nick>!9@36.  Undernet does the masking to it ok, but EfNet just fucks
#         it to hell, making something like bla.bla.com into *bla.bl to get it
#         to fit (cutting off the wrong side). ANYHOW, it is fixed.
#  MC_8 - Fixed special character return bug proc 'findchanuser'.
#
# v1.1.8 (11-23-99) -not published yet
#  MC_8 - ZARPO - Eggdrop1.4.0+ has removed it's own internal time proc and let
#                 TCL take over on time call's.  This is evidently going to
#                 create errors with old scripts.  I simply rewrote it back to
#                 the way it use to be when eggdrop1.3.28- took control.  And
#                 no, will not conflict on higher/ lower bot versions!
#  MC_8 -       - Added on source putlog responses on everything the bot catches
#                 and re-proc's.  (I like to know what the scripts are changing.)
#  MC_8 -       - Added the latest action.fix tcl code.
#
# v1.1.7 (10-30-99)
#  MC_8 - VaultX - Eggdrop1.3.29+RC2 for some reason did not have the date proc, #                  on source now tests to see if the date proc is there and
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
#  MC_8 - Added 'finduserchan'.
#  MC_8 - Modified lremove to work better.
#  MC_8 - Fixed returns of []'d characters not to return as {[]'d}.
#  MC_8 - Adjusted replace and lremove.
#
# v1.1.4 (10-09-99)
#  MC_8 - Added 'findchanuser', 'masktype' and 'replace'.
#
# v1.1.3 (09-28-99)
#  MC_8 - Added 'str'.
#  MC_8 - Cleaned up the definition section for the proc's.
#  MC_8 - Fixed a typo in the 'ctcp' proc.
#
# v1.1.2 (08-08-99)
#  MC_8 - Fixed some bugs on the 'findip' proc.
#
# v1.1.1
#  MC_8 - Added 'notice', 'msg', 'ctcp', 'bold', 'uline', 'reverse' and 'color'.
#
# v1.1.0
#  MC_8 - Added 'isparty' and 'islink'.
#
# v1.0.1
#  MC_8 - Changed return output for 'dnslookup'.
#
# v1.0
#  MC_8 - Initial Release
##

##
# Procedures:
##
# Scriptures, to test if this script is loaded variable $moretools will be set to # moretools current version number.
# <major version><minor version><bug fix level> ((010000) <- version 1.0.0)

#
# action <nick/#channel> <text>
#     Sends an action.
#     return: nothing

#
# biggest <numbers>
#     returns: the number of greatest value

#v1.0
# bold [text]
#     Puts the bold character around [text] (optional). If
#     [text] isn't specified, a lone bold character will be
#     returned.
#     returns: mIRC compliant bold

#
# chanflag <channel> <flag>
#     Tests to see if the channel flag is turned on or off.
#     return: 1 if flag is on, 0 otherwise.

#
# chanint <channel> <int>
#     This is like chanflag, but gives the value of an
#     integer channel set instead of a flag channel set.
#     returns:  integer's value setting
#              -1 if invalid integer setting

#
# color [foreground[,background] [text]]
#     Puts the color character (with foreground[,background] numbers)
#     around [text] (optional). If [text] is not specified, a lone
#     color character will be returned.
#     foreground and background numbers are:
#      0 white      6 purple      12 light blue
#      1 black      7 orange      13 pink
#      2 blue       8 yellow      14 grey
#      3 green      9 light green  15 light grey
#      4 light red  10 cyan
#      5 brown     11 light cyan
#
#     returns: mIRC compliant color

#
# ctcp <nick/#channel> <text/ ping>
#     Sends a ctcp <text/ ping> to nick or #channel.
#     If it's a ping, the proc will automatically
#     append the clock seconds to it.
#     returns: nothing

# v1.0
# dccchat <nick>
#     Initiates a DCC Chat with <nick>.
#     returns: 0 = No telnet ports setup.
#             1 = success

#
# filt <text>
#     Adds \ 's to {}[]" 's that are in the <text>.
#     returns: <text> after adding \'s to special characters

#
# findip <text>
#     Searches for logical ip address' within the <text>.
#     return: a list of IP's found

#
# findhand <hostmask>
#     Finds handles on the party line.  <hostmask> can
#     contain wild cards.
#     returns: list of handles found; each entry in the
#       list contains hostmask, the bot (s)he's on

#
# findnick <hostmask> [channel]
#     Searches [channel] to find nicks that match <hostmask>.
#     Wild cards are accepted in <hostmask>.  If channel isn't
#     specified, it will search all channels the bot is in.
#     returns: list of nick's found; each entry in the list
#       contains IRC Nickname, channel

#
# getchanhost <nick> [channel]
#     Finds the uhost of <nick>.  getchanhost is part of eggdrop, but
#     older bot's that use it have [channel] as a <> and not [].
#     This proc is good for fixing this error (occurs with old bots
#     and new scripts): TCL error: wrong # args: should be "getchanhost
#     nickname channel"
#     return: ident@host

#
# islinked <bot>
#     returns: "1" if the bot is currently linked, "0" otherwise

#
# lowest <numbers>
#     returns: the number of smallest value

#
# masktype <hostmask> [type]
#     Masks <hostmask> to one of the many masking types.
#     Here are the types:
#     Default == 5
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks
#     0 to 9.  But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of
#                  the host.domain, it replaces the numbers in the
#                  host.domain with a '?' (question mark) wildcard
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
#     returns: mask'd host

#
# msg <nick/#channel> <text>
#     Sends a message.
#     return: nothing

#v1.0
# normal [text]
#     Puts the normal mIRC compliant character around [text]. If [text] is not
#     specified, a loned bold character will be returned.
#     returns: mIRC compliant normal

#
# notice <nick/#channel> <text>
#     Sends a notice.
#     returns: nothing

#
# replace <text> <substring newstring [substring newstring ...]>
#     Replaces any occurrence of substring in <text> with newstring.
#       example: replace abcdefg "cd xyz"  => abxyzefg
#     You can also specify multiple replace parameters.
#       example: replace abcdefg "a A b B c C d D"  => ABCDefg
#       example: replace abcdefg "d { the middle }"  => abc the middle efg
#
#     NOTE:
#       substring and newstring goes in list format.
#
#       Replacement works from left to right.
#
#      returns: <text> after all substrings were replaced with newstrings

#
# reverse [text]
#     Puts the reverse character around [text] (optional). If
#     [text] isn't specified, a loned reverse character will
#     be returned.
#     returns: mIRC compliant reverse

#
# str <text> <times>
#     example: str "ho " 3 => ho ho ho
#     returns: <string> repeated <times> times

#
# strip:all <text>
#     Strips mIRC compliant color, underline, reverse, normal
#     and bold from the <text>.
#     returns: <text> after striped

#
# strip:bold <text>
#     Strips mIRC compliant bold characters from <text>.
#     returns: <text> after striped

#
# strip:color <text>
#     Strip mIRC compliant color from <text>.
#     returns: <text> after striped

#
# strip:normal <text>
#     Strips mIRC compliant normal characters from <text>.
#     returns: <text> after striped

#
# strip:reverse <text>
#     Strips mIRC compliant reverse characters from <text>.
#     returns: <text> after striped

#
# strip:uline <text>
#     Strips mIRC compliant underline characters from <text>.
#     returns: <text> after striped

#
# uline [text]
#     Puts the underline character around [text] (optional). If
#     [text] isn't specified, a loned reverse character will
#     be returned.
#     returns: mIRC compliant underline

#
# which <executable_file>
#     Finds the location of a executable file.
#     returns: path/executable_file



#### Procedure coding

# v1.0
proc action {to text} {puthelp "PRIVMSG $to :\001ACTION $text\001"}

# v1.0
proc biggest {numbers} {return [lindex [lsort -integer $numbers] end]}

# v1.0
proc bold {{arg ""}} {if {$arg != ""} {append arg \002};return \002$arg}

# v2.1
proc chanflag {channel flag} {
 if {[lsearch -exact [string tolower [channel info $channel]] +[string tolower $flag]] >= "0"} {return 1}
 return 0
}

# v2.0
proc chanint {channel int} {
 set cache(chaninfo) [string tolower [channel info $channel]]
 regsub -all -- {([\\\{\}\[\]\"])} [string tolower $int] {\\\1} int
 if {[set temp(i) [lsearch -glob $cache(chaninfo) "$int *"]] == "-1"} {return -1}
 return [lindex [split [lindex $cache(chaninfo) $temp(i)] " "] 1]
}

# v1.1
proc color {{num {}} {text {}}} {
 if {$text == ""} {set x $num} else {
  if {$num == ""} {
   return -code error "wrong # args: should be \"color [forground[,background] [text]]\""
  } elseif {![regexp {^([0-9][0-9]?(,[0-9][0-9]?)?)?$} $num]} {
   return -code error "couldn't formulate colored string: invalid color number format, should be ff\[,bb\]"
  }; set x $num$text\003
 }; return \003$x
}

# v1.1
proc ctcp {to arg} {
 set arg "[string toupper [lindex [split $arg] 0]] [join [lrange [split $arg] 1 end]]"
 if {([lindex $arg 0] == "PING") && ([lindex $arg 1] == "")} {set arg "PING [clock seconds]"}
 puthelp "PRIVMSG $to :\001$arg\001"
}

# v1.0
proc dccchat {nick} {
 foreach d [dcclist TELNET] {
  set hand [lindex $d 1]
  if {($hand != "(users)") && ($hand != "(telnet)")} {continue}
  puthelp "PRIVMSG $nick :\001DCC CHAT chat [myip] [lindex [lindex $d 4] 1]\001"
  return 1
 }; return 0
}

# v2.0
proc filt {text} {
	regsub -all -- {([\\\{\}\[\]\"])} $text {\\\1} text; return $text
}

# v1.0
proc findip {arg} {
 set ips ""
 while {[regexp -- {([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)} $arg temp a b c d]} {
  if {$a > 0 && $a < 256 && $b < 256 && $c < 256 && $d < 256} {lappend ips $a.$b.$c.$d}
  set string [string range $string [expr [string first $a.$b.$c.$d $string]+1] end]
 }; return $ips
}

# v1.0
proc findhand {hostmask} {
 set list ""
 foreach user [whom *] {
  set uhost [format %s!%s [lindex $user 0] [lindex $user 2]]
  if {![string match [string tolower $hostmask] $uhost]} {continue}
  lappend list [list $uhost [lindex $user 1]]
 }; return $list
}

# v1.0
proc findnick {hostmask {channel ""}} {
 if {![validchan $channel]} {
  if {$channel != ""} {return -code error "no such channel record"} \
  else {set channel [channels]}
 }; set buffer "" ; set hostmask [string tolower $hostmask]
 foreach chan $channel {
  foreach user [chanlist $chan] {
   if {[string match $hostmask [string tolower $user![getchanhost $user $chan]]]} {
    lappend buffer [list $user $chan]
   }
  }
 }; return $buffer
}

# Pre 1.4.2 bots do not support getchanhost with as channel optional.
# This is a simple fix to make channel optional.
if {[catch {getchanhost -test}]} {
 if {[info commands mc:fix:v1:getchanhost] == ""} {rename getchanhost mc:fix:v1:getchanhost}
 proc getchanhost {nick {channel ""}} {
  if {![validchan $channel]} {
   if {$channel != ""} {return -code error "no such channel record"} \
   else {set channel [channels]}
  }
  foreach chan $channel {if {[onchan $nick $chan]} {return [mc:fix:v1:getchanhost $nick $chan]}}
  return ""
 }; putlog "More Tools:  Old TCL command 'getchanhost' found, fixing."
}

# v1.0
proc gethost {nick {channel ""}} {
 if {![catch {set return [getchanhost $nick]}]} {return $return}
 if {![validchan $channel]} {
  if {$channel != ""} {return -code error "no such channel record"} \
  else {set channel [channels]}
 }
 foreach chan $channel {if {[onchan $nick $chan]} {return [getchanhost $nick $chan]}}
 return ""
}

# Pre 1.4.2 bots do not support the islinked tcl command.  This will add it
# if not avilable.
if {[catch {islinked -test}]} {
 proc islinked {bot} {
  if {[lsearch -exact [string tolower [bots]] [string tolower $bot]] == "-1"} {return 0}
  return 1
 }; putlog "More Tools:  TCL command 'islinked' not found, fixing."
}

# v1.0
proc lowest {numbers} {return [lindex [lsort -integer $numbers] 0]}

# v1.2
proc masktype {nuhost type} {
 set ident_max-length 9
 set host_max-length 63
 scan $nuhost {%[^!]!%s} nick uhost
 set temp(split_uhost) [split $uhost @]
 set ident [join [lrange $temp(split_uhost) 0 [expr [llength $temp(split_uhost)]-2]] @]
 set host [lindex $temp(split_uhost) end]
 set maskhost 1
 if {[regexp -- {^1[0-9]$} $type]} {
  set temp(w) {([0-9][0-9]?[0-9]?)}
  set temp(x) "^$temp(w)\\.$temp(w)\\.$temp(w)\\.$temp(w)\$"
  if {!(([regexp -- $temp(x) $host temp a b c d]) &&
       ($a > 0 && $a <= 255 && $b <= 255 && $c <= 255 && $d <= 255))} {
   regsub -all -- {[0-9]} $host ? host
   set maskhost 0
  }; set type [string index $type 1]
 }
 if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
 if {[regexp -- {^[2479]$} $type]} {set ident "*"}
 if {[regexp -- {^[1368]$} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
 if {[regexp -- {^[3489]$} $type]} {
  if {$maskhost} {set host [lindex [split [maskhost $host] @] end]}
 }
 if {[set cache(x) [string length $ident]] > ${ident_max-length}} {
  set ident "*[string range $ident [expr $cache(x)-${ident_max-length}] end]"
 }
 if {[set cache(x) [string length $host]] > ${host_max-length}} {
  set host "*[string range $host [expr $cache(x)-${host_max-length}] end]"
 }; return [format "%s!%s@%s" $nick $ident $host]
}

# v1.0
proc msg {to text} {puthelp "PRIVMSG $to :$text"}

# v1.0
proc normal {{arg ""}} {if {$arg != ""} {append arg \017};return \017$arg}

# v1.0
proc notice {to text} {puthelp "NOTICE $to :$text"}

# v1.1
proc replace {text subs} {
 if {![catch {string map -nocase $subs $text} output]} {return $output}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])} [lindex $subs $i] {\\\1} temp(temp)
  regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
 }; return $text
}

# v1.0
proc reverse {{arg {}}} {if {$arg != ""} {append arg \026};return \026$arg}

# v1.0
proc str {text times} {
 if {![catch {string repeat $text $times} output]} {return $output}
 for {set i 1; set return ""} {($i <= $times) && ($times > 0)} {incr i} {append return $text}
 return $return
}

# v1.1
proc strip:all {text} {
 regsub -all -- {\002} $text "" text ;#bold
 regsub -all -- {\003([0-9][0-9]?(,[0-9][0-9]?)?)?} $text "" text ;#color
 regsub -all -- {\017} $text "" text ;#normal
 regsub -all -- {\026} $text "" text ;#reverse
 regsub -all -- {\037} $text "" text ;#underline
 return $text
}

# v1.0
proc strip:bold {text} {regsub -all -- {\002} $text "" text; return $text}

# v1.0
proc strip:color {text} {
 regsub -all -- {\003([0-9][0-9]?(,[0-9][0-9]?)?)?} $text "" text
 return $text
}

# v1.0
proc strip:normal {text} {regsub -all -- {\017} $text "" text; return $text}

# v1.0
proc strip:reverse {text} {regsub -all -- {\026} $text "" text; return $text}

# v1.0
proc strip:uline {text} {regsub -all -- {\037} $text "" text; return $text}

# v1.0
proc uline {{arg {}}} {if {$arg != ""} {append arg \037};return \037$arg}

# v1.0
proc which {exec} {
 if {![catch {exec which $exec} output]} {return $output}
 global env
 if {[info exists env(OS)] && [string match *windows* [string tolower $env(OS)]]} {set temp ";"} else {set temp ":"}
 foreach path [split $env(PATH) $temp] {if {[file executable "$path/$exec"]} {return "$path/$exec"}}; return ""
}

# Yea yea, if {1}, no real meaning... just trying to keep it grouped together for easy reading.
# This does the action fixes for dcc chat and telnet partyline communications.
if {1} {
 bind filt - "\001ACTION *\001" filt_act
 proc filt_act {idx text} {
  set temp [join [lrange [split $text] 1 end]]
  regexp -- "^(.*)\001?\$" $temp dummy temp
  return ".me $temp"
 }
 bind filt - "/me *" filt_telnet_act
 bind filt - "/action *" filt_telnet_act
 proc filt_telnet_act {idx text} {return ".me [join [lrange [split $text " "] 1 end] " "]"}
 putlog "More Tools:  Partyline action-fix applied."
}

set moretools_version v2.1
set moretools "020100"
putlog "More Tools $moretools_version by MC_8 loaded."
