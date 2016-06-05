require 'sinatra/base'

module ProxyBot
  class Web < Sinatra::Base
    get '/' do
      'I do stuff'
    end
  end
end
