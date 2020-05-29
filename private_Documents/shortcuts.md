# VIM

leader key             : ,
set nowrap             : disable line wrapping
Ctrl + v               : column selection (I to insert, ESC to apply)

## Actions and motions
dw                     : until the start of the next word
de                     : to the end of the current word
ce                     : change to the end of the word
O                      : Open above the line
dtc                    : Delete To the next C
ci}                    : Change Inside the curly braces
cf,                    : Change Forward to and include the comma
di”                    : Delete Inside the quotes
ya’                    : Yank Around single quotes
gi                     : Go toethe last place with Insert mode
g;                     : go to the last place
gU{motion}             : example: gUaw -> word under cursor uppercase
d/palabro<cr>          : delete until "palabro"
%norm A*               : command to per each line (%) execute (norm) A* (add * in the end)

# Transform
U                      : uppercase in visual
<C-a>                  : increment a number
<C-x>                  : decrement a number

## Copy and paste

"+y                    : copy to X clipboard
"ay                    : copy to the record a
"Ay                    : append to the record a
"ap                    : paste from the record a
CTR+r+a                : in insert mode, paste record a
reg                    : command to see the values of the registers

## Undo and redo

CTR+R                  : undos undo
U                      : undo all the line
earlier 24s            : command to undo the last 24s
later 12s              : command to move forward 12s

## Search and replace

?                      : backwards search
%s/old/new/g           : command to change every occurrence in the whole file.
%s/old/new/gc          : command with a prompt whether to substitute or not.
noh                    : command to disable search highlighting
*                      : look for the work before the cursor, n for next
#                      : look for the work after the cursor, n for next
.\{-}                  : instead of `.*` to match only the first occurrence
<C-f>                  : after / to open a search history window

## Windows

Crtl+ww                : cycle though all windows
Crtl+wh                : takes you left a window
Crtl+wj                : takes you down a window
Crtl+wk                : takes you up a window
Crtl+wl                : takes you right a window
Crtl+wq                : close the window
Crtl+wo                : close other windows
Crtl+|                 : split
Crtl+-                 : split vertically

## Tabs

gt                     : go to next tab
gT                     : go to previous tab
{i}gt                  : go to tab in position i
tabclose               : command to close tab

## navigate errors

[l                     : previous error as :lprev
]l                     : next error as :lnext
mm                     : set mark `m`
'm                     : go to mark `m`


## Location list

lne                    : command to go to the next error
lnp                    : command to go to the previous error
lop                    : command to open the location list
lcl                    : command to close the location list

## Buffers

ls                     : command to list buffers
ls!                    : command to list buffers included unlisted
buffer (b)             : command to change to buffer by name or number
Ctrl + 6               : move to the previous buffer

## Spell checking

set spell              : toggle on
z=                     : show list with changes
[s                     : go to previous
]s                     : go to next
zg                     : add to dictionary
CTRL-X s               : to find suggestions
CTRL-n                 : to use the next suggestion
CTRL-p                 : to go back
GrammarousCheck        : command to check grammar
%s/\s\+$//e            : command to trim spaces in the line end

## netrw

Explore                : command to opens netrw in the current window
Sexplore               : command to opens netrw in a horizontal split
Vexplore               : command to opens netrw in a vertical split
E.                     : command to open explorer at HOME
%                      : open new file, ask for name
write <file>           : command to write buffer to filename
cd %:p:h               : change path to current directory


## splitjoin

gS                     : to split a one-liner into multiple lines
gJ                     : (with the cursor on the first line of a block) to join a block into a single-line statement.

## Tabularize

Tab /=                 : align by char =
Tab /=\zs              : same as before but = isn't centered

## vim-slice

<C-c><C-c>             : send to tmux pane

## Advanced vim

s                      : x + i
.                      : repeat last command
f{char}                : forward to char, also with motions
t{char}                : move to the previous char, also with motions
cw                     : delete the word + i
daw                    : delete a word
yyp                    : duplicate line
<C-u>                  : delete to the start of the line, also for bash.
<C-w>                  : delete last word, also for bash.
<C-o>                  : back to normal mode but only for one command!
zz                     : position cursor at middle screen
zt                     : position cursor at top of screen
zb                     : position cursor at bottom of screen
<C-r>0                 : paste register 0 in insert mode
C                      : delete selection and insert mode
I                      : insert in the beginning of the line
@                      : repeat last Ex command
q + double point       : command line window, ideal to repeat commands
<C-f>                  : switch to command line window in Ex mode
shell                  : command launch a shell
argdo                  : command which uses args as input of a command (if you open vim with many files)
e                      : end of the word
ge                     : end of the previous word
W,B,E,GE               : the same but more
\cd                    : set path
window lcd path        : command to change the path of a window
<C-r><C-w>             : paste a word in mode Ex
<C-r>=1+1              : paste 2

## To check / doesn't work
%% shortcut            : pag 120
path                   : command pag 122 automatic detection
%                      : to find a matching ),], or } . f% -> forward to
;                      : repeat the last search
cin(                   : change inside next ( asdfadff )
cil(                   : change inside last ()

# TMUX

## Windows (tabs)

<prefix> c             : create window
<prefix> w             : list windows
<prefix> n             : next window
<prefix> p             : previous window
<prefix> f             : find window
<prefix> ,             : name window
<prefix> &             : kill window

## Panes (splits)

<prefix> %             : vertical split
<prefix> "             : horizontal split
<prefix> o             : swap panes
<prefix> q             : show pane numbers
<prefix> x             : kill pane
<prefix> +             : break pane into window 
<prefix> -             : restore pane from window
<prefix> ⍽             : space - toggle between layouts
<prefix> {             : move the current pane left
<prefix> }             : move the current pane right

## Others

<prefix> ]             : copy, as vim (custom)
<prefix> z             : toggle pane zoom
<prefix> :             : command mode
setw synchronize-panes : synchronize panes ;-)

# i3wm

$mod + enter           : terminal
$mod + d               : dmenu
$mod + v               : open next windows in the vertical
$mod + #               : move to the workspace #
$mod + shift + e       : logout
$mod + shift + r       : reload i3
$mod + w               : tabbed mode

# fzf

'string                : exact match
^string                : start match
string$                : end match
string!                : negate match
vi **                  : open in vim
kill<tab>              : kill process
ls -lah **             : give details
cd **                  : change directory
ssh **                 : connect by ssh
<CTRL+T>               : list files+folders in current directory
<CTRL+R>               : search history of shell commands
<ALT+C>                : fuzzy change directory



# Intellij Idea

Alt + Insert           : generate constructor, setters, etc.
Ctrl + Shift + A       : find action by name
Alt + Enter            : show the list of available actions
** Alt + F1            : switch between views
** Crtl+Tab            : switch between tool windows and files opened
** Alt+Home            : who the Navigation bar
Ctrl + j               : insert a live template
Ctrl + Shift + j       : surround with a live template
Ctrl + e               : recent files
Ctrl + Shift + e       : recent edited files
** Ctrl + /            : comment linecode
** Ctrl + shift + /    : comment block code
Ctrl + n               : open class by name
Ctrl + shift + n       : open file by name
Ctrl + w               : increment expression selection
Ctrl + shift + w       : decrement expression selection
Shift + shift          : search anywhere
Ctrl + shift + F7      : quick view the usages of the selected symbol
Ctrl + Space           : invoke code completion
Ctrl + shift + Space   : smart statement completion
Ctrl + shift + alt + t : refactor this
F2                     : jump to the next error (or warning if no errors)
Ctrl + Enter           : fix typo
Ctrl + Shift + j       : join Lines to concatenate String values, combine if statements, merge variable declaration and its assignment, etc.
Ctrl + Shift + Enter   : Complete Statement to add a semi-colon to the line, create the outline of for loops or if statements, move the cursor to the next place, etc.

Ctrl + Alt + left      : back to the previous location
Ctrl + Alt + b         : Jump to implementation

Ctrl + F8              : breakpoint on
Ctrl + Shift + F8      : breakpoint options
Shift + F9             : debug
F8                     : continue to the next breakpoint
Shift + F8             : return to the previous breakpoint

Live templates         : soat, if, etc.
Ctrl shift +  w        : increase selection (custom to avoid problems with Ctrl + ww)
Ctrl + alt + t         : surround with (also with your own templates)

vsplit                 : split the windows
Ctrl + w + w           : to cycle between windows
Ctrl + w + o           : to back to ONLY one window

## Custom
Ctrl + 0               : reset font
Ctrl + Shift + plus    : increase font
Ctrl + Shift + minus   : decrease font
F11                    : full screen
Shift + F11            : presentation mode
Ctrl + Shift + G       : Refresh all external projects (gradle)

