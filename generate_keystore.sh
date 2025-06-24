#!/bin/bash

echo "🔐 Generating Java Keystore for JRuby SSL"
echo "=========================================="

# Clean up any existing files
echo "🧹 Cleaning up existing certificates..."
rm -f server.crt server.key keystore.jks server.p12

# Generate PEM certificates
echo "📜 Generating SSL certificates..."
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj '/CN=localhost'

# Create PKCS12 keystore
echo "🔧 Creating PKCS12 keystore..."
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name localhost -password pass:password

# Convert to Java keystore (JKS)
echo "🔧 Converting to Java keystore..."
keytool -importkeystore \
  -srckeystore server.p12 \
  -srcstoretype PKCS12 \
  -destkeystore keystore.jks \
  -deststoretype JKS \
  -srcstorepass password \
  -deststorepass password \
  -noprompt

# Clean up temporary file
rm server.p12

echo "✅ Java keystore created successfully!"
echo "📄 Files created:"
echo "   - server.crt (PEM certificate)"
echo "   - server.key (PEM private key)"  
echo "   - keystore.jks (Java keystore for JRuby/Puma)"
echo ""
echo "🚀 Now you can run: ./start_jruby.sh" 