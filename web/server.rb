require_relative '../lib/jumbalya.rb'

require 'sinatra/base'

class Jumbalya::Server < Sinatra::Base

  get '/' do
    @password = 'aPassword'
    @string = "This is a string of thext with random stuff in it I guess :)"
    @encrypted = Jumbalya.encrypt(@string, @password)
    @unencrypted = Jumbalya.unencrypt(@encrypted, @password)
    @encrypted = Jumbalya.encrypt(@string, @password)
    @wrong = Jumbalya.unencrypt(@encrypted, 'wrong')
    erb :home
  end

end