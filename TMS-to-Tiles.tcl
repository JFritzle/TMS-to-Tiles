# Download and compose TMS server tiles
# =====================================

# Important:
# - Only new "tasks" server type supported!
# - At least Java version 11 required!

# Notes:
# - Additional user settings file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by "ini"
# - At least one additional localized resource file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by
#   2 lowercase letters ISO 639-1 code, e.g. "en"

# Force file encoding "utf-8"
# Usually required for Tcl/Tk version < 9.0 on Windows!

if {[encoding system] != "utf-8"} {
   encoding system utf-8
   exit [source $argv0]
}

if {![info exists tk_version]} {package require Tk}
wm withdraw .

set version "2025-03-05"
set script [file normalize [info script]]
set title [file tail $script]
set cwd [pwd]

# Required packages

foreach item {Thread msgcat tooltip http uri fileutil} {
  if {[catch "package require $item"]} {
    ::tk::MessageBox -title $title -icon error \
	-message "Could not load required Tcl package '$item'" \
	-detail "Please install missing $tcl_platform(os) package!"
    exit
  }
}

# Procedure aliases

interp alias {} ::send {} ::thread::send
interp alias {} ::mc {} ::msgcat::mc
interp alias {} ::messagebox {} ::tk::MessageBox
interp alias {} ::tooltip {} ::tooltip::tooltip
interp alias {} ::filetype {} ::fileutil::fileType
interp alias {} ::style {} ::ttk::style
interp alias {} ::button {} ::ttk::button
interp alias {} ::checkbutton {} ::ttk::checkbutton
interp alias {} ::combobox {} ::ttk::combobox
interp alias {} ::radiobutton {} ::ttk::radiobutton
interp alias {} ::scrollbar {} ::ttk::scrollbar

# Define color palette

foreach {item value} {
Background #f0f0f0
ButtonHighlight #ffffff
Border #a0a0a0
ButtonText #000000
DisabledText #6d6d6d
Focus #e0e0e0
Highlight #0078d7
HighlightText #ffffff
InfoBackground #ffffe1
InfoText #000000
Trough #c8c8c8
Window #ffffff
WindowFrame #646464
WindowText #000000
} {set color$item $value}

# Global widget options

foreach {item value} {
background Background
foreground ButtonText
activeBackground Background
activeForeground ButtonText
disabledBackground Background
disabledForeground DisabledText
highlightBackground Background
highlightColor WindowFrame
readonlyBackground Background
selectBackground Highlight
selectForeground HighlightText
selectColor Window
troughColor Trough
Entry.background Window
Entry.foreground WindowText
Entry.insertBackground WindowText
Entry.highlightColor WindowFrame
Listbox.background Window
Listbox.highlightColor WindowFrame
Tooltip*Label.background InfoBackground
Tooltip*Label.foreground InfoText
} {option add *$item [set color$value]}

set dialog.wrapLength [expr [winfo screenwidth .]/2]
foreach {item value} {
Dialog.msg.wrapLength ${dialog.wrapLength}
Dialog.dtl.wrapLength ${dialog.wrapLength}
Dialog.msg.font TkDefaultFont
Dialog.dtl.font TkDefaultFont
Entry.highlightThickness 1
Label.borderWidth 1
Label.padX 0
Label.padY 0
Labelframe.borderWidth 0
Scale.highlightThickness 1
Scale.showValue 0
Scale.takeFocus 1
Tooltip*Label.padX 2
Tooltip*Label.padY 2
} {eval option add *$item $value}

# Global ttk widget options

style theme use clam

if {$tcl_version > 8.6} {
  if {$tcl_platform(os) == "Windows NT"} \
	{lassign {23 41 101 69 120} ry ul ll cy ht}
  if {$tcl_platform(os) == "Linux"} \
	{lassign { 3 21  81 49 100} ry ul ll cy ht}
  set CheckOff "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	"
  set CheckOn "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	<path d='M20 $ll L80 $ul M20 $ul L80 $ll'
	style='fill:none;stroke:black;stroke-width:14;stroke-linecap:round'/>
	"
  set RadioOff "
	<circle cx='49' cy='$cy' r='47'
	fill='white' stroke='black' stroke-width='3'/>
	"
  set RadioOn "
	<circle cx='49' cy='$cy' r='37'
	fill='black' stroke='white' stroke-width='20'/>
	<circle cx='49' cy='$cy' r='47'
	fill='none' stroke='black' stroke-width='3'/>
	"
  foreach item {CheckOff CheckOn RadioOff RadioOn} \
    {image create photo $item \
	-data "<svg width='125' height='$ht'>[set $item]</svg>"}

  foreach item {Check Radio} {
    style element create ${item}button.sindicator image \
	[list ${item}Off selected ${item}On]
    style layout T${item}button \
	[regsub indicator [style layout T${item}button] sindicator]
  }
}

if {$tcl_platform(os) == "Windows NT"}	{lassign {1 1} yb yc}
if {$tcl_platform(os) == "Linux"}	{lassign {0 2} yb yc}
foreach {item option value} {
. background $colorBackground
. bordercolor $colorBorder
. focuscolor $colorFocus
. darkcolor $colorWindowFrame
. lightcolor $colorWindow
. troughcolor $colorTrough
. selectbackground $colorHighlight
. selectforeground $colorHighlightText
TButton borderwidth 2
TButton padding "{0 -2 0 $yb}"
TCombobox arrowsize 15
TCombobox padding 0
TCheckbutton padding "{0 $yc}"
TRadiobutton padding "{0 $yc}"
} {eval style configure $item -$option [eval set . \"$value\"]}

foreach {item option value} {
TButton darkcolor {pressed $colorWindow}
TButton lightcolor {pressed $colorWindowFrame}
TButton background {focus $colorFocus pressed $colorFocus}
TCombobox background {focus $colorFocus pressed $colorFocus}
TCombobox bordercolor {focus $colorWindowFrame}
TCombobox selectbackground {!focus $colorWindow}
TCombobox selectforeground {!focus $colorWindowText}
TCheckbutton background {focus $colorFocus}
TRadiobutton background {focus $colorFocus}
Arrow.TButton bordercolor {focus $colorWindowFrame}
} {style map $item -$option [eval list {*}$value]}

# Global widget bindings

foreach item {TButton TCheckbutton TRadiobutton} \
	{bind $item <Return> {%W invoke}}
bind TCombobox <Return> {event generate %W <Button-1>}

bind Entry <FocusIn> {grab %W}
bind Entry <Tab> {grab release %W}
bind Entry <Button-1> {+button-1-press %W %X %Y}

proc scale_updown {w d} {$w set [expr [$w get]+$d*[$w cget -resolution]]}
bind Scale <MouseWheel> {scale_updown %W [expr %D>0?+1:-1]}
bind Scale <Button-4> {scale_updown %W -1}
bind Scale <Button-5> {scale_updown %W +1}
bind Scale <Button-1> {+focus %W}

proc button-1-press {W X Y} {
  set w [winfo containing $X $Y]
  if {"$w" == "$W"} {focus $W; return}
  grab release $W
  if {"$w" == ""} return
  focus $w
  switch [winfo class $w] {
    TCheckbutton -
    TRadiobutton -
    TButton	{$w instate !disabled {$w invoke}}
    TCombobox	{$w instate !disabled {ttk::combobox::Press "" $w \
		[expr $X-[winfo rootx $w]] [expr $Y-[winfo rooty $w]]}}
  }
}

# Bitmap arrow down

image create bitmap ArrowDown -data {
  #define x_width 9
  #define x_height 7
  static char x_bits[] = {
  0x00,0xfe,0x00,0xfe,0xff,0xff,0xfe,0xfe,0x7c,0xfe,0x38,0xfe,0x10,0xfe
  };
}

# Try using system locale for script
# If corresponding localized file does not exist, try locale "en" (English)
# Localized filename = script's filename where file extension "tcl"
# is replaced by 2 lowercase letters ISO 639-1 code

set locale [regsub {(.*)[-_]+(.*)} [::msgcat::mclocale] {\1}]
if {$locale == "c"} {set locale en}

set prefix [file rootname $script]

set list [list $locale en]
foreach item [glob -nocomplain -tails -path $prefix. -type f ??] \
	{lappend list [lindex [split $item .] end]}

unset locale
foreach item $list {
  set file $prefix.$item
  if {![file exists $file]} continue
  if {[catch {source $file} result]} {
    messagebox -title $title -icon error \
	-message "Error reading locale file '[file tail $file]':\n$result"
    exit
  }
  set locale $item
  ::msgcat::mclocale $locale
  break
}
if {![info exists locale]} {
  messagebox -title $title -icon error \
	-message "No locale file '[file tail $file]' found"
  exit
}

# Read user settings from file
# Filename = script's filename where file extension "tcl" is replaced by "ini"

set file [file rootname $script].ini
if {![file exist $file]} {
  messagebox -title $title -icon error \
	-message "[mc i01 [file tail $file]]"
  exit
} elseif {[catch {source $file} result]} {
  messagebox -title $title -icon error \
	-message "[mc i00 [file tail $file]]:\n$result"
  exit
}

# Process user settings:
# replace commands resolved by current search path
# replace relative paths by absolute paths

# - commands
set cmds {java_cmd curl_cmd gm_cmd magick_cmd}
# - commands + folders + files
set list [concat $cmds ini_folder server_jar]

set drive [regsub {((^.:)|(^//[^/]*)||(?:))(?:.*$)} $cwd {\1}]
if {$tcl_platform(os) == "Windows NT"}	{cd $env(SystemDrive)/}
if {$tcl_platform(os) == "Linux"}	{cd /}

foreach item $list {
  if {![info exists $item]} continue
  set value [set $item]
  if {$value == ""} continue
  if {$tcl_version >= 9.0} {set value [file tildeexpand $value]}
  if {$item in $cmds} {
    set exec [auto_execok $value]
    if {$exec == ""} {
      messagebox -title $title -icon error -message [mc e04 $value $item]
      exit
    }
    set value [lindex $exec 0]
  }
  switch [file pathtype $value] {
    absolute		{set $item [file normalize $value]}
    relative		{set $item [file normalize $cwd/$value]}
    volumerelative	{set $item [file normalize $drive/$value]}
  }
}

cd $cwd

# Check operating system

if {$tcl_platform(os) == "Windows NT"} {
  if {$language == ""} {
    package require registry
    set language [registry get \
	{HKEY_CURRENT_USER\Control Panel\International} {LocaleName}]
    set language [regsub {(.*)-(.*)} $language {\1}]
  }
  if {![info exists env(TMP)]} {set env(TMP) $env(HOME)]}
  set tmpdir [file normalize $env(TMP)]
  set nprocs $env(NUMBER_OF_PROCESSORS)
} elseif {$tcl_platform(os) == "Linux"} {
  if {$language == ""} {
    set language [regsub {(.*)_(.*)} $env(LANG) {\1}]
    if {$env(LANG) == "C"} {set language en}
  }
  if {![info exists env(TMPDIR)]} {set env(TMPDIR) /tmp}
  set tmpdir $env(TMPDIR)
  set nprocs [exec /usr/bin/nproc]
} else {
  error_message [mc e03 $tcl_platform(os)] exit
}

# Restore saved settings from folder ini_folder

if {![info exists ini_folder]} {set ini_folder $env(HOME)/.Mapsforge}
file mkdir $ini_folder

set maps.contrast 0
set maps.gamma 1.00
set font.size [font configure TkDefaultFont -size]
set console.show 0
set console.geometry ""
set console.font.size 8

set dem.folder ""
set shading.onoff 0
set shading.magnitude 1.
set shading.algorithm simple
set shading.simple.linearity 0.1
set shading.simple.scale 0.666
set shading.diffuselight.angle 50.
set shading.asy.values [list 0.5 0 80 [expr max(1,$nprocs/3)] $nprocs true]
array set shading.asy.array {}
set shading.zoom.min.apply false
set shading.zoom.min.value 9
set shading.zoom.max.apply false
set shading.zoom.max.value 17

set tcp.port $tcp_port
set tcp.interface $interface
set tcp.maxconn 1024
set log.requests 0

set use.magick gm
set tiles.folder $cwd
set tiles.abort 1
set tiles.compose 1
set tiles.keep 0
set composed.show 1
set http.keep 0
set http.wait 0

set tms.url ""
set tms.list {}
set tms.z 0
set tms.x [lrepeat 21 0]
set tms.y [lrepeat 21 0]
set tms.servers ""

set min_zoom_level [expr max( 0,$min_zoom_level)]
set max_zoom_level [expr min(25,$max_zoom_level)]

# Save/restore settings

proc save_settings {file args} {
  array set save {}
  set fd [open $file a+]
  seek $fd 0
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set save($name) $value
  }
  foreach name $args {set save($name) [set ::$name]}
  seek $fd 0
  chan truncate $fd
  foreach name [lsort [array names save]] {puts $fd $name=$save($name)}
  close $fd
}

proc restore_settings {file} {
  if {![file exists $file]} return
  set fd [open $file r]
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set ::$name $value
  }
  close $fd
}

# Restore saved settings

foreach item {global hillshading tmsserver tiles} \
	{restore_settings $ini_folder/$item.ini}
set i 0
lmap v ${shading.asy.values} {set shading.asy.array($i) $v; incr i}

# Restore saved test tile numbers

array set tms.ax {}
array set tms.ay {}
for {set i 0} {$i<=$max_zoom_level} {incr i} {
  set tms.ax($i) [lindex ${tms.x} $i]
  set tms.ay($i) [lindex ${tms.y} $i]
}

# Restore saved font sizes

foreach item {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont} \
	{font configure $item -size ${font.size}}

# Configure main window

set title [mc l01]
wm title . $title
wm protocol . WM_DELETE_WINDOW "set action 0"
wm resizable . 0 0
. configure -bd 5 -bg $colorBackground

# Output console window

set console 0;			# Valid values: 0=hide, 1=show

set ctid [thread::create -joinable "
  package require Tk
  wm withdraw .
  wm title . \"$title - [mc l99]\"
  set font_size ${console.font.size}
  set geometry {${console.geometry}}
  ttk::style theme use clam
  ttk::style configure . -border $colorBorder -troughcolor $colorTrough
  thread::wait
  "]

proc ctsend {script} "return \[send $ctid \$script\]"

ctsend {
  foreach item {Consolas "Ubuntu Mono" "Noto Mono" "Liberation Mono"
  	[font configure TkFixedFont -family]} {
    set family [lsearch -nocase -exact -inline [font families] $item]
    if {$family != ""} break
  }
  font create font -family $family -size $font_size
  text .txt -font font -wrap none -setgrid 1 -state disabled -undo 0 \
	-width 120 -xscrollcommand {.sbx set} \
	-height 24 -yscrollcommand {.sby set}
  ttk::scrollbar .sbx -orient horizontal -command {.txt xview}
  ttk::scrollbar .sby -orient vertical   -command {.txt yview}
  grid .txt -row 1 -column 1 -sticky nswe
  grid .sby -row 1 -column 2 -sticky ns
  grid .sbx -row 2 -column 1 -sticky we
  grid columnconfigure . 1 -weight 1
  grid rowconfigure    . 1 -weight 1

  bind .txt <Control-a> {%W tag add sel 1.0 end;break}
  bind .txt <Control-c> {tk_textCopy %W;break}
  bind . <Control-plus>  {incr_font_size +1}
  bind . <Control-minus> {incr_font_size -1}
  bind . <Control-KP_Add>      {incr_font_size +1}
  bind . <Control-KP_Subtract> {incr_font_size -1}

  bind . <Configure> {
    if {"%W" != "."} continue
    scan [wm geometry %W] "%%dx%%d+%%d+%%d" cols rows x y
    set geometry "$x $y $cols $rows"
  }

  proc incr_font_size {incr} {
    set px [.txt xview]
    set py [.txt yview]
    set size [font configure font -size]
    incr size $incr
    if {$size < 5 || $size > 20} return
    font configure font -size $size
    update idletasks
    .txt xview moveto [lindex $px 0]
    .txt yview moveto [lindex $py 0]
  }

  set lines 0
  proc write {text} {
    incr ::lines
    .txt configure -state normal
    if {[string index $text 0] == "\r"} {
      set text [string range $text 1 end]
      .txt delete end-2l end-1l
    }
    .txt insert end $text
    .txt configure -state disabled
    .txt see end
    if {$::lines == 256} {update; set ::lines 0}
  }

  proc show_hide {show} {
    if {$show} {
      if {$::geometry == ""} {
	wm deiconify .
      } else {
	lassign $::geometry x y cols rows
	if {$x > [expr [winfo vrootx .]+[winfo vrootwidth .]] ||
	    $x < [winfo vrootx .]} {set x [winfo vrootx .]}
	wm positionfrom . program
	wm geometry . ${cols}x${rows}+$x+$y
	wm deiconify .
	wm geometry . +$x+$y
      }
    } else {
      wm withdraw .
    }
  }

  lassign [chan pipe] fdi fdo
  thread::detach $fdo
  fconfigure $fdi -blocking 0 -buffering line -translation lf
  fileevent $fdi readable "
    while {\[gets $fdi line\] >= 0} {write \"\$line\\n\"}
  "
}

set fdo [ctsend "set fdo"]
thread::attach $fdo
fconfigure $fdo -blocking 0 -buffering line -translation lf
interp alias {} ::cputs {} ::puts $fdo

if {$console == 1} {
  set console.show 1
  ctsend "show_hide 1"
}

# Mark output message

proc cputi {text} {cputs "\[---\] $text"}
proc cputw {text} {cputs "\[+++\] $text"}

cputw [mc m51 [pid] [file tail [info nameofexecutable]]]
cputw "Tcl/Tk version $tcl_patchLevel"
cputw "Script '[file tail $script]' version $version"

# Show error message

proc error_message {message exit_return} {
  messagebox -title $::title -icon error -message $message
  eval $exit_return
}

# Get shell command from exec command

proc get_shell_command {command} {
  return [join [lmap item $command {regsub {^(.* +.*|())$} $item {"\1"}}]]
}

# Check commands & folders

foreach item {java_cmd} {
  set value [set $item]
  if {$value == ""} {error_message [mc e04 $value $item] exit}
}
foreach item {server_jar} {
  set value [set $item]
  if {![file isfile $value]} {error_message [mc e05 $value $item] exit}
}

# Work around Oracle's Java wrapper "java.exe" issue:
# Wrapper requires running within real Windows console,
# therefore not working within Tcl script called by "wish"!
# -> Try getting Java's real path from Windows registry

if {$tcl_platform(os) == "Windows NT" &&
  ([regexp -nocase {^.*/Program Files.*/Common Files/Oracle/Java/.*/java.exe$} $java_cmd]
   || [regexp -nocase {^.*/ProgramData/Oracle/Java/.*/java.exe$} $java_cmd])} {
  set exec ""
  foreach item {HKEY_LOCAL_MACHINE\\SOFTWARE\\JavaSoft \
		HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\JavaSoft} {
    foreach key {JRE "Java Runtime Environment" JDK "Java Development Kit"} {
      if {[catch {registry get $item\\$key CurrentVersion} value]} continue
      if {[catch {registry get $item\\$key\\$value JavaHome} value]} continue
      set exec [auto_execok "[file normalize $value]/bin/java.exe"]
      if {$exec != ""} break
    }
    if {$exec == ""} continue
    set java_cmd [lindex $exec 0]
    break
  }
}

# Get major Java version

set java_version 0
set java_string unknown
set command [list $java_cmd -version]
set rc [catch "exec $command 2>@1" result]
if {!$rc} {
  set line [lindex [split $result \n] 0]
  regsub -nocase {^.* version "(.*)".*$} $line {\1} data
  set java_string $data
  if {[regsub {^1\.([1-9]+)\.[0-9]+.*$} $java_string {\1} data] > 0} {
    set java_version $data; # Oracle Java version <= 8
  } elseif {[regsub {^([1-9][0-9]*)((\.0)*\.[1-9][0-9]*)*([+-].*)?$} \
	$java_string {\1} data] > 0} {
    set java_version $data; # Other Java versions >= 9
  }
}

if {$rc || $java_version == 0} \
  {error_message [mc e08 Java [get_shell_command $command] $result] exit}
if {$java_version < 11} {error_message [mc e07 Java $java_string 11] exit}

# Evaluate numeric Mapsforge server version
# from output line ending with version string " version: x.y.z.c"

set server_version 0
set server_string unknown
set command [list $java_cmd -jar $server_jar -help]
set rc [catch "exec $command 2>@1" result]
foreach line [split $result \n] {
  if {![regexp -nocase {^(?:.* version: )([0-9.]+)$} $line "" data]} continue
  set server_string $data
  set data [split $data .]
  if {[llength $data] != 4} \
    {error_message [mc e07 "Mapsforge Server" $server_string 0.21.0.0] exit}
  foreach item $data {set server_version [expr 100*$server_version+$item]}
  break
}

if {$rc || $server_version == 0} \
  {error_message [mc e08 Server [get_shell_command $command] $result] exit}
if {$server_version < 210000} \
  {error_message [mc e07 "Mapsforge Server" $server_string 0.21.0.0] exit}

# Looking for installed URL tool "curl"

set curl ""
if {[info exists curl_cmd] && $curl_cmd != ""} {set curl $curl_cmd}
if {$curl == ""} {set curl [lindex [auto_execok curl] 0]}
if {$curl == ""} {error_message [mc e10] exit}

catch {exec $curl -V} data
set string [lindex [split $data] 1]
set curl_version [split $string .]
set curl_version [expr 1000*[lindex $curl_version 0]+[lindex $curl_version 1]]
if {$curl_version < 7075} {error_message [mc e07 curl $string 7.75.0] exit}

# Looking for installed GraphicsMagick's tool "gm"

set gm ""
if {[info exists gm_cmd] && $gm_cmd != ""} {set gm $gm_cmd}

if {$gm == "" && $::tcl_platform(os) == "Windows NT"} {
  foreach dir {GraphicsMagick*Q8* GraphicsMagick*} {
    foreach var {ProgramFiles ProgramFiles(x86)} {
      if {![info exists env($var)]} continue
      set val $env($var)
      set gm [lindex [glob -nocomplain -type f \
	"[file normalize $val]/$dir/gm.exe"] end]
      if {$gm != ""} break
    }
    if {$gm != ""} break
  }
}
if {$gm == ""} {set gm [lindex [auto_execok gm] 0]}

# Set resource limits of GraphicsMagick
# - GraphicsMagick uses defaults for unset resource values
# - Resource value "-1" is equivalent to "unlimited"
# See http://www.graphicsmagick.org/GraphicsMagick.html

if {$gm != ""} {
# set env(MAGICK_LIMIT_DISK)	-1
  set env(MAGICK_LIMIT_FILES)	16384
# set env(MAGICK_LIMIT_MAP)	4GiB
# set env(MAGICK_LIMIT_MEMORY)	2GiB
# set env(MAGICK_LIMIT_WIDTH)	10MiP
# set env(MAGICK_LIMIT_HEIGHT)	10MiP
# set env(MAGICK_LIMIT_PIXELS)	1GiB

# catch {exec $gm convert -list Resource} result
# cputs "[file tail $gm] - $result\n"
}

# Looking for installed ImageMagick's tool "magick"

set magick ""
if {[info exists magick_cmd] && $magick_cmd != ""} {set magick $magick_cmd}

if {$magick == "" && $::tcl_platform(os) == "Windows NT"} {
  foreach dir {ImageMagick*Q8* ImageMagick*} {
    foreach var {ProgramFiles ProgramFiles(x86)} {
      if {![info exists env($var)]} continue
      set val $env($var)
      set magick [lindex [glob -nocomplain -type f \
	"[file normalize $val]/$dir/magick.exe"] end]
      if {$magick != ""} break
    }
    if {$magick != ""} break
  }
}
if {$magick == ""} {set magick [lindex [auto_execok magick] 0]}

# Set resource limits of ImageMagick
# - ImageMagick uses defaults for unset resource values
# - Resource value "" is equivalent to "unlimited"
# See https://imagemagick.org/script/security-policy.php#policy
# and https://imagemagick.org/script/resources.php

if {$magick != ""} {
  set fd [open $ini_folder/policy.xml w]
  puts $fd {?xml version="1.0" encoding="UTF-8"?>}
  puts $fd {<!DOCTYPE policymap [}
  puts $fd {  <!ELEMENT policymap (policy)*>}
  puts $fd {  <!ATTLIST policymap xmlns CDATA #FIXED ''>}
  puts $fd {  <!ELEMENT policy EMPTY>}
  puts $fd {  <!ATTLIST policy xmlns CDATA #FIXED '' domain NMTOKEN #REQUIRED}
  puts $fd {    name NMTOKEN #IMPLIED pattern CDATA #IMPLIED}
  puts $fd {    rights NMTOKEN #IMPLIED}
  puts $fd {    stealth NMTOKEN #IMPLIED value CDATA #IMPLIED>}
  puts $fd {]>}
  puts $fd {<policymap>}
# puts $fd {  <policy domain="resource" name="disk" value=""/>}
# puts $fd {  <policy domain="resource" name="file" value="16384"/>}
# puts $fd {  <policy domain="resource" name="map" value="4GB"/>}
# puts $fd {  <policy domain="resource" name="memory" value="10GB"/>}
# puts $fd {  <policy domain="resource" name="area" value="10GB"/>}
# puts $fd {  <policy domain="resource" name="width" value="10MiP"/>}
# puts $fd {  <policy domain="resource" name="height" value="10MiP"/>}
  puts $fd {</policymap>}
  close $fd
  set env(MAGICK_CONFIGURE_PATH) $ini_folder

# catch {exec $magick -list Resource} result
# cputs "[file tail $magick] - $result\n"
}

if {$gm == "" && $magick == ""} {error_message [mc e09] exit}

# --- Begin of main window left column

# Title

font create title_font {*}[font configure TkDefaultFont] \
	-underline 1 -weight bold
label .title -text $title -font title_font -fg blue
pack .title -expand 1 -fill x -pady {0 3}

set github https://github.com/JFritzle/TMS-to-Tiles
tooltip .title $github
if {$tcl_platform(platform) == "windows"} \
	{set exec "exec cmd.exe /C START {} $github"}
if {$tcl_platform(os) == "Linux"} \
	{set exec "exec nohup xdg-open $github >/dev/null"}
bind .title <Button-1> "catch {$exec}"

# Left menu column

frame .l
pack .l -side left -anchor nw

# Show TMS server settings

checkbutton .tmsserver_show_hide -text [mc c01] \
	-command "show_hide_toplevel_window .tmsserver"
pack .tmsserver_show_hide -in .l -expand 1 -fill x

# Show hillshading server settings

checkbutton .server_show_hide -text [mc c02] \
	-command "show_hide_toplevel_window .server"
pack .server_show_hide -in .l -expand 1 -fill x

# Show hillshading options

checkbutton .shading_show_hide -text [mc c03] \
	-command "show_hide_toplevel_window .shading"
pack .shading_show_hide -in .l -expand 1 -fill x

# Show visual rendering effects options

checkbutton .effects_show_hide -text [mc c04] \
	-command "show_hide_toplevel_window .effects"
pack .effects_show_hide -in .l -expand 1 -fill x

# Filler down to bottom left

frame .fill_l
pack .fill_l -in .l -fill y

# --- End of main window left column

# Menu columns separator

frame .m -width 2 -bd 2 -relief sunken
pack .m -side left -fill y -padx 5

# --- Begin of main window right column

# Right menu column

frame .r
pack .r -anchor nw

# X and Y range

labelframe .xyrange -labelanchor w -text [mc l21]:
pack .xyrange -in .r -expand 1 -fill x -pady 1
combobox .xyrange_values -width 18 -values [list [mc v22] [mc v23]] \
	-validate key -validatecommand {return 0}
if {[info exists xyrange.mode]} {.xyrange_values current ${::xyrange.mode}}
if {[.xyrange_values current] < 0} {.xyrange_values current 0}
pack .xyrange_values -in .xyrange -side right -anchor e -expand 1

proc switch_xyrange {} {
  set range [.xyrange_values current]
  if {$range == 0} {
    set w tiles
    set r coord
  } else {
    set r tiles
    set w coord
  }
  foreach item {xmine xmaxe ymine ymaxe} {
    .${w}.$item configure -takefocus 1 -state normal
    .${r}.$item configure -takefocus 0 -state readonly
  }
}

# Tiles

labelframe .tiles -labelanchor nw -text [mc l22]:
pack .tiles -in .r -fill x

# Coordinates

labelframe .coord -labelanchor nw -text [mc l23]:
pack .coord -in .r -fill x

# Common widgets for tiles/coordinates

foreach item {tiles coord} {
  set widget .${item}
  label $widget.xminl -text "X min:"
  entry $widget.xmine -textvariable ${item}.xmin -justify right -width 12
  label $widget.xmaxl -text "X max:"
  entry $widget.xmaxe -textvariable ${item}.xmax -justify right -width 12
  grid $widget.xminl -in $widget -row 1 -column 1 -sticky w
  grid $widget.xmine -in $widget -row 1 -column 2 -sticky w
  grid $widget.xmaxl -in $widget -row 1 -column 3 -sticky e
  grid $widget.xmaxe -in $widget -row 1 -column 4 -sticky e
  label $widget.yminl -text "Y min:"
  entry $widget.ymine -textvariable ${item}.ymin -justify right -width 12
  label $widget.ymaxl -text "Y max:"
  entry $widget.ymaxe -textvariable ${item}.ymax -justify right -width 12
  grid $widget.yminl -in $widget -row 2 -column 1 -sticky w
  grid $widget.ymine -in $widget -row 2 -column 2 -sticky w
  grid $widget.ymaxl -in $widget -row 2 -column 3 -sticky e
  grid $widget.ymaxe -in $widget -row 2 -column 4 -sticky e
  grid columnconfigure $widget {1 3} -weight 1
  grid columnconfigure $widget {2 4} -weight 1
}

# Zoom level

labelframe .zoom -labelanchor w -text [mc l24]:
pack .zoom -in .r -fill x -expand 1 -pady 1
scale .zoom_scale -from $min_zoom_level -to $max_zoom_level -resolution 1 \
	-orient horizontal -variable zoom.level -command scale_zoom
label .zoom_value -anchor center -textvariable zoom.level -width 4 \
	-relief sunken
pack .zoom_value -in .zoom -side right
pack .zoom_scale -in .zoom -side left -fill x -expand 1

proc scale_zoom {zoom} {
  set tmax [expr (1<<$zoom)-1]
  set xmax 180
  set ymax 85.0511
  set tiles_xmin "X min ≥ 0 ([mc t21 0 $xmax°])"
  set tiles_xmax "X max ≤ $tmax ([mc t22 $tmax $xmax°])"
  set tiles_ymin "Y min ≥ 0 ([mc t23 0 $ymax°])"
  set tiles_ymax "Y max ≤ $tmax ([mc t24 $tmax $ymax°])"
  set coord_xmin "X min ≥ -$xmax ([mc t21 0 $xmax°])"
  set coord_xmax "X max ≤ +$xmax ([mc t22 $tmax $xmax°])"
  set coord_ymin "Y min ≥ -$ymax ([mc t24 $tmax $ymax°])"
  set coord_ymax "Y max ≤ +$ymax ([mc t23 0 $ymax°])"
  foreach item {tiles coord} {
    set widget .${item}
    eval tooltip $widget.xmine "\$${item}_xmin"
    eval tooltip $widget.xmaxe "\$${item}_xmax"
    eval tooltip $widget.ymine "\$${item}_ymin"
    eval tooltip $widget.ymaxe "\$${item}_ymax"
  }
  set count [expr $tmax+1]
  tooltip .zoom_scale [mc t25 $tmax $count $count]

  # Shrink tiles range to valid range
  while {1} {
    set valid 1
    foreach item {xmin xmax ymin ymax} \
	{if {[set ::tiles.$item] > $tmax} {set valid 0}}
    if {$valid} break
    foreach item {xmin xmax ymin ymax} \
	{set ::tiles.$item [expr [set ::tiles.$item]>>1]}
  }

  # Recalculate tile numbers or coordinate values
  if {[.xyrange_values current] == 0} {
    set type tiles
  } else {
    set type coord
  }
  foreach item {xmine xmaxe ymine ymaxe} {
    set widget .$type.$item
    set value [$widget get]
    validate_$type $widget $value
  }
}

bind .xyrange_values <<ComboboxSelected>> switch_xyrange
switch_xyrange

# Validate tile numbers

foreach item {xmine xmaxe ymine ymaxe} \
	{.tiles.$item configure -validate key -vcmd "validate_tiles %W %P"}

proc validate_tiles {widget tile} {
  if {[$widget cget -state] == "readonly"} {return 1}
  set tile [string trim $tile]
  set suffix [lindex [split $widget "."] end]
  set xy [string range $suffix 0 0]
  set minmax [string range $suffix 1 3]
  regsub -- {tiles} $widget {coord} coord_widget
  set variable [$coord_widget cget -textvariable]
  if {$xy == "y"} {
    if {$minmax == "min"} {
      regsub -- {min} $variable {max} variable
    } else {
      regsub -- {max} $variable {min} variable
    }
  }
  if {$tile == ""} {
    set ::$variable ""
    return 1
  }
  if {![string is integer $tile]} {return 0}
  set max [expr 1<<${::zoom.level}]
  if {$tile < 0} {return 0}
  if {$tile >= $max} {return 0}
  if {$minmax == "max"} {incr tile]}
  set max [expr double($max)]
  if {$xy == "x"} {
    set value [expr $tile/$max*360.-180.]
  } else {
    set pi 3.1415926535897931
    set value [expr atan(sinh($pi*(1.-2.*$tile/$max)))]
    set value [expr $value*180./$pi]
  }
  set ::$variable [format "%+.7f" $value]
  return 1
}

# Validate coordinates

foreach item {xmine xmaxe ymine ymaxe} \
	{.coord.$item configure -validate key -vcmd "validate_coord %W %P"}

proc validate_coord {widget coord} {
  if {[$widget cget -state] == "readonly"} {return 1}
  set coord [string trim $coord]
  set suffix [lindex [split $widget "."] end]
  set xy [string range $suffix 0 0]
  set minmax [string range $suffix 1 3]
  regsub -- {coord} $widget {tiles} tiles_widget
  set variable [$tiles_widget cget -textvariable]
  if {$xy == "y"} {
    if {$minmax == "min"} {
      regsub -- {min} $variable {max} variable
    } else {
      regsub -- {max} $variable {min} variable
    }
  }
  if {$coord == "" || $coord == "+" || $coord == "-"} {
    set ::$variable ""
    return 1
  }
  if {![string is double $coord]} {return 0}
  if {$xy == "x"} {
    set limit 180.
  } else {
    set limit 85.0511288
  }
  if {$coord < -$limit} {return 0}
  if {$coord > +$limit} {return 0}
  set max [expr double(1<<${::zoom.level})]
  if {$xy == "x"} {
    set value [expr ($coord+180.)/360.*$max]
  } else {
    set pi 3.1415926535897931
    set coord [expr $coord*$pi/180.]
    set value [expr (1.-(log(tan($coord)+1./cos($coord))/$pi))/2.*$max]
  }
  set ::$variable [expr int(min($value,$max-1))]
  return 1
}

# Recalculate tile numbers or coordinate values

scale_zoom ${zoom.level}

# Show tile server's URL

labelframe .tms_url -labelanchor nw -text [mc l11]:
pack .tms_url -in .r -fill x -expand 1 -pady 1
entry .tms_url_value -textvariable tms.url \
	-state readonly -takefocus 0 -highlightthickness 0
pack .tms_url_value -in .tms_url -side left -fill x -expand 1

# Choose folder for tiles and composed image

if {![file isdirectory ${tiles.folder}]} {set tiles.folder $cwd}
labelframe .tiles_folder -labelanchor nw -text [mc l31]:
pack .tiles_folder -in .r -fill x -expand 1 -pady 1
entry .tiles_folder_value -textvariable tiles.folder \
	-state readonly -takefocus 0 -highlightthickness 0
button .tiles_folder_button -style Arrow.TButton \
	-image ArrowDown -command choose_tiles_folder
pack .tiles_folder_button -in .tiles_folder -side right -fill y
pack .tiles_folder_value -in .tiles_folder -side left -fill x -expand 1

proc choose_tiles_folder {} {
  set folder [tk_chooseDirectory -parent . -initialdir ${::tiles.folder} \
	-title "$::title - [mc l32]"]
  if {$folder != ""} {
    if {![file isdirectory $folder]} {catch {file mkdir $folder}}
    if { [file isdirectory $folder]} {set ::tiles.folder $folder}
  }
}

# Filename prefix

labelframe .tiles_prefix -labelanchor w -text [mc l33]:
pack .tiles_prefix -in .r -expand 1 -fill x -pady {2 1}
entry .tiles_prefix_value -textvariable tiles.prefix -width 25 -justify left
pack .tiles_prefix_value -in .tiles_prefix -side right

.tiles_prefix_value configure -validate key -vcmd {
  if {%d < 1} {return 1}
  return [regexp {^(\w+[-.]?)*$} %P]
}

# Abort HTTP requests at error condition

checkbutton .tiles_abort -text [mc c31] \
	-variable tiles.abort
pack .tiles_abort -in .r -expand 1 -fill x

# Use GraphicsMagick or ImageMagick for composition

radiobutton .use_gmagick -text [mc c32 GraphicsMagick] \
	-variable use.magick -value gm
radiobutton .use_imagick -text [mc c32 ImageMagick] \
	-variable use.magick -value magick
pack .use_gmagick .use_imagick -in .r -expand 1 -fill x

if {$gm == ""} {
  set use.magick magick
  .use_gmagick configure -state disabled
  tooltip .use_gmagick [mc c32t GraphicsMagick]
}
if {$magick == ""} {
  set use.magick gm
  .use_imagick configure -state disabled
  tooltip .use_imagick [mc c32t ImageMagick]
}

# Compose tiles

checkbutton .tiles_compose -text [mc c33] \
	-variable tiles.compose -command tiles_compose_onoff
pack .tiles_compose -in .r -expand 1 -fill x

# Container for "Compose tiles" dependent widgets

frame .tiles_compose_onoff
proc tiles_compose_onoff {} {
  if {${::tiles.compose}} {
    pack .tiles_compose_onoff -in .r -after .tiles_compose -fill x
  } else {
    pack forget .tiles_compose_onoff
  }
  if {[winfo ismapped .]} {resize_toplevel_window .}
}
tiles_compose_onoff

# Keep tiles after composing to image

checkbutton .tiles_keep -text [mc c34] -variable tiles.keep
pack .tiles_keep -in .tiles_compose_onoff -expand 1 -fill x

# Show composed image

checkbutton .show_composed -text [mc c35] -variable composed.show
pack .show_composed -in .tiles_compose_onoff -expand 1 -fill x

# Action buttons

frame .buttons
button .buttons.continue -text [mc b01] -width 12 -command {set action 1}
button .buttons.cancel -text [mc b02] -width 12 -command {set action 0}
pack .buttons.continue .buttons.cancel -side left
pack .buttons -after .r -anchor n -pady 5

focus .buttons.continue

proc busy_state {state} {
  set busy {.l .r .buttons.continue .shading .effects .server .tmsserver}
  if {$state} {
    foreach item $busy {tk busy hold $item}
    .buttons.continue state pressed
    .buttons.cancel configure -text [mc b03] -command cancel_render_job
  } else {
    .buttons.continue state !pressed
    .buttons.cancel configure -text [mc b02] -command {set action 0}
    foreach item $busy {tk busy forget $item}
  }
  update idletasks
}

# Show/hide output console window (show with saved geometry)

checkbutton .output -text [mc c99] \
	-variable console.show -command show_hide_console
pack .output -after .buttons -anchor n -expand 1 -fill x

proc show_hide_console {} {ctsend "show_hide ${::console.show}"}
show_hide_console

# Map/Unmap events are generated by Windows only!
set tid [thread::id]
ctsend "
  wm protocol . WM_DELETE_WINDOW \
	{thread::send -async $tid {.output invoke}}
  bind . <Unmap> {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 0}}}
  bind . <Map>   {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 1}}}
"

# --- End of main window right column

# Create toplevel windows for
# - hillshading settings
# - visual rendering effects
# - hillshading server settings
# - tmsserver settings

foreach widget {.shading .effects .server .tmsserver} {
  set parent ${widget}_show_hide
  toplevel $widget -bd 5
  wm withdraw $widget
  wm title $widget [$parent cget -text]
  wm protocol $widget WM_DELETE_WINDOW "$parent invoke"
  wm resizable $widget 0 0
  wm positionfrom $widget program
  if {[tk windowingsystem] == "x11"} {wm attributes $widget -type dialog}

  bind $widget <Double-ButtonRelease-3> "$parent invoke"
  set ::$parent 0
}

# Show/hide toplevel window

proc show_hide_toplevel_window {widget} {
  set onoff [set ::${widget}_show_hide]
  if {$onoff} {
    resize_toplevel_window $widget
    position_toplevel_window $widget
    scan [wm geometry $widget] "%*dx%*d+%d+%d" x y
    wm transient $widget .
    wm deiconify $widget
    if {[tk windowingsystem] == "x11"} {after idle "wm geometry $widget +$x+$y"}
  } else {
    scan [wm geometry $widget] "%*dx%*d+%d+%d" x y
    set ::{$widget.dx} [expr $x - [set ::{$widget.x}]]
    set ::{$widget.dy} [expr $y - [set ::{$widget.y}]]
    wm withdraw $widget
  }
}

# Recalculate and force toplevel window size

proc resize_toplevel_window {widget} {
  update idletask
  lassign [wm minsize $widget] w0 h0
  set w1 [winfo reqwidth $widget]
  set h1 [winfo reqheight $widget]
  if {$w0 == $w1 && $h0 == $h1} return
  wm minsize $widget $w1 $h1
  wm maxsize $widget $w1 $h1
}

# Position toplevel window right/left besides main window

proc position_toplevel_window {widget} {
  if {![winfo ismapped .]} return
  update idletasks
  scan [wm geometry .] "%dx%d+%d+%d" width height x y
  if {[tk windowingsystem] == "win32"} {
    set bdwidth [expr [winfo rootx .]-$x]
  } elseif {[tk windowingsystem] == "x11"} {
    set bdwidth 2
    if {[auto_execok xwininfo] == ""} {
      cputw "Please install program 'xwininfo' by Linux package manager"
      cputw "to evaluate exact window border width."
    } elseif {![catch {exec bash -c "export LANG=C;xwininfo -id [wm frame .] \
	| grep Width | cut -d: -f2"} wmwidth]} {
      set bdwidth [expr ($wmwidth-$width)/2]
      set width $wmwidth
    }
  }
  set reqwidth [winfo reqwidth $widget]
  set right [expr $x+$bdwidth+$width]
  set left  [expr $x-$bdwidth-$reqwidth]
  if {[expr $right+$reqwidth > [winfo vrootx .]+[winfo vrootwidth .]]} {
    set x [expr $left < [winfo vrootx .] ? 0 : $left]
  } else {
    set x $right
  }
  set ::{$widget.x} $x
  set ::{$widget.y} $y
  if {[info exists ::{$widget.dx}]} {
    incr x [set ::{$widget.dx}]
    incr y [set ::{$widget.dy}]
  }
  wm geometry $widget +$x+$y
}

# Global toplevel bindings

foreach widget {. .shading .effects .server .tmsserver} {
  bind $widget <Control-plus>  {incr_font_size +1}
  bind $widget <Control-minus> {incr_font_size -1}
  bind $widget <Control-KP_Add>      {incr_font_size +1}
  bind $widget <Control-KP_Subtract> {incr_font_size -1}
}

# --- Begin of hillshading

# Enable/disable hillshading

checkbutton .shading.onoff -text [mc c80] -variable shading.onoff
pack .shading.onoff -expand 1 -fill x

# Hillshading as separate transparent overlay map only

radiobutton .shading.asmap -text [mc c82]
pack .shading.asmap -anchor w -fill x
.shading.asmap invoke

# Choose DEM folder with HGT files

if {![file isdirectory ${dem.folder}]} {set dem.folder ""}

labelframe .shading.dem_folder -labelanchor nw -text [mc l81]:
tooltip .shading.dem_folder [mc l81t]
pack .shading.dem_folder -fill x -expand 1 -pady 1
entry .shading.dem_folder_value -textvariable dem.folder \
	-state readonly -takefocus 0 -highlightthickness 0
tooltip .shading.dem_folder_value [mc l81t]
button .shading.dem_folder_button -style Arrow.TButton \
	-image ArrowDown -command choose_dem_folder
pack .shading.dem_folder_button -in .shading.dem_folder \
	-side right -fill y
pack .shading.dem_folder_value -in .shading.dem_folder \
	-side left -fill x -expand 1

proc choose_dem_folder {} {
  set folder [tk_chooseDirectory -parent . -initialdir ${::dem.folder} \
	-mustexist 1 -title "$::title - [mc l82]"]
  if {$folder != "" && [file isdirectory $folder]} {set ::dem.folder $folder}
}

# Hillshading algorithm

labelframe .shading.algorithm -labelanchor w -text [mc l83]:
pack .shading.algorithm -expand 1 -fill x -pady 2
set list {}
if {$server_version >= 230001} {lappend list adaptasy}
if {$server_version >= 220000} {lappend list stdasy simplasy hiresasy}
combobox .shading.algorithm.values -width 12 \
	-validate key -validatecommand {return 0} \
	-textvariable shading.algorithm -values $list
if {[.shading.algorithm.values current] < 0} \
	{.shading.algorithm.values current 0}
pack .shading.algorithm.values -in .shading.algorithm \
	-side right -anchor e -expand 1

# Hillshading algorithm parameters

labelframe .shading.simple -labelanchor w -text [mc l84]:
entry .shading.simple.value1 -textvariable shading.simple.linearity \
	-width 8 -justify right
set .shading.simple.value1.minmax {0 1 0.1}
tooltip .shading.simple.value1 "0 ≤ [mc l84] ≤ 1"
label .shading.simple.label2 -text [mc l85]:
entry .shading.simple.value2 -textvariable shading.simple.scale \
	-width 8 -justify right
set .shading.simple.value2.minmax {0 10 0.666}
tooltip .shading.simple.value2 "0 ≤ [mc l85] ≤ 10"
pack .shading.simple.value1 .shading.simple.label2 .shading.simple.value2 \
	-in .shading.simple -side left -anchor w -expand 1 -fill x -padx {5 0}

labelframe .shading.diffuselight -labelanchor w -text [mc l86]:
entry .shading.diffuselight.value -textvariable shading.diffuselight.angle \
	-width 8 -justify right
set .shading.diffuselight.value.minmax {0 90 50.}
tooltip .shading.diffuselight.value "0° ≤ [mc l86] ≤ 90°"
pack .shading.diffuselight.value -in .shading.diffuselight \
	-side right -anchor e -expand 1

frame .shading.asy
foreach i {0 1 2} {
  label .shading.asy.label$i -anchor w -text [mc l88$i]:
  entry .shading.asy.value$i -textvariable shading.asy.array($i) \
	-width 8 -justify right
  grid .shading.asy.label$i -row $i -column 1 -sticky w -padx {0 2}
  grid .shading.asy.value$i -row $i -column 2 -sticky e
}
set .shading.asy.value0.minmax {0 1 0.5}
tooltip .shading.asy.value0 "0 ≤ [mc l880] ≤ 1"
set .shading.asy.value1.minmax {0 99 0}
tooltip .shading.asy.value1 "0 ≤ [mc l881] < [mc l882]"
set .shading.asy.value2.minmax {1 100 80}
tooltip .shading.asy.value2 "[mc l881] < [mc l882] ≤ 100"
checkbutton .shading.asy.hq -text [mc l885] -variable shading.asy.array(5) \
	-onvalue true -offvalue false
grid .shading.asy.hq -row 4 -column 1 -columnspan 2 -sticky we
grid columnconfigure .shading.asy 1 -weight 1

# Hillshading magnitude

labelframe .shading.magnitude -labelanchor w -text [mc l87]:
pack .shading.magnitude -expand 1 -fill x
entry .shading.magnitude.value -textvariable shading.magnitude \
	-width 8 -justify right
set .shading.magnitude.value.minmax {0 4 1.}
tooltip .shading.magnitude.value "0 ≤ [mc l87] ≤ 4"
pack .shading.magnitude.value -in .shading.magnitude -anchor e -expand 1

# Theme's hillshading zoom

frame .shading.zoom
checkbutton .shading.zoom.min_apply -text [mc l891]: \
	-variable shading.zoom.min.apply \
	-onvalue true -offvalue false -command update_shading_zoom_levels
entry .shading.zoom.min_value -textvariable shading.zoom.min.value \
	-width 8 -justify right
set .shading.zoom.min_value.minmax {0 25 9}
tooltip .shading.zoom.min_value "0 ≤ [mc l891] ≤ 25"
checkbutton .shading.zoom.max_apply -text [mc l892]: \
	-variable shading.zoom.max.apply \
	-onvalue true -offvalue false -command update_shading_zoom_levels
entry .shading.zoom.max_value -textvariable shading.zoom.max.value \
	-width 8 -justify right
set .shading.zoom.max_value.minmax {0 25 17}
tooltip .shading.zoom.max_value "0 ≤ [mc l892] ≤ 25"

set row 0
foreach item {min max} {
  incr row
  grid .shading.zoom.${item}_apply -row $row -column 1 -sticky we -padx {0 2}
  grid .shading.zoom.${item}_value -row $row -column 2 -sticky we
}
grid columnconfigure .shading.zoom 1 -weight 1
if {$server_version >= 230002} {pack .shading.zoom -expand 1 -fill x}

# Reset hillshading algorithm parameters

button .shading.reset -text [mc b92] -width 8 -command reset_shading_values
tooltip .shading.reset [mc b92t]
pack .shading.reset -pady {5 0}

proc update_shading_zoom_levels {} {
  foreach item {shading.zoom.min shading.zoom.max} {
    if {[set ::$item.apply] == true} {.${item}_value configure -state normal} \
    else {.${item}_value configure -state disabled}
  }
}

proc update_shading_window {} {
  catch "pack forget .shading.simple .shading.diffuselight .shading.asy"
  if {${::shading.algorithm} ni [.shading.algorithm.values cget -values]} \
	{.shading.algorithm.values current 0}
  set widget ${::shading.algorithm}
  regsub {.*asy$} $widget {asy} widget
  pack .shading.$widget -after .shading.algorithm -expand 1 -fill x -pady 1
  update_shading_zoom_levels
  resize_toplevel_window .shading
}

set shading_widgets_float {.shading.simple.value1 .shading.simple.value2 \
	.shading.diffuselight.value .shading.magnitude.value \
	.shading.asy.value0}
set shading_widgets_int {.shading.asy.value1 .shading.asy.value2 \
	.shading.zoom.min_value .shading.zoom.max_value}

proc reset_shading_values {} {
  foreach item [concat $::shading_widgets_float $::shading_widgets_int] \
	{set ::[$item cget -textvariable] [lindex [set ::$item.minmax] 2]}
  set ::shading.asy.array(5) true
  .shading.algorithm.values current 0
  foreach item {min max} {set ::shading.zoom.$item.apply false}
  update_shading_window
}

foreach item $shading_widgets_float {
  $item configure -validate all -vcmd {validate_number %W %V %P " " float}
}

foreach item $shading_widgets_int {
  $item configure -validate all -vcmd {validate_number %W %V %P " " int}
}

foreach item [concat $shading_widgets_float $shading_widgets_int] {
  bind $item <Shift-ButtonRelease-1> \
	{set [%W cget -textvariable] [lindex ${::%W.minmax} 2]}
}

# Save hillshading settings to folder ini_folder

proc save_shading_settings {} {
  lmap {i v} [array get ::shading.asy.array] {lset ::shading.asy.values $i $v}
  save_settings $::ini_folder/hillshading.ini \
	shading.onoff shading.algorithm \
	shading.simple.linearity shading.simple.scale \
	shading.diffuselight.angle shading.asy.values \
	shading.magnitude dem.folder \
	shading.zoom.min.apply shading.zoom.min.value \
	shading.zoom.max.apply shading.zoom.max.value
}

bind .shading.algorithm.values <<ComboboxSelected>> update_shading_window
update_shading_window

# --- End of hillshading
# --- Begin of visual rendering effects

# Gamma correction & Contrast-stretching

label .effects.color -text [mc s06]

label .effects.gamma_label -text [mc s07]: -anchor w
scale .effects.gamma_scale -from 0.01 -to 4.99 -resolution 0.01 \
	-orient horizontal -variable maps.gamma
bind .effects.gamma_scale <Shift-ButtonRelease-1> "set maps.gamma 1.00"
label .effects.gamma_value -textvariable maps.gamma -width 4 \
	-relief sunken -anchor center

label .effects.contrast_label -text [mc s08]: -anchor w
scale .effects.contrast_scale -from 0 -to 254 -resolution 1 \
	-orient horizontal -variable maps.contrast
bind .effects.contrast_scale <Shift-ButtonRelease-1> "set maps.contrast 0"
label .effects.contrast_value -textvariable maps.contrast -width 4 \
	-relief sunken -anchor center

set row 10
grid .effects.color -row $row -column 1 -columnspan 3 -sticky we
foreach item {gamma contrast} {
  incr row
  grid .effects.${item}_label -row $row -column 1 -sticky w \
	-padx {0 2} -pady {0 4}
  grid .effects.${item}_scale -row $row -column 2 -sticky we
  grid .effects.${item}_value -row $row -column 3 -sticky e
}

grid columnconfigure .effects {1 2} -uniform 1

# Reset visual rendering effects

button .effects.reset -text [mc b92] -width 8 -command reset_effects_values
tooltip .effects.reset [mc b92t]
grid .effects.reset -row 99 -column 1 -columnspan 3 -pady {5 0}

proc reset_effects_values {} {
  set ::maps.gamma 1.00
  set ::maps.contrast 0
}

# --- End of visual rendering effects
# --- Begin of server settings

# Server information

label .server.info -text [mc x01]
pack .server.info

# Java runtime version

labelframe .server.jre_version -labelanchor w -text [mc x02]:
pack .server.jre_version -expand 1 -fill x -pady 1
label .server.jre_version_value -anchor e -textvariable java_string
pack .server.jre_version_value -in .server.jre_version \
	-side right -anchor e -expand 1

# Mapsforge server version

labelframe .server.version -labelanchor w -text [mc x03]:
pack .server.version -expand 1 -fill x -pady 1
label .server.version_value -anchor e -textvariable server_string
pack .server.version_value -in .server.version \
	-side right -anchor e -expand 1

# Mapsforge server version jar archive

labelframe .server.jar -labelanchor nw -text [mc x04]:
pack .server.jar -expand 1 -fill x -pady 1
entry .server.jar_value -textvariable server_jar \
	-state readonly -takefocus 0 -highlightthickness 0
pack .server.jar_value -in .server.jar -expand 1 -fill x

# Server configuration

label .server.config -text [mc x11]
pack .server.config -pady {5 0}

# Rendering engine

set pattern marlin-*-Unsafe-OpenJDK11
set engines [glob -nocomplain -tails -type f \
	-directory [file dirname $server_jar] $pattern.jar]
lappend engines (default)
set engines [lsort -dictionary $engines]

set width 0
foreach item $engines \
	{set width [expr max([font measure TkTextFont $item],$width)]}
set width [expr $width/[font measure TkTextFont "0"]+1]

labelframe .server.engine -labelanchor nw -text [mc x12]:
combobox .server.engine_values -width $width \
	-validate key -validatecommand {return 0} \
	-textvariable rendering.engine -values $engines
if {[.server.engine_values current] < 0} \
	{.server.engine_values current 0}
if {[llength $engines] > 1} {
  pack .server.engine -expand 1 -fill x -pady 1
  pack .server.engine_values -in .server.engine \
	-anchor e -expand 1 -fill x
}

# Server interface

labelframe .server.interface -labelanchor w -text [mc x13]:
combobox .server.interface_values -width 10 \
	-textvariable tcp.interface -values {localhost all}
if {[.server.interface_values current] < 0} \
	{.server.interface_values current 0}
pack .server.interface -expand 1 -fill x -pady {6 2}
pack .server.interface_values -in .server.interface \
	-side right -anchor e -expand 1 -padx {3 0}

# Server TCP port number

labelframe .server.port -labelanchor w -text [mc x15]:
entry .server.port_value -textvariable tcp.port \
	-width 6 -justify center
set .server.port_value.minmax "1024 65535 $tcp_port"
tooltip .server.port_value "1024 ≤ [mc x15] ≤ 65535"
pack .server.port -expand 1 -fill x -pady 1
pack .server.port_value -in .server.port \
	-side right -anchor e -expand 1 -padx {3 0}

# Maximum size of TCP listening queue

labelframe .server.maxconn -labelanchor w -text [mc x16]:
entry .server.maxconn_value -textvariable tcp.maxconn \
	-width 6 -justify center
set .server.maxconn_value.minmax {0 {} 1024}
tooltip .server.maxconn_value "[mc x16] ≥ 0"
pack .server.maxconn -expand 1 -fill x -pady 1
pack .server.maxconn_value -in .server.maxconn \
	-side right -anchor e -expand 1 -padx {3 0}

# Enable/disable server request logging

checkbutton .server.logrequests -text [mc x19] -variable log.requests
pack .server.logrequests -expand 1 -fill x

# Reset server configuration

button .server.reset -text [mc b92] -width 8 -command reset_server_values
tooltip .server.reset [mc b92t]
pack .server.reset -pady {5 0}

proc reset_server_values {} {
  foreach widget {.server.port_value .server.maxconn_value} \
	{set ::[$widget cget -textvariable] [lindex [set ::$widget.minmax] 2]}
  .server.engine_values current 0
  .server.interface_values set $::interface
}

foreach widget {.server.port_value .server.maxconn_value} {
  $widget configure -validate all -vcmd {validate_number %W %V %P " " int}
  bind $widget <Shift-ButtonRelease-1> \
	{set [%W cget -textvariable] [lindex ${::%W.minmax} 2]}
}

# --- End of server settings
# --- Begin of TMS server settings

# Current tile server URL

labelframe .tmsserver.url -labelanchor nw -text [mc l11]:
pack .tmsserver.url -fill x -expand 1 -pady 1
entry .tmsserver.url_value -textvariable tms.url -width 0
pack .tmsserver.url_value -in .tmsserver.url -fill x -expand 1

# Example URL

label .tmsserver.xmpl -anchor w -text \
  {Example URL: http[s]://host[:port][/path]/{z}/{x}/{y}.png[?query]}
pack .tmsserver.xmpl -anchor w -pady 1 -fill x

# Tooltip for example URL

set wtip .tmsserver_xmpl_tooltip
set bg $colorInfoBackground
set fg $colorInfoText

toplevel $wtip -bd 1 -relief solid
wm withdraw $wtip
wm overrideredirect $wtip 1

label $wtip.title -bg $bg -fg $fg -padx 2 -anchor w -text [mc l120]:
pack $wtip.title -fill x

frame $wtip.comp -bg $bg -padx 10
set col1 {"host" "port" "path" "{z}" "{x}" "{y}" "query"}
set col2 {}
set row 0
while {$row < 7} {
  incr row
  lappend col2 " … [mc l12$row]"
}
foreach col {1 2} {
  label $wtip.comp.$col -text [join [set col$col] \n] \
	-justify left -bd 0 -bg $bg -fg $fg
  grid $wtip.comp.$col -row 1 -column $col
}
pack $wtip.comp -fill x
unset col1 col2

label $wtip.foot -bg $bg -fg $fg -padx 2 -anchor w -text [mc l129]
pack $wtip.foot -fill x

bind .tmsserver.xmpl <Enter> {
  set wtip .tmsserver_xmpl_tooltip
  wm geometry $wtip +%X+[expr %Y+[winfo height %W]]
  wm deiconify $wtip
}
bind .tmsserver.xmpl <Leave> {
  set wtip .tmsserver_xmpl_tooltip
  after 500 "wm withdraw $wtip"
}

frame .tmsserver.grid
pack .tmsserver.grid -expand 1 -fill x

grid columnconfigure .tmsserver.grid {2 3 4} -weight 1

# Test URL with tile values

button .tmsserver.grid.test -text [mc l13] -command test_server_url
grid .tmsserver.grid.test -row 1 -column 1 -sticky we

# Tile test values

labelframe .tmsserver.grid.z -text "{z}" -labelanchor w
scale .tmsserver.grid.z.scale -from $min_zoom_level -to $max_zoom_level \
	-showvalue 0 -orient horizontal -length 50 -sliderlength 20 \
	-variable tms.z 
label .tmsserver.grid.z.value -width 3 -relief sunken -textvariable tms.z
pack .tmsserver.grid.z.scale .tmsserver.grid.z.value -side left
pack configure .tmsserver.grid.z.scale -padx {5 0} -ipadx 5
grid .tmsserver.grid.z -row 1 -column 2 -sticky we -padx {5 0}

labelframe .tmsserver.grid.x -text "{x}" -labelanchor w
entry .tmsserver.grid.x.value -justify center -width 9
pack .tmsserver.grid.x.value -padx {5 0} -ipadx 5
grid .tmsserver.grid.x -row 1 -column 3 -sticky we -padx {5 0}

labelframe .tmsserver.grid.y -text "{y}" -labelanchor w
entry .tmsserver.grid.y.value -justify center -width 9
pack .tmsserver.grid.y.value -padx {5 0} -ipadx 5
grid .tmsserver.grid.y -row 1 -column 4 -sticky we -padx {5 0}

proc tmsserver_test_z {value} {
  set tmax [expr (1<<$value)-1]
  foreach item {x y} {
    set widget .tmsserver.grid.$item.value
    set txtvar tms.a${item}($value)
    tooltip $widget "0 ≤ {$item} ≤ $tmax"
    set ::tms.$item 0
    set ::$widget.minmax "0 $tmax [set ::$txtvar]"
    $widget configure -textvariable $txtvar \
	-validate all -vcmd {validate_number %W %V %P " " int}
    bind $widget <Shift-ButtonRelease-1> \
	{set [%W cget -textvariable] [lindex ${::%W.minmax} 2]}
  }
}
.tmsserver.grid.z.scale configure -command tmsserver_test_z
bind .tmsserver.grid.z.scale <Configure> {tmsserver_test_z ${tms.z}}

# Add URL to tile server archive

button .tmsserver.grid.add -text [mc l14] -command add_server_url
grid .tmsserver.grid.add -row 2 -column 1 -sticky we

proc add_server_url {} {
  set url [string trim ${::tms.url}]
  if {$url == ""} return
  if {[lsearch -exact ${::tms.list} $url] >= 0} return
  if {[catch {::uri::split $url}]} {
    error_message "[mc e12]:\n$url" return
    return
  }
  lappend ::tms.list $url
  .tmsserver.list_values selection set end
  .tmsserver.list_values see end
  .tmsserver.list_values configure \
	-height [expr min([llength ${::tms.list}],12)]
}

# Merge URLs from text file

button .tmsserver.grid.merge -text [mc l15] -command merge_server_file
grid .tmsserver.grid.merge -row 3 -column 1 -sticky we

labelframe .tmsserver.grid.file -text [mc l151] -labelanchor w
entry .tmsserver.grid.file.value -textvariable tms.servers \
	-state readonly -takefocus 0 -highlightthickness 0
button .tmsserver.grid.file.button -style Arrow.TButton \
	-image ArrowDown -command set_server_file
pack .tmsserver.grid.file.value .tmsserver.grid.file.button \
	-side left -fill y
pack configure .tmsserver.grid.file.value -fill x -expand 1
pack configure .tmsserver.grid.file.button -fill y
grid .tmsserver.grid.file -row 3 -column 2 -columnspan 3 -sticky we -padx {5 0}

proc merge_server_file {} {
  if {![file exists ${::tms.servers}]} return
  set fd [open ${::tms.servers} r]
  while {[gets $fd line] != -1} {
    set url [string trim $line]
    if {[catch {::uri::split $url}]} continue
    if {[lsearch -exact ${::tms.list} $url] != -1} continue
    lappend ::tms.list $url
    .tmsserver.list_values see end
  }
  close $fd
  .tmsserver.list_values configure \
	-height [expr min([llength ${::tms.list}],12)]
  resize_toplevel_window .tmsserver
}

proc set_server_file {} {
  set file ${::tms.servers}
  if {[file exists $file]} {set folder [file dirname $file]} \
  else {set folder ${::ini_folder}}
  set file [tk_getOpenFile -parent .tmsserver -initialdir $folder \
	-filetypes [list [list [mc l151] .txt]] \
	-title "$::title - [mc l15]"]
  if {$file != ""} {set ::tms.servers $file}
}

# Tile server archive

labelframe .tmsserver.list -labelanchor nw -text [mc l16]:
pack .tmsserver.list -expand 1 -fill x -pady 1
scrollbar .tmsserver.list_scroll -command ".tmsserver.list_values yview"
listbox .tmsserver.list_values -selectmode single -activestyle none \
	-takefocus 1 -exportselection 0 -listvariable tms.list \
	-width 0 -height [expr min([llength ${tms.list}],12)] \
	-yscrollcommand ".tmsserver.list_scroll set"
pack .tmsserver.list_scroll -in .tmsserver.list -side right -fill y
pack .tmsserver.list_values -in .tmsserver.list -side left -expand 1 -fill both

bind .tmsserver.list_values <ButtonRelease-1> {
  set tms.url [lindex ${tms.list} [%W curselection]]
}
bind .tmsserver.list_values <Delete> {
  %W delete [%W curselection]
}

# Test result window

set wtest .tmsserver_test_result

toplevel $wtest -bd 5
wm withdraw $wtest
wm title $wtest [.tmsserver.grid.test cget -text]
wm resizable $wtest 0 0
if {[tk windowingsystem] == "x11"} {wm attributes $wtest -type dialog}
wm protocol $wtest WM_DELETE_WINDOW "wm withdraw $wtest"

bind $wtest <Double-ButtonRelease-3> "wm withdraw $wtest"

set focus$wtest ""
foreach event {Enter Leave Control-plus Control-minus \
	Control-KP_Add Control-KP_Subtract} \
	{bind $wtest <$event> [bind .tmsserver <$event>]}

label $wtest.title -padx 1 -bd 0 -anchor w -text [mc l181]:
grid $wtest.title -row 1 -column 1 -sticky we
text $wtest.text -padx 1 -bd 1 -relief sunken -bg $colorWindow -wrap word
grid $wtest.text -row 2 -column 1 -sticky we
label $wtest.image -padx 1 -bd 1 -relief sunken -image ""
label $wtest.size

# Test URL

proc test_server_url {} {
  set url [string trim ${::tms.url}]
  set zoom ${::tms.z}
  set xmin [set ::tms.ax($zoom)]
  set ymin [set ::tms.ay($zoom)]
  set xmax $xmin
  set ymax $ymin
  set prefix [::fileutil::tempdir]/
  set suffix tmp
  set task ""
  set ::cancel 0

  set tmpfile $prefix$zoom.$xmin.$ymin.$suffix
  catch {file delete $tmpfile}

  set logsep ""
  set logfmt "%-17s : %s"
  set fdlog [file tempfile]

  set ::curl_echo 0
  set rc [download_with_curl]

  seek $fdlog 0
  set log [split [read -nonewline $fdlog] \n]
  close $fdlog

  set test_result {}
  set url [string trim ${::tms.url}]
  regsub "\\$?{z}" $url $zoom url
  regsub "\\$?{x}" $url $xmin url
  regsub "\\$?{y}" $url $ymin url
  lappend test_result [list [mc l182] $url]
  lappend test_result [list "curl return code" "$rc $result"]
  foreach item $log {
    if {![regexp {^< } $item]} continue
    regexp {^< ([^:]*):?(.*)} $item {} head tail
    lappend test_result [list $head $tail]
  }

  if {[file exists $tmpfile] && [lindex [filetype $tmpfile] 0] == "binary"} {
    set tile_format ""
    if {${::use.magick} == "gm"} {
      exec $::gm convert $tmpfile\[0\] $tmpfile.png
      catch {exec $::gm identify -format "%m %w %h %q %r" $tmpfile} result
    } elseif {${::use.magick} == "magick"} {
      exec $::magick $tmpfile\[0\] $tmpfile.png
      catch {exec $::magick identify -format "%m %w %h %z %r" $tmpfile} result
    }
    set tile_format [eval format \"[mc l185]: %s, [mc l186]: %sx%s [mc l187], \
	[mc l188]: %s-bit, [mc l189]: %s\" $result]
    set tile_image [image create photo tile_image -file $tmpfile.png]
    file delete $tmpfile.png
  }

  if {[file exists $tmpfile] && [filetype $tmpfile] == "text"} {
    lappend test_result [list Content [::fileutil::cat $tmpfile]]
  }

  catch {file delete $tmpfile}

  set wtest .tmsserver_test_result
  $wtest.text configure -state normal
  catch "$wtest.text delete 0.0 end"
  set wdt 0
  foreach item $test_result {
    lassign $item head tail
    set head [string trim $head]
    if {$head == ""} continue
    set str [format "%-17s" $head]
    set tail [string trim $tail]
    if {$tail != ""} {append str ": $tail"}
    set wdt [expr max($wdt,[string length $str])]
    $wtest.text insert end $str\n
  }
  $wtest.text delete end-1c
  if {$wdt > 100} {set wdt 100}
  $wtest.text configure -state disabled -width $wdt
  update idletasks
  set hgt [$wtest.text count -displaylines 0.0 end]
  $wtest.text configure -height $hgt
  if {[info exists tile_image]} {
    $wtest.size configure -text $tile_format
    $wtest.image configure -image $tile_image
    grid $wtest.image -row 3 -column 1 -sticky w -pady {5 0}
    grid $wtest.size -row 4 -column 1 -sticky w
  } else {
    grid forget $wtest.image $wtest.size
  }
  update idletasks
  wm transient $wtest .tmsserver
  wm deiconify $wtest
}

# --- End of TMS server settings

# Update global settings to folder ini_folder

proc save_global_settings {} {
  scan [wm geometry .] "%dx%d+%d+%d" width height x y
  set ::window.geometry "$x $y $width $height"
  set ::font.size [font configure TkDefaultFont -size]
  set ::console.geometry [ctsend "set geometry"]
  set ::console.font.size [ctsend "font configure font -size"]
  save_settings $::ini_folder/global.ini \
	rendering.engine maps.contrast maps.gamma \
	tcp.maxconn log.requests \
	window.geometry font.size \
	console.show console.geometry console.font.size
}

# Save TMS server settings to folder ini_folder

proc save_tmsserver_settings {} {
  set ::tms.x [lmap i [lsort -integer [array names ::tms.ax]] \
	{set ::tms.ax($i)}]
  set ::tms.y [lmap i [lsort -integer [array names ::tms.ay]] \
	{set ::tms.ay($i)}]
  save_settings $::ini_folder/tmsserver.ini \
	tms.url tms.list tms.x tms.y tms.z tms.servers
}

# Save tiles settings to folder ini_folder

proc save_tiles_settings {} {
  set ::xyrange.mode [.xyrange_values current]
  save_settings $::ini_folder/tiles.ini \
	tiles.folder tiles.prefix xyrange.mode zoom.level \
	tiles.xmin tiles.xmax tiles.ymin tiles.ymax \
	coord.xmin coord.xmax coord.ymin coord.ymax \
	tiles.abort tiles.compose tiles.keep composed.show \
	tcp.interface tcp.port \
	use.magick http.wait http.keep
}

# Validate signed/unsigned int/float number value

proc validate_number {widget event value sign number} {
  set name ::[$widget cget -textvariable]
  set value [string trim $value]
  set sign "\[$sign\]?";	# sign: " ", "+", "-", "+-"
  set int   {\d*}
  set float {\d*\.?\d*}
  set pattern [set $number];	# number: "int", "float"
  if {$event == "key"} {
    return [regexp "^($sign|$sign$pattern)$" $value];
  } elseif {$event == "focusin"} {
    set $name.prev $value
  } elseif {$event == "focusout"} {
    set prev [set $name.prev]
    if {[regexp "^$sign$pattern$" $value] &&
       ![regexp "^($sign|$sign\\.)$" $value]} {
      if {![info exists ::$widget.minmax]} {return 1}
      lassign [set ::$widget.minmax] min max
      set test [regsub {([+-]?)0*([0-9]+.*)} $value {\1\2}]
      if {$min != "" && [expr $test < $min]} {set $name $prev}
      if {$max != "" && [expr $test > $max]} {set $name $prev}
    } else {
      set $name $prev
    }
    after idle "$widget config -validate all"
  }
  return 1
}

# Increase/decrease font size

proc incr_font_size {incr} {
  set size [font configure TkDefaultFont -size]
  if {$size < 0} {set size [expr round(-$size/[tk scaling])]}
  incr size $incr
  if {$size < 5 || $size > 20} return
  set fonts {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont title_font}
  foreach item $fonts {font configure $item -size $size}
  set height [expr [winfo reqheight .title]-2]

  if {$::tcl_version > 8.6} {
    set scale [expr ($height+2)*0.0065]
    foreach item {CheckOff CheckOn RadioOff RadioOn} \
	{$item configure -format [list svg -scale $scale]}
  } else {
    set size [expr round(($height+3)*0.6)]
    set padx [expr round($size*0.3)]
    if {$::tcl_platform(os) == "Windows NT"} {set pady 0.1}
    if {$::tcl_platform(os) == "Linux"} {set pady -0.1}
    set pady [expr round($size*$pady)]
    set margin [list 0 $pady $padx 0]
    foreach item {TCheckbutton TRadiobutton} \
	{style configure $item -indicatorsize $size -indicatormargin $margin}
  }
  update idletasks

  foreach item {.xyrange_values .shading.algorithm.values \
	.server.engine_values .server.interface_values} \
	{if {[winfo exists $item]} {$item configure -justify left}}
  foreach item {.effects.gamma_scale .effects.contrast_scale \
	.zoom_scale .tmsserver.grid.z.scale} \
	{if {[winfo exists $item]} {$item configure -width $height}}
  foreach item {. .shading .effects .server .tmsserver} \
	{resize_toplevel_window $item}
}

# Check selection for completeness

proc selection_ok {} {
  if {${::tms.url} == ""} {
    error_message [mc e41] return
    return 0
  }
  set count 0
  foreach item {xmin xmax ymin ymax} \
	{if {[set ::tiles.$item] == ""} {incr count}}
  if {$count} {
    error_message [mc e42 $count] return
    return 0
  }
  if {(${::tiles.xmin} > ${::tiles.xmax}) || \
      (${::tiles.ymin} > ${::tiles.ymax})} {
    error_message [mc e43] return
    return 0
  }
  if {![file writable ${::tiles.folder}]} {
    error_message [mc e44 ${::tiles.folder}] return
    return 0
  }
  if {${::shading.onoff} && ![file isdirectory ${::dem.folder}]} {
    error_message [mc e45] return
    return 0
  }
  return 1
}

# Process start

proc process_start {command process} {

  lassign [chan pipe] fdi fdo
  set rc [catch "exec $command >&@ $fdo &" result]
  close $fdo

  if {$rc} {
    close $fdi
    error_message $result return
    after 0 {set action 0}
    return
  }

  namespace eval $process {}
  namespace upvar $process fd fd pid pid exe exe
  set ${process}::command $command
  set ${process}::cr ""

  set fd $fdi
  fconfigure $fd -blocking 0 -buffering line

  set pid $result
  set exe [file tail [lindex $command 0]]
  set mark "\[[string toupper $process]\]"
  cputi "[mc m51 $pid $exe] $mark"

  set cr "\$${process}::cr"
  unset -nocomplain ::$process.eof
  fileevent $fd readable "
    while {\[gets $fd line\] >= 0} {
      cputs \"$cr\\$mark \$line\"
    }
    if {\[eof $fd\]} {
      cputi \"\[mc m52 $pid $exe\] \\$mark\"
      namespace delete $process
      set $process.eof 1
      close $fd
    }"

}

# Process kill

proc process_kill {process} {

  if {![process_running $process]} return
  namespace upvar $process fd fd pid pid

  fileevent $fd readable [regsub {m52} [fileevent $fd readable] {m53}]

  if {$::tcl_platform(os) == "Windows NT"} {
    catch {exec TASKKILL /F /PID $pid /T}
  }
  if {$::tcl_platform(os) == "Linux"} {
    set rc [catch {exec pgrep -P $pid} list]
    if {$rc} {set list $pid} else {lappend list $pid}
    foreach item $list {catch {exec kill -SIGTERM $item}}
  }

  if {![info exist ::$process.eof]} {
    after 5000 "set $process.eof 1"
    vwait $process.eof
  }

}

# Check if process is running

proc process_running {process} {
  return [expr [namespace exists $process] && ![info exists ::$process.eof]]
}

# Mapsforge server start

proc srv_start {} {

  # Compose command line

  set params {-Xmx1G -Xms256M -Xmn256M}
  if {[info exists ::java_args]} {lappend params {*}$::java_args}
  lappend params -Dfile.encoding=UTF-8

  set engine ${::rendering.engine}
  if {$engine != "(default)"} {
    set engine [file dirname $::server_jar]/$engine
    lappend params --patch-module java.desktop="$engine"
  }

# set now [clock format [clock seconds] -format "%Y-%m-%d_%H-%M-%S"]
# lappend params -Xloggc:$::cwd/gc.$now.log -XX:+PrintGCDetails
  lappend params -Dslf4j.internal.verbosity=WARN
# lappend params -Dlog4j.debug
  lappend params -Dlog4j.configuration=file:$::tmpdir/log4j.properties

  lappend params -Dsun.java2d.opengl=true
# lappend params -Dsun.java2d.d3d=true
# lappend params -Dsun.java2d.accthreshold=0
# lappend params -Dsun.java2d.translaccel=true
# lappend params -Dsun.java2d.ddforcevram=true
# lappend params -Dsun.java2d.ddscale=true
# lappend params -Dsun.java2d.ddblit=true
# lappend params -Dsun.java2d.renderer.log=true
  lappend params -Dsun.java2d.renderer.log=false
  lappend params -Dsun.java2d.renderer.useLogger=true
# lappend params -Dsun.java2d.renderer.doStats=true
# lappend params -Dsun.java2d.renderer.doChecks=true
# lappend params -Dsun.java2d.renderer.useThreadLocal=true
  lappend params -Dsun.java2d.renderer.profile=speed
  lappend params -Dsun.java2d.renderer.useRef=hard
  lappend params -Dsun.java2d.renderer.pixelWidth=2048
  lappend params -Dsun.java2d.renderer.pixelHeight=2048
  lappend params -Dsun.java2d.renderer.tileSize_log2=8
  lappend params -Dsun.java2d.renderer.tileWidth_log2=8
  lappend params -Dsun.java2d.renderer.subPixel_log2_X=2
  lappend params -Dsun.java2d.renderer.subPixel_log2_Y=2
  lappend params -Dsun.java2d.renderer.useFastMath=true
  lappend params -Dsun.java2d.render.bufferSize=524288
# lappend params -Dawt.useSystemAAFontSettings=on

  set fd [open $::tmpdir/java_args w]
  foreach item $params {puts $fd $item}
  close $fd
  lappend command $::java_cmd @$::tmpdir/java_args -jar $::server_jar
  lappend command -config [file nativename $::tmpdir]

  # Configure server

  set data terminate=true\n
  append data requestlog-format=
  if {${::log.requests}} {append data "From %{client}a Get %U%q Status %s Size %O bytes Time %{ms}T ms"}
  append data \n
  if {${::tcp.interface} == "localhost"} {append data host=localhost\n}
  set port [set ::tcp.port]
  append data port=$port\n
  append data acceptQueueSize=${::tcp.maxconn}\n

  set fd [open $::tmpdir/server.properties w]
  puts $fd $data
  close $fd

  # Configure task

  set params {}

  set algorithm ${::shading.algorithm}
  if {$algorithm == "simple"} {
    set linearity ${::shading.simple.linearity}
    set scale ${::shading.simple.scale}
    if {$linearity == ""} {set linearity 0.1}
    if {$scale == ""} {set scale 0.666}
    lappend params hillshading-algorithm $algorithm\($linearity,$scale\)
  } elseif {$algorithm == "diffuselight"} {
    set angle ${::shading.diffuselight.angle}
    if {$angle == ""} {set angle 50.}
    lappend params hillshading-algorithm $algorithm\($angle\)
  } elseif {[regexp {asy$} $algorithm]} {
    lmap {i v} [array get ::shading.asy.array] \
	{lset ::shading.asy.values $i $v}
    set values [join ${::shading.asy.values} ,]
    lappend params hillshading-algorithm $algorithm\($values\)
  }
  set magnitude ${::shading.magnitude}
  if {$magnitude == ""} {set magnitude 1.}
  lappend params hillshading-magnitude $magnitude
  foreach item {min max} {
    lassign [list ::shading.zoom.$item.apply ::shading.zoom.$item.value] i v
    if {[info exists $i] && [set $i] == true} {
      lappend params hillshading-zoom-$item [set $v]
    }
  }
  lappend params demfolder ${::dem.folder}

  set data ""
  foreach {item value} $params {append data $item=$value\n}

  set fd [open $::tmpdir/tasks/Hillshading.properties w]
  puts $fd $data
  close $fd

  set text "Mapsforge Server \[SRV]\]"
  # Server not yet running: TCP port is currently in use?
  set count 0
  while {$count < 5} {
    set rc [catch {socket -server {} -myaddr 127.0.0.1 $port} fd]
    if {!$rc} break
    incr count
    after 200
  }
  if {$rc} {
    error_message [mc m59 $text $port $fd] return
    return
  }
  close $fd
  update

  # Start server

  cputi "[mc m54 $text] ..."
  cputs [get_shell_command $command]

  process_start $command srv

  # Wait until port becomes ready to accept connections or server aborts
  # Send dummy render request and wait for rendering initialization

  set url http://127.0.0.1:$port
  while {[process_running srv]} {
    if {[catch {::http::geturl $url} token]} {after 10; continue}
    set size [::http::size $token]
    ::http::cleanup $token
    if {$size} break
  }
  after 20
  update

  if {![process_running srv]} {error_message [mc m55 $text] return; return}
  set srv::port $port
  set srv::cr \r
  if {${::log.requests}} {cputs \r}

}

# Mapsforge hillshading server stop

proc srv_stop {} {

  if {![process_running srv]} return

  namespace upvar srv port port
  set url http://127.0.0.1:$port/terminate
  if {![catch {::http::geturl $url} token]} {
    if {[::http::status $token] == "eof"} {set code 200} \
    else {set code [::http::ncode $token]}
    if {$code != 200} {process_kill srv; return}
    ::http::cleanup $token
  }
  if {![info exist ::srv.eof]} {vwait srv.eof}

}

# Run command pipe

proc pipe_run {exe args} {
  lappend cmd $exe {*}$args
  set exe [file tail $exe]
  set rc [catch {open "| $cmd 2>@1" r} result]
  if {$rc} {return [list $rc $result]}

  set fd $result
  fconfigure $fd -blocking 0 -buffering line
  namespace eval pipe {}
  set pipe::pid [pid $fd]
  set pipe::exe $exe
  fileevent $fd readable "
    while {\[gets $fd line\] >= 0} {
      cputs \"\\r> $exe \$line\"
    }
    if {\[eof $fd\]} {
      set pipe::rc \[catch {close $fd} pipe::result]
    }"
  if {![info exists pipe::rc]} {vwait pipe::rc}
  set return [list $pipe::rc $pipe::result]
  namespace delete pipe
  return $return
}

# Kill command pipe

proc pipe_kill {} {
  if {![namespace exists pipe]} return
  if {[info exists pipe::rc]} return
  namespace upvar pipe pid pid exe exe
  if {$::tcl_platform(os) == "Windows NT"} {catch {exec TASKKILL /F /PID $pid}}
  if {$::tcl_platform(os) == "Linux"} {catch {exec kill -SIGTERM $pid}}
  if {![info exists pipe::rc]} {vwait pipe::rc}
  cputi [mc m53 $pid $exe]
}

# Download tiles with "curl"

proc download_with_curl {} {uplevel 1 {

  set url [string trim $url]
  regsub "\\$?{x}" $url "\[$xmin-$xmax\]" url
  regsub "\\$?{y}" $url "\[$ymin-$ymax\]" url
  regsub "\\$?{z}" $url $zoom url

  # Download tiles from server

  set curl_format !
  append curl_format " curl_url {%{url}}"
  append curl_format " curl_status %{response_code}"
  append curl_format " curl_size %{size_download}"
  append curl_format " curl_rc %{exitcode}"
  append curl_format " curl_result {%{errormsg}}"
  append curl_format \n

  set curl_exec $::curl
  lappend curl_exec -qsvkL --http1.1 --retry 0
  lappend curl_exec --fail-early
  lappend curl_exec --parallel --parallel-max 4
  lappend curl_exec --output ${prefix}$zoom.#1.#2.$suffix
  lappend curl_exec --write-out $curl_format
  lappend curl_exec --stderr - --no-buffer
  lappend curl_exec $url

  set count 0
  set valid 0

# cputs "\r[get_shell_command $curl_exec]\n"
  set rc [catch {open "| $curl_exec" r} result]
  if {$rc} {
    error_message "Download $url:\n$result" return
    puts $fdlog [format $logfmt "URL" $url]
    puts $fdlog [format $logfmt "curl error" $result]
    puts $fdlog $logsep
    return 1
  }

  set fd $result
  fconfigure $fd -blocking 0 -buffering line
  namespace eval pipe {}
  set pipe::pid [pid $fd]
  set pipe::exe [file tail $::curl]
  lassign {-1 unknown} ::curl_rc ::curl_result
  fileevent $fd readable "
    while {\[gets $fd line\] >= 0} {
      if {\[info exists pipe::abort\]} continue
      if {\[string range \$line 0 1\] != {! }} {
	puts $fdlog \[string trimright \$line \\r\]
      } else {
	lmap {name value} \[string range \$line 2 end\] {set \$name \$value}
	if {!$::curl_echo} continue
	if {\$curl_rc} {
	  cputs \"\\r> curl error \$curl_rc: \$curl_result\"
	  set pipe::abort 1
	} else {
	  cputs \"\\r> GET \$curl_url -> HTTP status \$curl_status, \$curl_size bytes data\"
	  if {\$curl_status == 200 || \$curl_status == 404} continue
	  if {${::tiles.abort}} {set pipe::abort 1; after 0 pipe_kill}
	}
      }
    }
    if {\[eof $fd\]} {
      set pipe::result \$curl_result
      set pipe::rc \$curl_rc
      close $fd
    }"
  if {![info exists pipe::rc]} {vwait pipe::rc}
  lassign [list $pipe::rc $pipe::result] rc result
  namespace delete pipe

  if {$rc || $::cancel} {return 1}

  # Count successfully downloded files

  set ytile $ymin
  while {$ytile <= $ymax} {
    set xtile $xmin
    while {$xtile <= $xmax} {
      incr count
      set tile ${prefix}$zoom.$xtile.$ytile.$suffix
      if {[file exists $tile]} {incr valid}
      incr xtile
    }
    incr ytile
  }
  return 0

}}

# Run render job

proc run_render_job {} {

  set ::cancel 0

  foreach item {xmin xmax ymin ymax} {upvar ::tiles.$item $item}
  upvar ::zoom.level zoom

  set text "\n[mc m61] ...\n"
  append text "[mc l24]: $zoom\n"
  append text "[mc m63]:\n"
  append text "$xmin ≤ xtile ≤ $xmax\n"
  append text "$ymin ≤ ytile ≤ $ymax\n"
  append text "[mc m64]:\n"
  append text "${::coord.xmin}° ≤ [mc m65] ≤ ${::coord.xmax}°\n"
  append text "${::coord.ymin}° ≤ [mc m66] ≤ ${::coord.ymax}°"
  cputs $text

  set xcount [expr $xmax-$xmin+1]
  set ycount [expr $ymax-$ymin+1]
  set total [expr $xcount*$ycount]

  set text ""
  append text "[mc m67 $xcount "x"],\n"
  append text "[mc m67 $ycount "y"],\n"
  append text "→ [mc m68] = $xcount * $ycount = $total.\n"
  cputs $text

  # Confirm if more than threshold tiles

  set threshold 100
  if {$total > $threshold} {
    if {[messagebox -parent . -title $::title -icon question -type yesno \
	-default no -message "$text\n[mc m69 $threshold]"] != "yes"} {return 1}
  }

  # Working in tiles folder

  catch {cd ${::tiles.folder}}
  set folder [pwd]
  cputs [mc m71 $folder]\n
  update

  set prefix ${::tiles.prefix}
  if {$prefix != "" && ![regexp {[-.]+$} $prefix]} {append prefix .}

  set composed $prefix$zoom.$xmin-$xmax.$ymin-$ymax
  file delete -force $composed.png

  # First remove existing tiles

  set tiles {}
  set ytile $ymin
  while {$ytile <= $ymax} {
    set xtile $xmin
    while {$xtile <= $xmax} {
      lappend tiles $prefix$zoom.$xtile.$ytile
      incr xtile
    }
    incr ytile
  }
  file delete -force {*}[lmap tile $tiles {list $tile.png}]

  # Open log file

  set logfile $composed.log
  set logsep [string repeat - 100]
  set logfmt "%-17s : %s"
  set fdlog [open $logfile w+]

  set rc 0
  set shading ${::shading.onoff}
  foreach task {Map Hillshading} {

    if {$task == "Hillshading" && !$shading} continue

    if {$task == "Map"} {set suffix img}
    if {$task == "Hillshading"} {set suffix ovl}

    # Url

    if {$task == "Map"} {set url ${::tms.url}}
    if {$task == "Hillshading"} {
      set url http://127.0.0.1:${::tcp.port}/{z}/{x}/{y}.png?task=Hillshading
      if {$::tile_size != 256} {append url &tileRenderSize=$::tile_size}
    }
    cputs "[mc m70 $url] ...\n"

    puts $fdlog $logsep
    puts $fdlog "Download tiles from URL '$url' ..."
    puts $fdlog $logsep

    # Start server

    if {$task == "Hillshading"} {
      srv_start
      if {![process_running srv]} {
	set rc 1
	break
      }
    }

    # Download with "curl"

    set start [clock milliseconds]
    set ::curl_echo [expr {$task == "Map"}]
    set rc [download_with_curl]
    set stop [clock milliseconds]

    # Stop server

    if {$task == "Hillshading"} {
      cputs ""
      srv_stop
    }

    if {$::cancel} break

    # Report result

    cputs "\n[mc m72 $total $valid]"

    # Measure time(s)

    set time [expr $stop-$start]
    cputs "\n[mc m75 $time $valid]"
    if {$valid} {cputs "[mc m76 [format "%.1f" [expr $time/(1.*$valid)]]]"}
    cputs "... [mc m77]\n"

    if {$valid == 0} {set rc 1}
    if {$rc} break

  }
  close $fdlog

  # Download cancelled or ended abnormally

  if {$rc || $::cancel} {
    file delete -force {*}[lmap tile $tiles {list $tile.img}]
    if {$shading} {file delete -force {*}[lmap tile $tiles {list $tile.ovl}]}
  }

  if {$::cancel} {
    cputs "\n[mc m73a]"
    file delete -force $logfile
    cd $::cwd
    return
  } elseif {$rc || $valid != $total} {
    cputs [mc m73b $folder/$logfile]
    cd $::cwd
    return
  } else {
#   exec notepad $logfile
    file delete -force $logfile
  }

  # Start tiles processing

  upvar ::use.magick use_magick
  set exe [set ::$use_magick]

  if {$use_magick == "gm"}	{set ::env(MAGICK_TMPDIR) $folder}
  if {$use_magick == "magick"}	{set ::env(MAGICK_TEMPORARY_PATH) $folder}

  # Fill missing tiles by white tile

  set void $::tmpdir/void.png
  if {$use_magick == "gm"}	{exec $exe convert -size 256x256 xc:white $void}
  if {$use_magick == "magick"}	{exec $exe -size 256x256 canvas:white $void}

  while {1} {

  # Convert image format to PNG with optional color post-processing

  set text [mc m84a]

  if {${::maps.contrast} != 0 || ${::maps.gamma} != 1.} {
    set black_point [format %.3f [expr 100.*${::maps.contrast}/255.]]
    if {$use_magick == "gm"} {
      set level "-level ${black_point}%,${::maps.gamma},100%"
    } elseif {$use_magick == "magick"} {
      set level "-level ${black_point},100%,${::maps.gamma}"
    }
    append text " [mc m84b]"
  } else {
    set level ""
  }

  cputs "$text ...\n"
  set start [clock milliseconds]

  set fd [file tempfile]
  if {$use_magick == "magick"} \
	{puts $fd "-format \"%f $level %t.png\\n\""}
  set clean {}
  set ytile $ymin
  while {$ytile <= $ymax} {
    set xtile $xmin
    while {$xtile <= $xmax} {
      set tile $prefix$zoom.$xtile.$ytile
      incr xtile
      if {![file exists $tile.img]} continue
      if {$level == "" && [lindex [filetype $tile.img] end] == "png"} {
	file rename -force $tile.img $tile.png
	puts "\r> rename $tile.img $tile.png"
      } elseif {$use_magick == "gm"} {
	puts $fd "convert $tile.img $level $tile.png"
	lappend clean $tile.img
      } elseif {$use_magick == "magick"} {
	puts $fd "$tile.img $level -identify -write $tile.png +delete"
	lappend clean $tile.img
      }
    }
    incr ytile
  }
  seek $fd 0

  set fderr [file tempfile]
  if {[llength $clean] == 0} {
    set rc 0
  } elseif {$use_magick == "gm"} {
    lassign [pipe_run $exe batch -stop-on-error on -echo on - \
	<@ $fd 2>@ $fderr] rc result
  } elseif {$use_magick == "magick"} {
    lassign [pipe_run $exe -script - \
	<@ $fd 2>@ $fderr] rc result
  }
  close $fd
  seek $fderr 0
  set data [split [read -nonewline $fderr] \n]
  close $fderr
  file delete -force {*}$clean
  set stop [clock milliseconds]

  if {[llength $data]} {
    if {$rc || [file exists $tile.png]} {
      cputs "> [join $data "\n> "]\n"
    } else {
      set rc 1
      set result "\n [join $data "\n "]\n"
    }
  }

  if {$rc || $::cancel} {
    file delete -force {*}[lmap tile $tiles {list $tile.png}]
    if {$shading} {file delete -force {*}[lmap tile $tiles {list $tile.ovl}]}
  }

  if {$::cancel} {
    break
  } elseif {$rc} {
    cputs [mc m74 $exe $result]
    break
  } else {
    set time [expr $stop-$start]
    cputs [mc m85 $time]
  }

  # Compose map tiles and alpha transparent hillshading overlay tiles

  if {$shading} {

  cputs "\n[mc m84c] ...\n"
  set start [clock milliseconds]

  set batch_file $::tmpdir/batch_file
  set fd [open $batch_file w+]
  if {$use_magick == "magick"} \
	{puts $fd "-format \"%f null: %t.ovl -layers composite %f\\n\""}
  set clean {}
  set ytile $ymin
  while {$ytile <= $ymax} {
    set xtile $xmin
    while {$xtile <= $xmax} {
      set tile $prefix$zoom.$xtile.$ytile
      incr xtile
      set map $tile.png
      set ovl $tile.ovl
      if {![file exists $ovl]} continue
      if {![file exists $map]} {set map $void}
      lappend clean $ovl
      if {$use_magick == "gm"} {
	puts $fd "composite $ovl $map $tile.png"
      } elseif {$use_magick == "magick"} {
	puts $fd "$map null: $ovl -layers composite -identify -write $tile.png -delete 0--1"
      }
    }
    incr ytile
  }
  seek $fd 0
  set mtime [file mtime $batch_file]

  set fderr [file tempfile]
  if {$use_magick == "gm"} {
    lassign [pipe_run $exe batch -stop-on-error on -echo on - \
	<@ $fd 2>@ $fderr] rc result
  } elseif {$use_magick == "magick"} {
    lassign [pipe_run $exe -script - \
	<@ $fd 2>@ $fderr] rc result
  }
  close $fd
  seek $fderr 0
  set data [split [read -nonewline $fderr] \n]
  close $fderr
  file delete -force {*}$clean
  set stop [clock milliseconds]

  if {[llength $data]} {
    if {$rc || ([file exists $tile.png] && [file mtime $tile.png] >= $mtime)} {
      cputs "> [join $data "\n> "]\n"
    } else {
      set rc 1
      set result "\n [join $data "\n "]\n"
    }
  }

  if {$rc || $::cancel} {
    file delete -force {*}[lmap tile $tiles {list $tile.png}]
  }

  if {$::cancel} {
    break
  } elseif {$rc} {
    cputs [mc m74 $exe $result]
    break
  } else {
    set time [expr $stop-$start]
    cputs [mc m85 $time]
  }

  }

  if {!${::tiles.compose}} break

  # Compose tiles to image

  cputs "\n[mc m78 $composed.png] ..."

  set start [clock milliseconds]

  set batch_file $::tmpdir/tiles.lst
  set fd [open $batch_file w]
  set tiles {}
  set ytile $ymin
  while {$ytile <= $ymax} {
    set xtile $xmin
    while {$xtile <= $xmax} {
      set tile $prefix$zoom.$xtile.$ytile.png
      if {[file exists $tile]} {
	lappend tiles $tile
	puts $fd $tile
      } else {
	puts $fd $void
      }
      incr xtile
    }
    incr ytile
  }
  close $fd

  set args "montage -mode concatenate -tile ${xcount}x${ycount} @$batch_file $composed.png"
  cputs "> [file tail $exe] $args"
  set fderr [file tempfile]
  lassign [pipe_run $exe {*}$args 2>@ $fderr] rc result
  seek $fderr 0
  set data [split [read -nonewline $fderr] \n]
  close $fderr
  set stop [clock milliseconds]

  if {[llength $data]} {
    if {$rc || [file exists $composed.png]} {
      cputs "> [join $data "\n> "]\n"
    } else {
      set rc 1
      set result "\n [join $data "\n "]\n"
    }
  }

  if {$rc || $::cancel} {
    file delete -force {*}$tiles $composed.png
  }

  if {$::cancel} {
    break
  } elseif {$rc} {
    cputs [mc m74 $exe $result]
    break
  } else {
    set time [expr $stop-$start]
    cputs [mc m85 $time]
    cputs [mc m81 $composed.png]
  }

  # Delete tiles

  if {!${::tiles.keep}} {
    file delete -force {*}$tiles
    cputs "\n[mc m83]"
  }

  break
  }

  # End tiles processing

  cd $::cwd

  if {$rc || $::cancel} return
  if {!${::composed.show}} return

  # Show composed image by background job

  set file $folder/$composed.png
  if {![file exists $file]} return
  if {$::tcl_platform(platform) == "windows"} {
    set exec "exec cmd.exe /C START {} \"$file\""
  } elseif {$::tcl_platform(os) == "Linux"} {
    set exec "exec nohup xdg-open \"$file\" >/dev/null"
  }
  after 0 "catch {$exec}"
  return

}

proc cancel_render_job {} {
  set ::cancel 1
  process_kill ovl
  pipe_kill
}

# Show main window (at saved position)

wm positionfrom . program
if {[info exists window.geometry]} {
  lassign ${window.geometry} x y width height
  # Adjust horizontal position if necessary
  set x [expr max($x,[winfo vrootx .])]
  set x [expr min($x,[winfo vrootx .]+[winfo vrootwidth .]-$width)]
  wm geometry . +$x+$y
}
incr_font_size 0
wm deiconify .

# Wait for valid selection or finish

while {1} {
  vwait action
  if {$action == 0} {
    foreach item {global shading tmsserver tiles} {save_${item}_settings}
    exit
  }
  unset action
  if {[selection_ok]} break
}

# Create server's temporary files folder

append tmpdir /[format "TMS%8.8x" [pid]]
file mkdir $tmpdir/tasks

# Create server logging properties

set fd [open $tmpdir/log4j.properties w]
puts $fd "log4j.rootLogger=INFO, stdout"
puts $fd "log4j.appender.stdout.encoding=UTF-8"
puts $fd "log4j.appender.stdout=org.apache.log4j.ConsoleAppender"
puts $fd "log4j.appender.stdout.Target=System.out"
puts $fd "log4j.appender.stdout.layout=org.apache.log4j.PatternLayout"
puts $fd "log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss.SSS} %m%n"
close $fd

# Run render job

busy_state 1
run_render_job
busy_state 0

# Wait for new selection or finish

update idletasks
if {![info exists action]} {vwait action}

# After changing settings: run render job

while {$action == 1} {
  unset action
  if {[selection_ok]} {
    busy_state 1
    run_render_job
    busy_state 0
  }
  if {![info exists action]} {vwait action}
}
unset action

# Delete temporary files folder

catch {file delete -force $tmpdir}

# Unmap main toplevel window

wm withdraw .

# Save settings to folder ini_folder

foreach item {global shading tmsserver tiles} {save_${item}_settings}

# Wait until output console window was closed

if {[ctsend "winfo ismapped ."]} {
  ctsend "
    write \"\n[mc m99]\"
    wm protocol . WM_DELETE_WINDOW {}
    bind . <ButtonRelease-3> {destroy .}
    tkwait window .
  "
}

# Done

destroy .
exit
