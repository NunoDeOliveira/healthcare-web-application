const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      service: "medicore-frontend",
      status: "healthy"
    }));
    return;
  }

  if (req.url === "/") {
    const filePath = path.join(__dirname, "public", "index.html");

    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    fs.createReadStream(filePath).pipe(res);
    return;
  }

  res.writeHead(404);
  res.end("Not Found");
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`MediCore frontend listening on port ${PORT}`);
});
