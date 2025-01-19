import http from 'k6/http';
import { sleep, check } from 'k6';

const BASE_URL = __ENV.URL;

// Load configuration file specified by the CONFIG_FILE environment variable
const CONFIG_FILE = __ENV.CONFIG_FILE || 'config.json';
const config = JSON.parse(open(CONFIG_FILE));

// Export k6 options from the configuration
export const options = config.options;

// Setup function: runs once before the test
export function setup() {
  if (config.setup) {
    // Execute custom setup logic if defined in the configuration
    return eval(config.setup)();
  }
}

// Default function: VU (Virtual User) code executed during the test
export default function (data) {
  // Make HTTP request to the specified URL
  const res = http.get(BASE_URL);

  // Perform checks if defined in the configuration
  if (config.checks) {
    for (const [name, condition] of Object.entries(config.checks)) {
      check(res, { [name]: eval(condition) });
    }
  }

  // Execute custom default function logic if defined in the configuration
  if (config.default) {
    eval(config.default)(data);
  }

  // Sleep to simulate user think time
  sleep(1);
}

// Teardown function: runs once after the test
export function teardown(data) {
  if (config.teardown) {
    // Execute custom teardown logic if defined in the configuration
    eval(config.teardown)(data);
  }
}
