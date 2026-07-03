#!/usr/bin/env bash
#
# Script for interpreting (and subsequently opening) firefox windows via shortcuts.
#

# stop execution if we reach a non-zero exit code
set -e

# Path to firefox binary
FIREFOX_BIN="/run/current-system/sw/bin/firefox"
if [ ! -f "$FIREFOX_BIN" ]; then
  FIREFOX_BIN=$(command -v firefox || echo "firefox")
fi

# grab shortcut string as a variable
SHORTCUT=$1

# Show help message if requested
if [ "$SHORTCUT" = "-h" ] || [ "$SHORTCUT" = "--help" ]; then
  cat <<EOF
Firefox Shortcut Opener (ff)

Usage:
  ff <shortcut>     Launch a site/profile directly
  ff                Open interactive fuzzy selector (fzf)
  ff -h | --help    Show this help message

Categories & Shortcuts:
  [CMU] Academic / Slack / Tools:
    c               CMU profile, Canvas
    gs              Gradescope
    pz              Piazza (legacy)
    cmail           CMU Gmail Inbox
    ccal            CMU Google Calendar
    s3              CMU S3 Portal (SIO)
    cprint          CMU Printing user summary
    ghc             CMU GitHub
    olc             CMU Overleaf projects
    dss/dsc/ds3d    Desmos (Scientific / Calculator / 3D)
    cia/io          Academic Slack Workspaces (CIA Buggy, IO Harness)

  [Personal] Personal / Social / Media:
    p               Personal profile default, davidlechan.dev
    drive           Google Drive
    cal             Google Calendar week view
    gmail/gmaila    Gmail Inbox (Primary / Alt)
    ghp             Personal GitHub
    res             Resume PDF (local)
    no              Notion workspace
    olp/olr         Personal Overleaf (Projects / Resume)
    li              LinkedIn Feed
    msg/ig/wa       Messaging (Messages, Instagram, WhatsApp)
    sfy/yt/yttv     Media (Spotify, YouTube, YouTube TV)
    mlbtv/cl/ph/mt  Hobbies (MLB.TV, Caught Looking, Photos, Monkeytype)
    vlr/sfg         Sports (VLR.gg, SF Giants ESPN)
    gpt/gem/gns     AI & News (ChatGPT, Gemini, Google News)

  [General] Global Utilities:
    pri             Launch personal profile in private window
    mails           Open all three email inboxes (personal x2, CMU)
EOF
  exit 0
fi

# If no shortcut was provided, use fzf to select one
if [ -z "$SHORTCUT" ]; then
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed, and no shortcut was specified." >&2
    exit 127
  fi

  CHOICE=$(cat <<EOF | grep -v '^[[:space:]]*#' | fzf --prompt="Select Firefox Shortcut: " --header="Press [Enter] to open, [Esc] to cancel." --height=40% --layout=reverse --border
[CMU]      c - CMU (Canvas)
[CMU]      gs - Gradescope (CMU)
[CMU]      pz - Piazza (CMU)
[CMU]      cmail - Gmail (CMU)
[CMU]      ccal - Google Calendar (CMU)
[CMU]      s3 - CMU S3 Portal (SIO)
[CMU]      cprint - CMU Printer Summary
[CMU]      ghc - GitHub (CMU)
[CMU]      olc - Overleaf (CMU)
[CMU]      dss - Desmos Scientific Calculator
[CMU]      dsc - Desmos Graphing Calculator
[CMU]      ds3d - Desmos 3D Calculator
[CMU]      cia - Slack (CIA Buggy)
# [CMU]      100 - Slack (18-100)
[CMU]      io - Slack (IO Harness)
[Personal] p - Personal Profile Default (davidlechan.dev)
[Personal] drive - Google Drive (Personal)
[Personal] cal - Google Calendar (Personal)
[Personal] gmail - Gmail (Personal)
[Personal] gmaila - Gmail (Personal Alt)
[Personal] ghp - GitHub (Personal)
[Personal] res - Resume PDF
[Personal] no - Notion Workspace
[Personal] olp - Overleaf (Personal)
[Personal] olr - Overleaf Resume Project
[Personal] li - LinkedIn Feed
[Personal] msg - Google Messages for Web
[Personal] ig - Instagram Direct Inbox
[Personal] wa - WhatsApp Web
# [Personal] tg - Telegram Web
# [Personal] dd - Discord Client
[Personal] sfy - Spotify Web Player
[Personal] yt - YouTube
[Personal] yttv - YouTube TV
[Personal] mlbtv - MLB.TV
[Personal] cl - Caught Looking App
[Personal] ph - Google Photos
[Personal] mt - Monkeytype
[Personal] vlr - VLR.gg
[Personal] sfg - SF Giants ESPN Page
[Personal] gpt - ChatGPT
[Personal] gem - Gemini
[Personal] gns - Google News
[General]  pri - Private Window
[General]  mails - All Email Accounts (Personal & CMU)
EOF
  )

  # If user canceled fzf selection, exit 130 (SIGINT standard) to keep terminal open
  if [ -z "$CHOICE" ]; then
    echo "Cancelled selection."
    exit 130
  fi

  # Extract shortcut (second word after the category tag)
  SHORTCUT=$(echo "$CHOICE" | awk '{print $2}')
fi

# function for opening firefox with a given profile + URL combo
open_ff() {
  local profile="$1"
  local url="$2"

  # open firefox (detached) with given profile and arguments, redirect output to prevent nohup.out
  nohup "$FIREFOX_BIN" -p "$profile" -new-window "$url" >/dev/null 2>&1 &
}

# cases for mapping shortcuts to sites
case $SHORTCUT in

  # --- basic profile shortcuts ---

  # cmu profile ; default to opening canvas
  "c")
    open_ff dchan2-cmu 'canvas.cmu.edu'
  ;;

  # personal profile ; default to opening personal site
  "p")
    open_ff dchan-personal 'davidlechan.dev'
  ;;

  # private window (personal profile) ; 
  "pri")
    nohup "$FIREFOX_BIN" -private-window >/dev/null 2>&1 &
  ;;

  # --- url-specific shortcuts ---

  # work-y stuff 
  
  # gradescope
  "gs")
    open_ff dchan2-cmu 'gradescope.com'
  ;;

  # piazza ; no default class selected
  "pz")
    open_ff dchan2-cmu 'https://legacy.piazza.com/class/mernozt93b66ii'
  ;;

  # personal drive
  "drive")
    open_ff dchan-personal 'drive.google.com'
  ;;

  # personal calendar
  "cal")
    open_ff dchan-personal 'https://calendar.google.com/calendar/u/0/r/week'
  ;;

  # personal email
  "gmail")
    open_ff dchan-personal 'mail.google.com/mail/u/0/#inbox'
  ;;

  # personal-alt email
  "gmaila")
    open_ff dchan-personal 'mail.google.com/mail/u/1/#inbox'
  ;; 

  # cmu email
  "cmail")
    open_ff dchan2-cmu 'mail.google.com/mail/u/0/#inbox'
  ;;

  # all (relevant) emails
  "mails")
    open_ff dchan-personal 'mail.google.com/mail/u/1/#inbox'
    open_ff dchan2-cmu 'mail.google.com/mail/u/0/#inbox'
    open_ff dchan-personal 'mail.google.com/mail/u/0/#inbox'
  ;;

  # cmu s3 portal
  "s3")
    open_ff dchan2-cmu 'https://s3.andrew.cmu.edu/sio/mpa/'
  ;;

  # cmu printer
  "cprint")
    open_ff dchan2-cmu 'https://printing.andrew.cmu.edu/app?service=page/UserSummary'
  ;;

  # cmu calendar
  "ccal")
    open_ff dchan2-cmu 'calendar.google.com'
  ;;

  # desmos (scientific, grapher, 3d)
  "dss")
    open_ff dchan2-cmu 'desmos.com/scientific'
  ;;

  "dsc")
    open_ff dchan2-cmu 'desmos.com/calculator'
  ;;

  "ds3d")
    open_ff dchan2-cmu 'desmos.com/3d'
  ;;

  # personal github
  "ghp")
    open_ff dchan-personal 'github.com'
  ;;

  # cmu github
  "ghc")
    open_ff dchan2-cmu 'github.com'
  ;;

  # github-resume-pdf
  "res")
    open_ff dchan-personal ~/personal-work/resume/DavidChan_Resume.pdf
  ;;

  # notion
  "no")
    open_ff dchan-personal 'www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566'
  ;;
  
  # overleaf-personal
  "olp")
    open_ff dchan-personal 'https://www.overleaf.com/project'
  ;;

  # overleaf-resume
  "olr")
    open_ff dchan-personal 'https://www.overleaf.com/project/688a6610cecbb603397bf8ff'
  ;;

  # overleaf-cmu
  "olc")
    open_ff dchan2-cmu 'https://www.overleaf.com/project'
  ;;
  
  # linkedin (yikes)
  "li")
    open_ff dchan-personal 'https://www.linkedin.com/feed/' 
  ;;

  # messaging stuff
  
  # messages for web
  "msg")
    open_ff dchan-personal 'messages.google.com/web/conversations'
  ;;

  # instagram
  "ig")
    open_ff dchan-personal 'instagram.com/direct/inbox'
  ;;

  # whatsapp
  "wa")
    open_ff dchan-personal 'web.whatsapp.com'
  ;;

  # telegram
  # "tg")
  #   open_ff dchan-personal 'web.telegram.org'
  # ;;

  # discord
  # "dd")
  #   open_ff dchan-personal 'discord.com/channels/@me'
  # ;;

  # slack (slack is *exceptionally* annoying)

  # cia buggy
  "cia")
    open_ff dchan2-cmu 'app.slack.com/client/T15JH0RJ8'
  ;;

  # 18-100
  # "100")
  #   open_ff dchan2-cmu 'app.slack.com/client/T0992RLKWCX/C0992RM15RD'
  # ;;

  # IO harness group
  "io")
    open_ff dchan2-cmu 'app.slack.com/client/T070WJHP2E4'
  ;;

  # random other stuff

  # spotify
  "sfy")
    open_ff dchan-personal 'open.spotify.com'
  ;;

  # youtube
  "yt")
    open_ff dchan-personal 'youtube.com'
  ;;

  # youtube TV
  "yttv")
    open_ff dchan-personal 'tv.youtube.com'
  ;;

  # mlb TV
  "mlbtv")
    open_ff dchan-personal 'https://www.mlb.com/tv'
  ;;

  # caught looking
  "cl")
    open_ff dchan-personal 'www.caughtlooking.app'
  ;;

  # photos
  "ph")
    open_ff dchan-personal 'photos.google.com'
  ;;

  # monkeytype
  "mt")
    open_ff dchan-personal 'monkeytype.com'
  ;;

  # vlr
  "vlr")
    open_ff dchan-personal 'https://www.vlr.gg/'
  ;;

  # sfg espn page
  "sfg")
    open_ff dchan-personal 'espn.com/mlb/team/_/name/sf/san-francisco-giants'
  ;;

  # chatgpt 
  "gpt")
    open_ff dchan-personal 'chatgpt.com'
  ;;

  # google gemini
  "gem")
    open_ff dchan-personal 'gemini.google.com/app'
  ;;

  # google news
  "gns")
    open_ff dchan-personal 'news.google.com'
  ;;

  # --- default (no match) case ---

  # default ; shortcut not found, error
  *)
    exit 127
  ;;

esac

# exit with status 0 upon successfully matching a case and spawning the processes
exit 0
