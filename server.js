/**
 * DentalSupport Pro - ローカルサーバー（院内LAN用）
 *
 * 依存パッケージなしの Node.js 標準モジュールのみで動作します。
 *   起動: node server.js
 *   既定: http://0.0.0.0:3000  （同一LAN内の他端末からもアクセス可能）
 *
 * 提供API:
 *   GET  /                     -> index.html を返す
 *   GET  /api/health           -> 疎通確認
 *   POST /api/save             -> 患者データ保存（JSON）
 *   GET  /api/load/:patientId  -> 患者データ読込（無ければ404）
 *
 * データは ./data/<patientId>.json に保存されます。
 */
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";
const DATA_DIR = path.join(__dirname, "data");

if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

function sendJson(res, status, obj) {
  res.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  res.end(JSON.stringify(obj));
}

function safeId(id) {
  // パストラバーサル防止：英数・ハイフン・アンダースコアのみ許可
  return String(id).replace(/[^A-Za-z0-9_-]/g, "");
}

const server = http.createServer((req, res) => {
  // 院内ツールのためCORSは緩めに許可
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") { res.writeHead(204); return res.end(); }

  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  // ヘルスチェック
  if (req.method === "GET" && pathname === "/api/health") {
    return sendJson(res, 200, { ok: true, time: new Date().toISOString() });
  }

  // 保存
  if (req.method === "POST" && pathname === "/api/save") {
    let body = "";
    req.on("data", chunk => { body += chunk; if (body.length > 5e6) req.destroy(); });
    req.on("end", () => {
      try {
        const data = JSON.parse(body);
        const id = safeId(data.patientId);
        if (!id) return sendJson(res, 400, { ok: false, error: "invalid patientId" });
        fs.writeFileSync(path.join(DATA_DIR, id + ".json"), JSON.stringify(data, null, 2), "utf-8");
        return sendJson(res, 200, { ok: true, patientId: id });
      } catch (e) {
        return sendJson(res, 400, { ok: false, error: "invalid JSON" });
      }
    });
    return;
  }

  // 読込
  if (req.method === "GET" && pathname.startsWith("/api/load/")) {
    const id = safeId(decodeURIComponent(pathname.replace("/api/load/", "")));
    const file = path.join(DATA_DIR, id + ".json");
    if (!id || !fs.existsSync(file)) return sendJson(res, 404, { ok: false, error: "not found" });
    try {
      const content = fs.readFileSync(file, "utf-8");
      res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
      return res.end(content);
    } catch (e) {
      return sendJson(res, 500, { ok: false, error: "read error" });
    }
  }

  // 静的ファイル（index.html / 画像など）
  if (req.method === "GET") {
    const rel = (pathname === "/" || pathname === "/index.html") ? "index.html" : decodeURIComponent(pathname.replace(/^\/+/, ""));
    // パストラバーサル防止
    if (rel.includes("..")) { res.writeHead(403); return res.end("Forbidden"); }
    const file = path.join(__dirname, rel);
    const types = { ".html":"text/html; charset=utf-8", ".png":"image/png", ".jpg":"image/jpeg", ".jpeg":"image/jpeg", ".webp":"image/webp", ".svg":"image/svg+xml", ".css":"text/css", ".js":"text/javascript" };
    const ext = path.extname(file).toLowerCase();
    if (types[ext] && fs.existsSync(file) && fs.statSync(file).isFile()) {
      res.writeHead(200, { "Content-Type": types[ext] });
      return res.end(fs.readFileSync(file));
    }
  }

  res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("Not Found");
});

server.listen(PORT, HOST, () => {
  console.log(`DentalSupport Pro server running at http://${HOST}:${PORT}`);
  console.log(`データ保存先: ${DATA_DIR}`);
});
