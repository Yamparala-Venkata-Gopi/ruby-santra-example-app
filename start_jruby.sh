#!/bin/bash

echo "🚀 Starting Sinatra App with JRuby Support"
echo "=============================================="

# Check if JRuby is available
if command -v jruby &> /dev/null; then
    RUBY_CMD="jruby"
    echo "✅ JRuby found: $(jruby --version)"
elif ruby --version | grep -q "jruby"; then
    RUBY_CMD="ruby"
    echo "✅ Ruby is JRuby: $(ruby --version)"
else
    RUBY_CMD="ruby"
    echo "⚠️  Standard Ruby detected: $(ruby --version)"
    echo "   This script is optimized for JRuby but will work with MRI Ruby too"
fi

# Generate SSL certificates if they don't exist
if [ ! -f "server.crt" ] || [ ! -f "server.key" ]; then
    echo "📜 Generating SSL certificates..."
    
    # Try system OpenSSL first (works for both JRuby and MRI)
    if command -v openssl &> /dev/null; then
        openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj '/CN=localhost'
    else
        # Fallback to using Ruby's certificate generation
        $RUBY_CMD -e "require './app_jruby.rb'; generate_ssl_certs_universal"
    fi
fi

echo ""
echo "🌐 Starting both HTTP and HTTPS servers with $RUBY_CMD..."
echo "📍 HTTP:  http://localhost:4567"
echo "📍 HTTPS: https://localhost:4568 (self-signed - accept the certificate warning)"
echo ""

# JRuby-specific JVM options for better SSL performance
if [[ "$RUBY_CMD" == *"jruby"* ]]; then
    echo "🔧 Setting JRuby-specific JVM options for SSL..."
    export JRUBY_OPTS="-J-Djruby.ssl.verify.mode=VERIFY_NONE -J-Xmx512m"
fi

echo "Press Ctrl+C to stop both servers"
echo ""

# Start Puma with both HTTP and HTTPS bindings
bundle exec puma \
  -b 'tcp://0.0.0.0:4567' \
  -b 'ssl://0.0.0.0:4568?key=server.key&cert=server.crt' \
  config.ru 