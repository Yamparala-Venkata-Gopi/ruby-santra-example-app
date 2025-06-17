# Load Testing for Ruby Sinatra App

This directory includes load testing capabilities using [Locust](https://locust.io/) to generate realistic traffic for your Sinatra application.

## Quick Start

### 1. Start Your Sinatra App
```bash
bundle exec ruby app.rb
```

### 2. Run Load Test
```bash
./run_load_test.sh
```

## What Gets Tested

The load test simulates realistic user behavior:

- **Homepage visits** (most common)
- **Proxy route testing** (Google, Amazon, Walmart, Nike, GitHub)
- **404 error generation** (simulates broken links)
- **Asset requests** (simulates browser loading CSS/JS)

## User Types

- **Regular Users** (majority): Normal browsing with 1-5 second delays
- **Power Users** (few): Rapid requests with 0.5-2 second delays  
- **Slow Users** (few): Slow browsing with 10-30 second delays

## Test Configurations

1. **Light Load**: 10 users, 2 spawn rate
2. **Medium Load**: 50 users, 5 spawn rate
3. **Heavy Load**: 100 users, 10 spawn rate
4. **Custom**: Configure your own parameters
5. **Quick Test**: 5 users for 30 seconds

## Monitoring

- **Web UI**: http://localhost:8089
- **Real-time metrics**: Requests/sec, response times, failures
- **Charts**: Performance graphs and statistics

## Files

- `locustfile.py`: Load test scenarios and user behavior
- `run_load_test.sh`: Easy-to-use script for running tests
- `requirements.txt`: Python dependencies
- `venv/`: Virtual environment (auto-created)

## Example Output

The test will show:
- Total requests per second
- Average response time
- 95th percentile response time
- Error rate
- Requests per endpoint

## Tips

- Start with light load and increase gradually
- Monitor your system resources during testing
- External proxy routes (Google, Amazon, etc.) may be slower
- Use the web UI for detailed real-time monitoring 