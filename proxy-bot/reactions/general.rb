module ProxyBot
  module Commands
    class General < SlackRubyBot::Commands::Base

      def self.extract_message_data(data)
        submatch = /^say&gt;\s?\<(?<imtype>[#@])(?<recipient>[\w-]*)\> (?<message>.*)/.match(data.text)
        url_matcher = /(\<(https?:\/\/[\S]+)\>)/
        link_match = url_matcher.match(submatch['message'])
        text = submatch['message'].gsub(url_matcher, '\2')
        message_data = { recipient: submatch['recipient'], text: text }
        message_data[:im_type] = submatch['imtype']
        if link_match && link_match.length > 2
          message_data[:link] = link_match[2]
        end
        message_data
      end

      match /(.)*/ do |client, data, _match|
        if data.channel[0] == 'D'
          if ENV['PUPETEER_ID']
            puppeteer_channel = client.web_client.im_open user: ENV['PUPETEER_ID']
            user_info = client.web_client.users_info user: data.user
            text = "@#{user_info.user.name} says:\n--\n```\n#{data.text}\n```"
            client.say(text: text, channel: puppeteer_channel['channel']['id'])
          end
          if data.text.start_with? 'say&gt;'
            message_data = ProxyBot::Commands::General.extract_message_data data
            if message_data[:im_type] == '#'
              message_data[:channel] = message_data[:recipient]
              if message_data[:channel] && message_data[:text]
                client.say(message_data)
              else
                client.say(channel: data.channel, text: '?')
              end
            else
              new_channel = client.web_client.im_open user: message_data[:recipient]
              message_data[:channel] = new_channel['channel']['id']
              if message_data[:channel] && message_data[:text]
                client.say(message_data)
              else
                client.say(user: data.user, text: '?')
              end
            end
          end
      end
      end
    end
  end
end
