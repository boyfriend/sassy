require "sinatra/base"
require "sass"
require "erb"
require "redis"

module Sassy
  class App < Sinatra::Base
    helpers do
      def redis
        @redis ||= Redis.new
      end

      def fetch(key)
        redis.get("sassy:stylesheets:#{key}")
      end

      def set(key, value)
        redis.set("sassy:stylesheets:#{key}", value)
      end

      def stylesheets
        redis.keys("sassy:stylesheets:*").map do |stylesheet_key|
          stylesheet_key.gsub("sassy:stylesheets:", '')
        end
      end

      def stylesheet(key)
        fetch(key) || "body { font-family: 'Comic Sans MS'; }"
      end
    end

    get "/" do
      erb :index
    end

    get "/edit/:stylesheet" do
      erb :edit
    end

    post "/save" do
      set(params[:stylesheet][:name], params[:stylesheet][:contents])
      redirect "/#{params[:stylesheet][:name]}.css"
    end

    get "/sassy.css" do
      scss :sassy
    end

    get "/:stylesheet.css" do
      scss stylesheet(params[:stylesheet])
    end
  end
end