const http = require('http');
const fs = require('fs');
const path = require('path');

const dir = path.resolve(__dirname, 'build', 'web');
const types = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.json': 'application/json',
};

http.createServer((req, res) => {
  let p = path.join(dir, req.url === '/' ? 'index.html' : req.url);
  if (!fs.existsSync(p)) {
    res.writeHead(404);
    return res.end('404');
  }
  const ext = path.extname(p);
  res.writeHead(200, { 'Content-Type': types[ext] || 'text/plain' });
  res.end(fs.readFileSync(p));
}).listen(5000, () => console.log('Flutter app on http://localhost:5000'));
