# By Henrik Nyh <henrik@nyh.se> 2010-12-18 under the MIT license.

require "open-uri"
require "rubygems"
require "sinatra"
require "haml"
require "sass"
require "json"
require "sequel"

Sequel.connect(ENV['DATABASE_URL'] || 'sqlite:///tmp/delpin.db')

set :haml, :format => :html5, :attr_wrapper => %{"}
set :views, lambda { root }

get '/' do
  if @name = params[:name]
    @friends = friends_of(@name)
  end

  @mappings = []

  haml :index
end

def friends_of(name)
  data = open("http://feeds.delicious.com/v2/json/networkmembers/#{name}").read
  usernames = JSON.parse(data).map { |values| values["user"] }
  usernames
end

def h(text)
  Rack::Utils.escape(text)
end
