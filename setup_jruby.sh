#!/bin/bash

echo "🚀 Setting up JRuby with jruby-openssl"
echo "======================================="

# Check JRuby installation
echo "🔍 Checking JRuby installation..."
if command -v jruby &> /dev/null; then
    echo "✅ JRuby found: $(jruby --version)"
else
    echo "❌ JRuby not found! Please install it first:"
    echo "   brew install jruby"
    exit 1
fi

# Check Java installation  
echo "🔍 Checking Java installation..."
if command -v java &> /dev/null; then
    echo "✅ Java found: $(java -version 2>&1 | head -n1)"
else
    echo "❌ Java not found! JRuby requires Java 8+."
    exit 1
fi

# Install JRuby gems with jruby-openssl
echo ""
echo "📦 Installing JRuby gems with jruby-openssl..."
echo "Using Gemfile.jruby which includes:"
echo "  - sinatra"
echo "  - httparty"  
echo "  - puma"
echo "  - jruby-openssl (Bouncy Castle SSL)"
echo ""

# Add java platform support
echo "🔧 Adding Java platform support..."
jruby -S bundle lock --add-platform java --gemfile=Gemfile.jruby

# Install gems
echo "📥 Installing gems..."
jruby -S bundle install --gemfile=Gemfile.jruby --path vendor/bundle

# Verify jruby-openssl installation
echo ""
echo "🔐 Verifying jruby-openssl installation..."
jruby -e "
require 'openssl'
puts '✅ OpenSSL loaded successfully!'
puts '📋 OpenSSL Version: ' + OpenSSL::OPENSSL_VERSION
puts '🏭 Platform: ' + RUBY_PLATFORM
puts '💎 JRuby Version: ' + JRUBY_VERSION
puts '☕ Java Version: ' + java.lang.System.getProperty('java.version')
puts ''
puts '🔐 SSL Implementation: jruby-openssl (Bouncy Castle)'
puts '🌐 Ready to use unified OpenSSL API across MRI and JRuby!'
"

# Test SSL certificate generation
echo ""
echo "🧪 Testing SSL certificate generation..."
jruby -e "
require './app_jruby.rb'
cert_file, key_file = generate_ssl_certs
if File.exist?(cert_file) && File.exist?(key_file)
  puts '✅ SSL certificates generated successfully!'
  puts '📄 Certificate: ' + cert_file
  puts '🔑 Private Key: ' + key_file
else
  puts '❌ SSL certificate generation failed!'
end
"

echo ""
echo "🎉 JRuby setup complete!"
echo ""
echo "🚀 To start the app with JRuby:"
echo "   ./start_jruby.sh"
echo ""
echo "📊 To run load tests:"
echo "   ./run_load_test.sh"
echo ""
echo "🔍 To check the app:"
echo "   jruby app_jruby.rb"
echo "" 