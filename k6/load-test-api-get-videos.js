import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// A custom metric to track failure rates
const failureRate = new Rate('check_failure_rate');

// Options
export const options = {
  projectID: 3514876,
  // Test runs with the same name groups test runs together
  name: 'api-get-videos-test',
  stages: [
    // Linearly ramp up from 1 to 50 VUs during first minute
    { target: 50, duration: '10s' },
    // Linearly ramp up from 50 to 1000 VUs for 6 minutes
    { target: 100, duration: '30s' },
    // Linearly ramp up from 50 to 1000 VUs for 6 minutes
    { target: 200, duration: '5m' },
    // Linearly ramp down from 10000 to 0 VUs for 1 minutes
    { target: 0, duration: '1m' }
    // Total execution time will be ~10 minutes
  ],
  thresholds: {
    // We want the 99th percentile of all HTTP request durations to be less than 500ms
    'http_req_duration': ['p(99)<500'],
    // Thresholds based on the custom metric we defined and use to track application failures
    'check_failure_rate': [
      // Global failure rate should be less than 1%
      'rate<0.01',
      // Abort the test early if it climbs over 5%
      { threshold: 'rate<=0.05', abortOnFail: true },
    ],
  },
};

// Main function
export default function () {
  const response = http.get('https://serverless-voting-app-new.demo.awsara.com/api/videos');

  // check() returns false if any of the specified conditions fail
  const checkRes = check(response, {
    'http2 is used': (r) => r.proto === 'HTTP/2.0',
    'status is 200': (r) => r.status === 200,
    'content is present': (r) => r.body.indexOf('region') !== -1,
  });

  // We reverse the check() result since we want to count the failures
  failureRate.add(!checkRes);

  sleep(Math.random() * 3 + 2); // Random sleep between 2s and 5s
}
