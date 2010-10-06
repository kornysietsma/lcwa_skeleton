require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require './lcwa_app'

use Rack::ShowExceptions

run LcwaApp
