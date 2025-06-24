#!/bin/bash

echo "🚀 Starting Sinatra App with JRuby ONLY"
echo "========================================"

# Force JRuby usage - no fallbacks
if command -v jruby &> /dev/null; then
    RUBY_CMD="jruby"
    echo "✅ JRuby found: $(jruby --version)"
    echo "🔐 Using jruby-openssl (Bouncy Castle) for SSL"
else
    echo "❌ JRuby not found! This script requires JRuby."
    echo "   Please install JRuby first:"
    echo "   brew install jruby"
    echo ""
    echo "   Or run the setup script:"
    echo "   ./setup_jruby.sh"
    exit 1
fi

# Verify jruby-openssl is available
echo ""
echo "🔐 Verifying jruby-openssl..."
if jruby -e "require 'openssl'; puts 'jruby-openssl loaded: ' + OpenSSL::OPENSSL_VERSION" 2>/dev/null; then
    echo "✅ jruby-openssl is working!"
else
    echo "❌ jruby-openssl not available. Please run:"
    echo "   ./setup_jruby.sh"
    exit 1
fi

# Generate SSL certificates and keystore if they don't exist
if [ ! -f "server.crt" ] || [ ! -f "server.key" ] || [ ! -f "keystore.jks" ]; then
    echo ""
    echo "📜 Generating SSL certificates and Java keystore..."
    
    # Generate PEM certificates using system OpenSSL
    if command -v openssl &> /dev/null; then
        echo "🔧 Using system OpenSSL for certificate generation..."
        openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj '/CN=localhost'
        echo "✅ SSL certificates generated with system OpenSSL"
    else
        # Fallback to JRuby certificate generation
        echo "🔧 Using jruby-openssl for certificate generation..."
        jruby -e "require './app_jruby.rb'; generate_ssl_certs"
        echo "✅ SSL certificates generated with jruby-openssl"
    fi
    
    # Convert to Java keystore format for JRuby/Puma
    echo "🔧 Converting to Java keystore format..."
    if command -v keytool &> /dev/null; then
        # Create PKCS12 first
        openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name localhost -password pass:password
        # Convert to JKS keystore
        keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -destkeystore keystore.jks -deststoretype JKS -srcstorepass password -deststorepass password -noprompt
        rm server.p12  # Clean up temporary file
        echo "✅ Java keystore (keystore.jks) created successfully"
    else
        echo "⚠️  keytool not found - HTTPS will not be available"
        echo "   HTTP server will still work on port 4567"
    fi
fi

echo ""
echo "🌐 Starting HTTP and HTTPS servers with JRuby..."
echo "📍 HTTP:  http://localhost:4567"

# Check if keystore exists for HTTPS
if [ -f "keystore.jks" ]; then
    echo "📍 HTTPS: https://localhost:4568 (self-signed - accept the certificate warning)"
    HTTPS_BINDING="-b 'ssl://0.0.0.0:4568?keystore=keystore.jks&keystore-pass=password'"
else
    echo "📍 HTTPS: Not available (keystore.jks not found)"
    HTTPS_BINDING=""
fi

echo ""

# JRuby-specific JVM options for better SSL performance with Bouncy Castle
echo "🔧 Setting JRuby-specific JVM options for SSL..."
echo "   jruby-openssl provides OpenSSL compatibility via Bouncy Castle"
export JRUBY_OPTS="-J-Xmx512m -J-XX:+UseG1GC"

echo "Press Ctrl+C to stop the server(s)"
echo ""

# Start Puma with HTTP and optionally HTTPS
if [ -f "keystore.jks" ]; then
    # Start with both HTTP and HTTPS
    BUNDLE_GEMFILE=Gemfile.jruby jruby -S bundle exec puma \
      -b 'tcp://0.0.0.0:4567' \
      -b 'ssl://0.0.0.0:4568?keystore=keystore.jks&keystore-pass=password' \
      config.ru
else
    # Start with HTTP only
    echo "⚠️  Starting HTTP only (no keystore available for HTTPS)"
    BUNDLE_GEMFILE=Gemfile.jruby jruby -S bundle exec puma \
      -b 'tcp://0.0.0.0:4567' \
      config.ru
fi 