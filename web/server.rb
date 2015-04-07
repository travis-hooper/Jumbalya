require_relative '../lib/jumbalya.rb'

require 'json'
require 'sinatra/base'

class Jumbalya::Server < Sinatra::Base

  get '/' do
    erb :home
  end

  post '/jumbalya' do
    password = params[:password]
    if password.match(/(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}/)
      jumbalya = Jumbalya.encrypt(params[:jText], password)
      halt 200, jumbalya
    else
      halt 400, 'Password does not meet validation requirements.'
    end
  end

  post '/unjumbalya' do
    unjumbalya = Jumbalya.unencrypt(params[:jText], params[:password])
    halt 200, unjumbalya
  end

end
