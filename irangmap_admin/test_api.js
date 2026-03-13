const https = require('https');

const agent = new https.Agent({ rejectUnauthorized: false });
const url = "https://apis.data.go.kr/1741000/pfc3?serviceKey=4b71b526c2e5c0a5c2d9604aec148136eadeb441b573e722d59ca03a57275592&pageNo=1&numOfRows=2&type=json";

https.get(url, { agent }, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log('Response:', data.substring(0, 1000)));
}).on('error', err => console.error(err));
