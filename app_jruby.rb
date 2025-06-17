require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'httparty'

# JRuby-specific SSL handling
if RUBY_PLATFORM == 'java'
  # JRuby uses Java's SSL implementation
  require 'java'
  java_import 'java.security.KeyStore'
  java_import 'java.security.cert.X509Certificate'
  java_import 'javax.net.ssl.KeyManagerFactory'
  java_import 'javax.net.ssl.SSLContext'
  puts "🔧 Running on JRuby - using Java SSL implementation"
else
  # Standard Ruby (MRI) - use OpenSSL
  require 'openssl'
  puts "🔧 Running on MRI Ruby - using OpenSSL"
end

# SSL Configuration
configure do
  set :bind, '0.0.0.0'  # Allow external connections
  set :port, 4567       # HTTP port
  set :ssl_port, 4568   # HTTPS port
end

get '/' do
  ruby_impl = RUBY_PLATFORM == 'java' ? 'JRuby' : 'MRI Ruby'
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
  output += "🔐 SSL Support: #{RUBY_PLATFORM == 'java' ? 'Java JSSE' : 'OpenSSL'} </br></br>"
  
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

# SSL Certificate generation - works for both MRI and JRuby
def generate_ssl_certs_universal
  cert_file = 'server.crt'
  key_file = 'server.key'
  
  unless File.exist?(cert_file) && File.exist?(key_file)
    puts "📜 Generating SSL certificates..."
    
    if RUBY_PLATFORM == 'java'
      # JRuby: Use system openssl or Java keytool
      puts "🔧 JRuby detected - using system OpenSSL command"
      system("openssl req -x509 -newkey rsa:2048 -keyout #{key_file} -out #{cert_file} -days 365 -nodes -subj '/CN=localhost'")
    else
      # MRI Ruby: Use OpenSSL gem
      puts "🔧 MRI Ruby detected - using OpenSSL gem"
      key = OpenSSL::PKey::RSA.new(2048)
      
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 0x0
      cert.not_before = Time.now
      cert.not_after = Time.now + (365 * 24 * 60 * 60) # 1 year
      cert.public_key = key.public_key
      
      subject = "/C=US/ST=Local/L=Local/O=Sinatra App/CN=localhost"
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      
      cert.sign(key, OpenSSL::Digest::SHA256.new)
      
      File.write(key_file, key.to_pem)
      File.write(cert_file, cert.to_pem)
    end
    
    if File.exist?(cert_file) && File.exist?(key_file)
      puts "✅ SSL certificates generated: #{cert_file}, #{key_file}"
    else
      puts "❌ Failed to generate SSL certificates"
    end
  end
  
  [cert_file, key_file]
end

# Main execution
if __FILE__ == $0
  cert_file, key_file = generate_ssl_certs_universal
  
  ruby_impl = RUBY_PLATFORM == 'java' ? 'JRuby' : 'MRI Ruby'
  puts "🌐 Starting Sinatra app on #{ruby_impl} with HTTP and HTTPS support..."
  puts "📍 HTTP:  http://0.0.0.0:4567"
  puts "📍 HTTPS: https://0.0.0.0:4568 (self-signed cert)"
  puts ""
  puts "💡 To enable HTTPS with Puma, run:"
  puts "   bundle exec puma -b 'tcp://0.0.0.0:4567' -b 'ssl://0.0.0.0:4568?key=#{key_file}&cert=#{cert_file}' config.ru"
  puts ""
  puts "Starting HTTP server on port 4567..."
end 