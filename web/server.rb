require_relative '../lib/jumbalya.rb'

require 'digest/sha1'
require 'json'
require 'sinatra/base'

class Jumbalya::Server < Sinatra::Base

  get '/' do
    erb :home
  end

  post '/jumbalya' do
    jumbalya = Jumbalya.encrypt(params[:jText], params[:password])
    halt 200, jumbalya
  end

  post '/unjumbalya' do
    unjumbalya = Jumbalya.unencrypt(params[:jText], params[:password])
    halt 200, unjumbalya
  end

end