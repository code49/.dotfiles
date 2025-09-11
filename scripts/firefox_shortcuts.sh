#!/bin/sh
#
# Script for interpreting (and subsequently opening) firefox windows via shortcuts.
#

# stop execution if we reach a non-zero exit code
set -e

# grab shortcut string as a variable
SHORTCUT=$1

# function for opening firefox with a given profile + URL combo
open_ff() {

  # grab desired profile, url as arguments
  PROFILE=$1
  URL=$2

  # open firefox (detached) with given profile and arguments
  nohup /run/current-system/sw/bin/firefox -p $PROFILE -new-window $URL &!

  # finished with script
  exit 0
  
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
    nohup /run/current-system/sw/bin/firefox -private-window & disown ; exit
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
    open_ff dchan-personal 'calendar.google.com'
  ;;

  # personal email
  "gmail")
    open_ff dchan-personal 'mail.google.com/mail/u/0/#inbox'
  ;;

  # cmu email
  "cmail")
    open_ff dchan2-cmu 'mail.google.com/mail/u/0/#inbox'
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

  # notion
  "no")
    open_ff dchan-personal 'www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566'
  ;;
  
  # overleaf-personal
  "olp")
    open_ff dchan-personal 'https://www.overleaf.com/project'
  ;;

  # overleaf-cmu
  "olc")
    open_ff dchan2-cmu 'https://www.overleaf.com/project'
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
  "tg")
    open_ff dchan-personal 'web.telegram.org'
  ;;

  # discord
  "dd")
    open_ff dchan-personal 'discord.com/channels/@me'
  ;;

  # slack (slack is *exceptionally* annoying)

  # cia buggy
  "cia")
    open_ff dchan2-cmu 'app.slack.com/client/T15JH0RJ8'
  ;;

  # 18-100
  "100")
    open_ff dchan2-cmu 'app.slack.com/client/T0992RLKWCX/C0992RM15RD'
  ;;

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

  # photos
  "ph")
    open_ff dchan-personal 'photos.google.com'
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



