#!/usr/bin/env jruby

puts "🧪 Testing JRuby with jruby-openssl"
puts "===================================="

begin
  # Test basic JRuby functionality
  puts "💎 JRuby Version: #{JRUBY_VERSION}"
  puts "🏭 Platform: #{RUBY_PLATFORM}"
  puts "☕ Java Version: #{java.lang.System.getProperty('java.version')}"
  
  # Test jruby-openssl
  require 'openssl'
  puts "✅ OpenSSL loaded successfully!"
  puts "📋 OpenSSL Version: #{OpenSSL::OPENSSL_VERSION}"
  
  # Test key generation
  puts ""
  puts "🔐 Testing RSA key generation..."
  key = OpenSSL::PKey::RSA.new(1024)
  puts "✅ RSA key generated (#{key.n.num_bits} bits)"
  
  # Test certificate creation
  puts ""
  puts "📜 Testing certificate creation..."
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 0x0
  cert.not_before = Time.now
  cert.not_after = Time.now + (365 * 24 * 60 * 60)
  cert.public_key = key.public_key
  
  subject = "/C=US/ST=Test/L=Test/O=Test/CN=localhost"
  cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
  cert.sign(key, OpenSSL::Digest::SHA256.new)
  
  puts "✅ Certificate created successfully!"
  puts "📋 Subject: #{cert.subject}"
  puts "📅 Valid until: #{cert.not_after}"
  
  # Test HTTParty (for external requests) - with bundle environment
  puts ""
  puts "🌐 Testing HTTParty with bundle environment..."
  
  # Set bundle environment
  ENV['BUNDLE_GEMFILE'] = 'Gemfile.jruby'
  
  begin
    require 'bundler/setup'
    require 'httparty'
    puts "✅ HTTParty loaded successfully!"
  rescue LoadError => e
    puts "⚠️  HTTParty not available: #{e.message}"
    puts "   This is okay - run ./setup_jruby.sh to install all gems"
  end
  
  # Test Sinatra loading
  puts ""
  puts "🎯 Testing Sinatra app loading..."
  begin
    require './app_jruby.rb'
    puts "✅ Sinatra app loaded successfully!"
  rescue LoadError => e
    puts "⚠️  Sinatra app not available: #{e.message}"
    puts "   Run ./setup_jruby.sh to install missing gems"
  end
  
  puts ""
  puts "🎉 Core JRuby with jruby-openssl is working correctly!"
  puts ""
  puts "🚀 Ready to run:"
  puts "   ./start_jruby.sh  # Start the server"
  puts "   BUNDLE_GEMFILE=Gemfile.jruby jruby -S bundle exec ruby app_jruby.rb  # Run with bundle"
  
rescue => e
  puts "❌ Test failed: #{e.message}"
  puts "📋 Error class: #{e.class}"
  puts ""
  puts "🔧 Please run the setup script:"
  puts "   ./setup_jruby.sh"
  exit 1
end 