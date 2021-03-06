# VIM

set nowrap             : disable line wrapping
<C-v>                  : column selection (I to insert, ESC to apply)
<C-f>                  : in the command line, to search in the history
gq                     : format and break lines
gx                     : open link under the cursor

## Actions and motions

dw                     : Delete until the start of the next Word
de                     : Delete to the End of the current word
dtc                    : Delete To the next C
di”                    : Delete Inside the quotes
ce                     : Change to the End of the word
ci}                    : Change Inside the curly braces
cf,                    : Change Forward to and include the comma
ya’                    : Yank Around single quotes

f<char>                : moves to the first occurrence of <char> to the right
F<char>                : moves to the first occurrence of <char> to the left
t<char>                : moves right before the first occurrence of <char>
T<char>                : moves left before the first occurrence of <char>
;                      : repeats the last character motion in the original direction
,                      : repeats the last character motion in the opposite direction

O                      : Open above the line
gi                     : Go to the last place with Insert mode
g;                     : Go to the last place
gU{motion}             : example: gUaw -> word under cursor uppercase
d/palabro<cr>          : delete until "palabro"
%norm A*               : command to per each line (%) execute (norm) A* (add * in the end)

## Jump list

<C-o>                  : go to the previous jump
<C-i>                  : go to the next jump
%                      : go or back inside matching ),], or } .
]m                     : go to [count] next start of a method
]M                     : go to [count] next end of a method
[m                     : go to [count] previous start of a method
[M                     : go to [count] previous end of a method
changes                : command to list last changes in the document
mm                     : set mark `m`
'm                     : go to mark `m`

## Transform

U                      : uppercase in visual
<C-a>                  : increment a number
<C-x>                  : decrement a number
read !ls               : command to update buffer with ls output
3read !ls              : command to update buffer with ls output in line 3
[range]write !cowsay   : command to send the range to the command
[range]! cowsay        : command to send the range and update the buffer
!{motion}              : the same but in normal mode
%! sort -n | column -t : command to send all, sort it and tab it
%sort                  : command to sort (ideal for TODO)

## Copy and paste

"+y                    : copy to X clipboard
"ay                    : copy to the record a
"Ay                    : append to the record a
"ap                    : paste from the record a
"0p                    : paste last yanked test
reg                    : command to see the values of the registers

## Insert mode

<C-r>a                 : paste record a
<C-u>                  : delete all changes in the line
<C-w>                  : delete previous word
<C-y>                  : copy character from the above line
<C-e>                  : copy character from the below line
<C-n>                  : auto-completion
<C-p>                  : auto-completion

## Undo and redo

<C-r>                  : undos undo
U                      : undo all the line
earlier 24s            : command to undo the last 24s
later 12s              : command to move forward 12s

## Search

?                      : backwards search
noh                    : command to disable search highlighting
*                      : look for the work before the cursor, n for next
#                      : look for the work after the cursor, n for next
<C-f>                  : after / to open a search history window
gn                     : gn will jump forward to the next match of the last used search pattern and visually select it (you can prepend actions like c for change, cgn and repeat it with .)

## Replace

.\{-}                  : instead of `.*` to match only the first occurrence
%s/old/new/g           : command to change every occurrence in the whole file.
%s/old/new/gc          : command with a prompt whether to substitute or not.
&                      : repeat your last substitution on the current line.
g&                     : repeat the last substitution on all lines.

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
Ctrl+wJ                : moves the active to the top
Ctrl+wH                : moves the active split to the left
Ctrl+wK                : moves the active split to the bottom
Ctrl+wL                : moves the active split to right
Ctrl+wr                : rotates splits to the right/down
Ctrl+wR                : rotates splits to the left/up

## Tabs

gt                     : go to next tab
gT                     : go to previous tab
{i}gt                  : go to tab in position i
tabclose               : command to close tab

## navigate errors

lne                    : command to go to the next error
lnp                    : command to go to the previous error
lop                    : command to open the location list
lcl                    : command to close the location list
[l                     : previous error as :lprev
]l                     : next error as :lnext

## Buffers

ls                     : command to list buffers
ls!                    : command to list buffers included unlisted
buffer (b)             : command to change to buffer by name or number
<C-6>                  : move to the previous buffer

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

## state
mks state.vim          : save your current session state to state.vim
vim -S state.vim       : load session in state.vim
source state.vim       : load session in state.vim

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
w !sudo tee %          : command to write as root

## To check / doesn't work
%% shortcut            : pag 120
path                   : command pag 122 automatic detection
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

Live templates         : soat, if, etc.
Ctrl + alt + t         : surround with (also with your own templates)

Ctrl + Alt + left      : back to the previous location
Ctrl + Alt + b         : Jump to implementation

## Run and debub

Shift + F10            : run last configuration
Ctrl + Shift + F10     : run new configuration by default
Alt + Shift + F10      : run windows
Alt + 4                : go to Run window (or hide)
Shift + F9             : debug
Ctrl + F8              : breakpoint on
Ctrl + Shift + F8      : breakpoint options
F8                     : continue to the next breakpoint
Shift + F8             : return to the previous breakpoint

## ideavim

vsplit                 : split the windows
Ctrl + w + w           : to cycle between windows
Ctrl + w + o           : to back to ONLY one window

## Terminal

Alt+F12                : open/hide the terminal
Alt+Left/Right         : move between tabs
Ctrl + Enter           : execute the command in the IDE (git, mvn, etc.)

## Custom

Ctrl + 0               : reset font
Ctrl + Shift + plus    : increase font
Ctrl + Shift + minus   : decrease font
F11                    : full screen
Shift + F11            : presentation mode
Ctrl + Shift + G       : Refresh all external projects (gradle)
Ctrl shift +  w        : increase selection (custom to avoid problems with Ctrl + ww)

