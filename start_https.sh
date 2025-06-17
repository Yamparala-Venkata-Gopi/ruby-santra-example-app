#!/bin/bash

echo "🚀 Starting Sinatra App with HTTP and HTTPS support"
echo "=============================================="

# Generate SSL certificates if they don't exist
if [ ! -f "server.crt" ] || [ ! -f "server.key" ]; then
    echo "📜 Generating SSL certificates..."
    bundle exec ruby -e "
    require './app.rb'
    generate_ssl_certs
    "
fi

echo "🌐 Starting both HTTP and HTTPS servers..."
echo "📍 HTTP:  http://localhost:4567"
echo "📍 HTTPS: https://localhost:4568 (self-signed - accept the certificate warning)"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Start Puma with both HTTP and HTTPS bindings
bundle exec puma \
  -b 'tcp://0.0.0.0:4567' \
  -b 'ssl://0.0.0.0:4568?key=server.key&cert=server.crt' \
  config.ru 