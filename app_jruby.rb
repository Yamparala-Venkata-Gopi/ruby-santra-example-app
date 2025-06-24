require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'

# Use jruby-openssl for consistent OpenSSL experience
require 'openssl'

configure do
  set :bind, '0.0.0.0'  # Allow external connections
  set :port, 4567       # HTTP port
  set :ssl_port, 4568   # HTTPS port
end

get '/' do
  ruby_impl = RUBY_PLATFORM == 'java' ? 'JRuby' : 'MRI Ruby'
  ssl_impl = RUBY_PLATFORM == 'java' ? 'jruby-openssl (Bouncy Castle)' : 'OpenSSL'
  
  output = "Hello world! Version 3 on #{ruby_impl}! Now with test-suite! </br></br>"
  output += "Available routes: </br>"
  output += "<a href='/google'>/google</a> - Google homepage </br>"
  output += "<a href='/amazon'>/amazon</a> - Amazon homepage </br>"
  output += "<a href='/walmart'>/walmart</a> - Walmart homepage </br>"
  output += "<a href='/nike'>/nike</a> - Nike homepage </br>"
  output += "<a href='/github'>/github</a> - GitHub homepage </br></br>"
  
  # Show both HTTP and HTTPS URLs
  output += "🔗 Access URLs: </br>"
  output += "HTTP: <a href='http://#{request.host}:4567'>http://#{request.host}:4567</a> </br>"
  output += "HTTPS: <a href='https://#{request.host}:4568'>https://#{request.host}:4568</a> </br></br>"
  
  output += "🔧 Ruby Implementation: #{ruby_impl} (#{RUBY_VERSION}) </br>"
  output += "🔐 SSL Implementation: #{ssl_impl} </br>"
  output += "🔐 OpenSSL Version: #{OpenSSL::OPENSSL_VERSION rescue 'N/A'} </br></br>"
  
  env_string = JSON.pretty_generate(ENV.to_a).gsub("\\n",'</br>')
  output += "Environment: </br> #{env_string} </br>"
  output
end

# External domain proxy routes
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

# Catch-all route for 404s
get '*' do
  status 404
  content_type 'text/plain'
  "404 - Resource not found"
end

# SSL Certificate generation using OpenSSL (works with both MRI and jruby-openssl)
def generate_ssl_certs
  cert_file = 'server.crt'
  key_file = 'server.key'
  
  unless File.exist?(cert_file) && File.exist?(key_file)
    puts "📜 Generating SSL certificates using OpenSSL..."
    
    begin
      # Generate RSA private key
      key = OpenSSL::PKey::RSA.new(2048)
      
      # Create certificate
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 0x0
      cert.not_before = Time.now
      cert.not_after = Time.now + (365 * 24 * 60 * 60) # 1 year
      cert.public_key = key.public_key
      
      # Certificate subject
      subject = "/C=US/ST=Local/L=Local/O=Sinatra App/CN=localhost"
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      
      # Sign certificate
      cert.sign(key, OpenSSL::Digest::SHA256.new)
      
      # Write files
      File.write(key_file, key.to_pem)
      File.write(cert_file, cert.to_pem)
      
      ssl_impl = RUBY_PLATFORM == 'java' ? 'jruby-openssl (Bouncy Castle)' : 'OpenSSL'
      puts "✅ SSL certificates generated using #{ssl_impl}: #{cert_file}, #{key_file}"
      
    rescue => e
      puts "❌ Failed to generate SSL certificates: #{e.message}"
      puts "   This might indicate an issue with the OpenSSL implementation"
    end
  else
    puts "✅ SSL certificates already exist: #{cert_file}, #{key_file}"
  end
  
  [cert_file, key_file]
end

# Main execution
if __FILE__ == $0
  cert_file, key_file = generate_ssl_certs
  
  ruby_impl = RUBY_PLATFORM == 'java' ? 'JRuby' : 'MRI Ruby'
  ssl_impl = RUBY_PLATFORM == 'java' ? 'jruby-openssl (Bouncy Castle)' : 'OpenSSL'
  
  puts "🌐 Starting Sinatra app on #{ruby_impl} with #{ssl_impl}..."
  puts "📍 HTTP:  http://0.0.0.0:4567"
  puts "📍 HTTPS: https://0.0.0.0:4568 (self-signed cert)"
  puts ""
  puts "💡 To enable HTTPS with Puma, run:"
  puts "   bundle exec puma -b 'tcp://0.0.0.0:4567' -b 'ssl://0.0.0.0:4568?key=#{key_file}&cert=#{cert_file}' config.ru"
  puts ""
  puts "Starting HTTP server on port 4567..."
end 