import http from "node:http";

const target = "https://litellm.tiebe.me";

const server = http.createServer((req, res) => {
  const chunks = [];
  req.on("data", (chunk) => chunks.push(chunk));
  req.on("end", async () => {
    try {
      let body = Buffer.concat(chunks);
      const contentType = req.headers["content-type"] || "";

      if (body.length && contentType.includes("application/json")) {
        const json = JSON.parse(body.toString("utf8"));
        delete json.max_output_tokens;
        delete json.max_tokens;
        body = Buffer.from(JSON.stringify(json));
      }

      const headers = { ...req.headers };
      delete headers.host;
      headers["content-length"] = String(body.length);

      const upstream = await fetch(`${target}${req.url}`, {
        method: req.method,
        headers,
        body: ["GET", "HEAD"].includes(req.method) ? undefined : body,
      });

      res.writeHead(upstream.status, Object.fromEntries(upstream.headers));
      if (upstream.body) {
        for await (const chunk of upstream.body) res.write(chunk);
      }
      res.end();
    } catch (error) {
      res.writeHead(502, { "content-type": "application/json" });
      res.end(JSON.stringify({ error: String(error?.stack || error) }));
    }
  });
});

server.listen(4001, "127.0.0.1", () => {
  console.log("OpenCode LiteLLM proxy listening on http://127.0.0.1:4001");
});