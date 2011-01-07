require 'sinatra/base'
require "bundler"
Bundler.setup(:default)
Bundler.require(:default)

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
    config_data = Hashie::Mash.new
    if File.exists?(config_file)
      config_data.deep_update JSON.parse(File.read(config_file))
    end
    ext_config = File.join(PRJ_DIR, "config", "config_#{LcwaApp.environment}.json")
    if File.exists?(ext_config)
      config_data.deep_update JSON.parse(File.read(ext_config))
    end
    set :config, config_data
  end

  before do
    Mongomatic.db = Mongo::Connection.new(LcwaApp.config.mongo_connection).db(LcwaApp.config.mongo_db)
    $stderr.puts "connected to #{LcwaApp.config.mongo_db}"
    if Widget.count == 0
      Widget.populate_sample_data(LcwaApp.config.initial_widgets)
    end
  end

  get '/' do
    redirect "/index.html"
  end

  def with_error_handler(context)
    begin
      yield
    rescue Exception => e
      $stderr.puts "exception #{e.class}:#{e.message} in #{context} : backtrace:\n#{e.backtrace.join("\n")}"
      halt 500, {'Content-Type' => 'application/json'}, {:context => context, :message => "#{e.class} : #{e.message}"}.to_json
    end
  end

  def json_error(code, context, message)
    $stderr.puts "error code #{code} in #{context}: #{message}"
    halt code, {'Content-Type' => 'application/json'}, {:context => context, :message => message}.to_json
  end

  get '/widgets.json' do
    content_type 'application/json', :charset => 'utf-8'
    with_error_handler("accessing widgets") do
      sleep 2 # so we can see the loading status
      return Widget.all.collect {|w| w.to_hash}.to_json
    end
  end

  get '/widget/:id.json' do
    content_type 'application/json', :charset => 'utf-8'
    widget_id = params[:id]
    with_error_handler("accessing widget #{widget_id}") do
      sleep 1 # so we can see loading status
      widget = Widget.find_one(:_id => widget_id)
      if widget.nil?
        json_error 400, "accessing widgets", "No widget with id #{widget_id}"
      end
      return widget.to_hash.to_json
    end
  end
end

