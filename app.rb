# By Henrik Nyh <henrik@nyh.se> 2010-12-18 under the MIT license.

require "open-uri"
require "rubygems"
require "sinatra"
require "sinatra/sequel"
require "haml"
require "sass"
require "json"

set :database, (ENV['DATABASE_URL'] || 'sqlite:///tmp/delpin3.db')

migration "create mappings" do
  database.create_table :mappings do
    primary_key :id
    text        :delicious
    text        :pinboard
    timestamp   :created_at, :null => false
    timestamp   :updated_at, :null => false

    index :delicious, :unique => true
  end
end

class Mapping < Sequel::Model
end


set :haml, :format => :html5, :attr_wrapper => %{"}
set :views, lambda { root }

get '/' do
  if @name = params[:name]
    @friends = friends_of(@name)
  end

  render_list
end

post '/' do
  delicious = params[:delicious].to_s.downcase
  pinboard = params[:pinboard].to_s.downcase
  pinboard = delicious if pinboard.empty?
  if delicious.empty?
    return "Please provide names."
  end
  old_mapping = Mapping[:delicious => delicious]
  if old_mapping
    old_mapping.update(:pinboard => pinboard, :updated_at => Time.now)
  else
    Mapping.create(
      :delicious => delicious,
      :pinboard => pinboard,
      :created_at => Time.now, :updated_at => Time.now
    )
  end

  render_list
end

get '/export.json' do
  content_type :json
  Mapping.select(:delicious, :pinboard).order(:delicious).map { |m| m.values }.to_json
end

def render_list
  @mappings = Mapping.limit(10).order(:updated_at).reverse
  haml :index
end


def friends_of(name)
  data = open("http://feeds.delicious.com/v2/json/networkmembers/#{name}").read
  usernames = JSON.parse(data).map { |values| values["user"] }
  usernames
rescue OpenURI::HTTPError
  []
end

def h(text)
  Rack::Utils.escape(text)
end
