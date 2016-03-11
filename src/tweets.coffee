# Description:
#   Create and search for tweets on Twitter.
#
# Dependencies:
#   "twit": "1.1.x"
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWITTER_ACCESS_TOKEN
#   HUBOT_TWITTER_ACCESS_TOKEN_SECRET
#
# Commands:
#   hubot twitter tweet <text> - Post to twitter
#   hubot tweet <text> - Post to twitter
#
# Author:
#   gkoo
#

Twit = require "twit"

config =
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token: process.env.HUBOT_TWITTER_ACCESS_TOKEN
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET

twit = undefined

getTwit = ->
  unless twit
    twit = new Twit config
  return twit

doTweet = (msg, tweet, robot) ->
  return if !tweet
  tweetObj = status: tweet
  twit = getTwit()
  if robot.auth.hasRole(msg.envelope.user, "twitter")
    twit.post 'statuses/update', tweetObj, (err, reply) ->
      if err
        msg.send "Error sending tweet!"
      else
        username = reply?.user?.screen_name
        id = reply.id_str
        if (username && id)
          msg.send "https://www.twitter.com/#{username}/status/#{id}"
  else
    msg.send "Error sending tweet!"

module.exports = (robot) ->
  robot.respond /twitter (\S+)\s*(.+)?/i, (msg) ->
    unless config.consumer_key
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
      return
    unless config.consumer_secret
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
      return
    unless config.access_token
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN environment variable."
      return
    unless config.access_token_secret
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN_SECRET environment variable."
      return

    command = msg.match[1]

    if (command == 'tweet')
      doTweet(msg, msg.match[2], robot)

  robot.respond /tweet\s*(.+)?/i, (msg) ->
    doTweet(msg, msg.match[1], robot)
