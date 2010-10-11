require 'sinatra/base'
require "bundler"
Bundler.setup(:default)
Bundler.require(:default)
require 'ostruct'

PRJ_DIR = File.absolute_path(File.dirname(__FILE__))
require_all Dir.glob("#{File.join(PRJ_DIR, "lib", "*.rb")}")

class LcwaApp < Sinatra::Base
  set :views, 'views/'
  set :public, 'public/'
  set :static, true
  set :sessions, false
  set :show_exceptions, true # or maybe not?
  configure do
    config_file = File.join(PRJ_DIR, "config", "config.json")
    config_data = {}
    if File.exists?(config_file)
      config_data = JSON.parse(File.read(config_file))
    end
    ext_config = File.join(PRJ_DIR, "config", "config_#{LcwaApp.environment}")
    if File.exists?(ext_config)
      config_data.merge! JSON.parse(File.read(config_file))
    end
    set :config, OpenStruct.build_recursive(config_data)
  end

  get '/' do
    redirect "/index.html"
  end

  get '/items.json' do
    content_type 'application/json', :charset => 'utf-8'
    {
       "abc" => {:title => "thing one", :body => "body one"},
       "def" => {:title => "thing two", :body => "body two"}
    }.to_json
  end

end

