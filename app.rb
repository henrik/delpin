# By Henrik Nyh <henrik@nyh.se> 2010-12-18 under the MIT license.

require "rubygems"
require "sinatra"
require "haml"
require "sass"

set :haml, :format => :html5, :attr_wrapper => %{"}
set :views, lambda { root }

get '/' do
  haml :index
end
