require "rss"
require "open-uri"

require_relative "rss/new_relic_message"

class Rss
  include Cinch::Plugin
  
  set :prefix, lambda{ |m| Regexp.new("(?=.*" + m.bot.nick + ")(?=.*rss)" )}

  match /(?=.*url)/, method: :url
  match /(?=.*help)/, method: :help
  match /(?=.*list)/, method: :list

  listen_to :join, method: :on_join

  def on_join(m)
    m.reply "Hello!"

    # check every 5min the rss feed and print the new item if needed
    if m.user.nick == bot.nick
      while true do
        open(bot.config.plugins.rss["url"]) do |rss|
          feed = RSS::Parser.parse(rss, false)
          feed.items.each do |item|
            if item.pubDate.seconds_ago < bot.config.plugins.rss["polling_period"]
              message = NewRelicMessage.new(item)
              m.reply message
            end
          end
        end
        sleep bot.config.plugins.rss["polling_period"]
      end

    # personal message last items on connection
    else
      messages = []
      open(bot.config.plugins.rss["url"]) do |rss|
        feed = RSS::Parser.parse(rss, false)
        feed.items.each_with_index do |item, index|
          if item.pubDate.hours_ago < bot.config.plugins.rss["freshness"]
            message = NewRelicMessage.new(item)
            messages << message
          end
        end
      end

      unless messages.empty?
        m.user.send "Hi #{m.user.nick}, you might be interested on these news :"
        messages.each do |message|
          m.user.send message
        end
      end
    end
  end

  def help(m)
    m.reply "Don't feel lost here are the commands you can try :"
    m.reply " - (?=.*#{bot.nick})(?=.*rss)(?=.*list) : will list all the item of the RSS feed"
    m.reply " example '#{bot.nick}, can you print me the list of items of the rss feed, please?'"
    # m.reply " - (?=.*#{bot.nick})(?=.*rss)(?=.*url) : gives the url of the rss feed"
    m.reply " - (?=.*#{bot.nick})(?=.*rss)(?=.*help) : gives you this help \\o/"
    m.reply ""
  end

  def list(m)
    m.reply "#{m.user.nick}, here is the list of RSS Item :"
    open(bot.config.plugins.rss["url"]) do |rss|
      feed = RSS::Parser.parse(rss, false)
      m.reply "Title: #{feed.channel.title}"
      feed.items.each do |item|
        message = NewRelicMessage.new(item)
        m.reply message
      end
    end
  end

  # def url(m)
  #   m.reply "The RSS url used is : #{bot.config.plugins.rss["url"]}"
  # end

end
