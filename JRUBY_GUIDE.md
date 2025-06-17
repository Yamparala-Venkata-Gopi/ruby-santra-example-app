# JRuby Support Guide

This guide explains how to run your Sinatra app with **JRuby** instead of standard Ruby (MRI).

## 🔄 **MRI Ruby vs JRuby Differences**

| Aspect | MRI Ruby | JRuby |
|--------|----------|-------|
| **Platform** | C-based | JVM-based |
| **SSL/TLS** | OpenSSL C extension | Java JSSE (Java Secure Socket Extension) |
| **Performance** | Single-threaded | True multithreading |
| **Memory** | Lower memory usage | Higher memory (JVM overhead) |
| **Java Integration** | None | Direct Java library access |

## 🛠 **Installation**

### 1. Install JRuby
```bash
# Using rbenv
rbenv install jruby-9.4.5.0
rbenv local jruby-9.4.5.0

# Using RVM  
rvm install jruby-9.4.5.0
rvm use jruby-9.4.5.0

# Direct download
curl -L https://repo1.maven.org/maven2/org/jruby/jruby-dist/9.4.5.0/jruby-dist-9.4.5.0-bin.tar.gz | tar xz
```

### 2. Install Dependencies
```bash
# Use JRuby-specific Gemfile
bundle install --gemfile=Gemfile.jruby

# Or modify your existing Gemfile to include JRuby platform gems
```

## 🚀 **Running with JRuby**

### Option 1: Use the JRuby-specific script
```bash
./start_jruby.sh
```

### Option 2: Manual JRuby execution
```bash
# Generate certificates
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj '/CN=localhost'

# Start with JRuby optimizations
JRUBY_OPTS="-J-Xmx512m" jruby -S bundle exec puma \
  -b 'tcp://0.0.0.0:4567' \
  -b 'ssl://0.0.0.0:4568?key=server.key&cert=server.crt' \
  config.ru
```

### Option 3: Use the universal app
```bash
# The app_jruby.rb automatically detects JRuby vs MRI
jruby app_jruby.rb
```

## 🔐 **SSL/TLS with JRuby**

### Key Differences:
1. **Certificate Generation**: Uses system OpenSSL or Java keytool
2. **SSL Context**: Java's SSLContext instead of Ruby's OpenSSL
3. **Trust Stores**: Java's trust store system

### JRuby SSL Configuration:
```ruby
# JRuby-specific SSL imports
require 'java'
java_import 'javax.net.ssl.SSLContext'
java_import 'javax.net.ssl.KeyManagerFactory'
java_import 'java.security.KeyStore'
```

## ⚡ **Performance Benefits**

### JRuby Advantages:
- **True Multithreading**: No Global Interpreter Lock (GIL)
- **JIT Compilation**: HotSpot JVM optimizations
- **Java Library Access**: Use any Java library directly
- **Better Concurrency**: Handle more simultaneous requests

### Example Performance Settings:
```bash
export JRUBY_OPTS="-J-Xmx1024m -J-server -J-XX:+UseG1GC"
```

## 🧪 **Testing**

### Run Load Tests with JRuby:
```bash
# Start JRuby server
./start_jruby.sh

# In another terminal, run load tests
./run_load_test.sh
```

### Compare Performance:
```bash
# Test MRI Ruby
bundle exec ruby app.rb &
curl -w "@curl-format.txt" http://localhost:4567

# Test JRuby  
jruby app_jruby.rb &
curl -w "@curl-format.txt" http://localhost:4567
```

## 🐛 **Troubleshooting**

### Common Issues:

1. **SSL Certificate Errors**:
   ```bash
   # Add JVM SSL options
   export JRUBY_OPTS="-J-Djruby.ssl.verify.mode=VERIFY_NONE"
   ```

2. **Memory Issues**:
   ```bash
   # Increase JVM heap
   export JRUBY_OPTS="-J-Xmx2048m"
   ```

3. **Gem Compatibility**:
   ```bash
   # Some gems have JRuby-specific versions
   gem install some-gem --platform=java
   ```

4. **Java Version Issues**:
   ```bash
   # JRuby requires Java 8+
   java -version
   export JAVA_HOME=/path/to/java8+
   ```

## 📦 **Production Deployment**

### Docker with JRuby:
```dockerfile
FROM jruby:9.4-jdk11

WORKDIR /app
COPY Gemfile.jruby Gemfile
COPY . .

RUN bundle install
EXPOSE 4567 4568

CMD ["./start_jruby.sh"]
```

### Environment Variables:
```bash
# Production JRuby settings
export JRUBY_OPTS="-J-server -J-Xmx2048m -J-XX:+UseG1GC"
export RACK_ENV=production
```

## 🔍 **Monitoring JRuby**

### JVM Monitoring:
```bash
# Enable JMX monitoring
export JRUBY_OPTS="-J-Dcom.sun.management.jmxremote"

# Use JConsole or similar tools to monitor
jconsole
```

### Memory Usage:
```ruby
# In your app, check JRuby memory
puts "JRuby Memory: #{java.lang.Runtime.runtime.total_memory / 1024 / 1024}MB"
```

## 📊 **Performance Comparison**

| Metric | MRI Ruby | JRuby |
|--------|----------|-------|
| **Startup Time** | Fast | Slower (JVM warmup) |
| **Steady State** | Good | Better (JIT optimization) |
| **Memory Usage** | Lower | Higher |
| **Concurrency** | Limited (GIL) | Excellent |
| **Java Integration** | None | Native |

## 🎯 **When to Use JRuby**

### Choose JRuby when:
- ✅ High concurrency requirements
- ✅ Need Java library integration  
- ✅ Long-running applications
- ✅ CPU-intensive workloads
- ✅ Enterprise Java environments

### Stick with MRI when:
- ✅ Quick scripts/prototypes
- ✅ Memory-constrained environments
- ✅ Gems with C extensions
- ✅ Fast startup time required

---

Your Sinatra app now supports both MRI Ruby and JRuby! 🎉 