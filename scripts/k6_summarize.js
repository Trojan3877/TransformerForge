import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 20,
  duration: '2m',
  thresholds: {
    http_req_duration: ['p(95)<600'],      // P95 < 600 ms
    http_req_failed:   ['rate<0.01'],
  },
};

const URL = __ENV.TF_ENDPOINT || 'http://localhost:8000/summarize';

export default function () {
  const payload = JSON.stringify({
    text: 'TransformerForge turns data and models into code.',
  });

  const params = { headers: { 'Content-Type': 'application/json' } };
  const res = http.post(URL, payload, params);

  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(0.5);
}
