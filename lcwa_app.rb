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
    ext_config = File.join(PRJ_DIR, "config", "config_#{LcwaApp.environment}.json")
    if File.exists?(ext_config)
      config_data.merge! JSON.parse(File.read(ext_config))
    end
    set :config, OpenStruct.build_recursive(config_data)
  end

  def db
    @db ||= FakeDb.new(LcwaApp.config.db_file, LcwaApp.config.initial_db)
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
      return db.all_widgets.to_json
    end
  end

  get '/widget/:id.json' do
    content_type 'application/json', :charset => 'utf-8'
    widget_id = params[:id]
    with_error_handler("accessing widget #{widget_id}") do
      sleep 1 # so we can see loading status
      widget = db.widget(widget_id, :with_sprockets => true)
      if widget.nil?
        json_error 400, "accessing widgets", "No widget with id #{widget_id}"
      end
      return widget.to_json
    end
  end
end

