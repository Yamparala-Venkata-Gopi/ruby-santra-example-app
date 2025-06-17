require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'

# myapp.rb
get '/' do
  output = "Hello world! Version 3. Now with test-suite! </br></br>"
  output += "Available routes: </br>"
  output += "<a href='/google'>/google</a> - Google homepage </br>"
  output += "<a href='/amazon'>/amazon</a> - Amazon homepage </br>"
  output += "<a href='/walmart'>/walmart</a> - Walmart homepage </br>"
  output += "<a href='/nike'>/nike</a> - Nike homepage </br>"
  output += "<a href='/github'>/github</a> - GitHub homepage </br></br>"
  
  env_string = JSON.pretty_generate(ENV.to_a).gsub!("\n",'</br>')
  output += "Environment: </br> #{env_string} </br>"
  output
end

get "/google" do
  HTTParty.get('http://google.com', follow_redirects: true).body
end

get "/amazon" do
  HTTParty.get('https://amazon.com', follow_redirects: true).body
end

get "/walmart" do
  HTTParty.get('https://walmart.com', follow_redirects: true).body
end

get "/nike" do
  HTTParty.get('https://nike.com', follow_redirects: true).body
end

get "/github" do
  HTTParty.get('https://github.com', follow_redirects: true).body
end

# Catch-all route for handling any unmatched requests
get '*' do
  status 404
  content_type 'text/plain'
  "404 - Page not found"
end
