require_relative '../lib/jumbalya.rb'

require 'sinatra/base'

class Jumbalya::Server < Sinatra::Base

  get '/' do
    @password = 'aPassword'
    @string = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    @encrypted = Jumbalya.encrypt(@string, @password)
    @unencrypted = Jumbalya.unencrypt(@encrypted, @password)
    @encrypted = Jumbalya.encrypt(@string, @password)
    @wrong = Jumbalya.unencrypt(@encrypted, 'wrong')
    erb :home
  end

end