/**
 * DentalSupport Pro - ローカルサーバー（院内LAN用）
 *
 * 依存パッケージなしの Node.js 標準モジュールのみで動作。
 *   起動(Node)     : node server.js   /   npm start
 *   起動(実行ファイル): dist/DentalSupportPro.exe をダブルクリック（Node不要・pkgで生成）
 *   既定 http://0.0.0.0:3000（同一LAN内の他端末からもアクセス可能・ブラウザ自動起動）
 *
 * 提供API:
 *   GET  /                     -> index.html（pkg時はスナップショットから配信）
 *   GET  /api/health           -> 疎通確認
 *   POST /api/save             -> 患者データ保存（JSON）
 *   GET  /api/load/:patientId  -> 患者データ読込（無ければ404）
 *   GET/POST /api/settings     -> 医院共通設定
 *
 * データは（exe/server.js と同じ場所の）data/ に保存されます。
 *   環境変数 PORT で待受ポート、NO_OPEN=1 でブラウザ自動起動を抑止。
 */
const http = require("http");
const fs = require("fs");
const path = require("path");
const os = require("os");
const { exec } = require("child_process");

const PORT = Number(process.env.PORT) || 3000;
const HOST = process.env.HOST || "0.0.0.0";
// 実行ファイル(pkg)化した場合は exe と同じ場所に data を作る（書込可能）。通常は server.js と同じ場所。
const BASE_DIR = process.pkg ? path.dirname(process.execPath) : __dirname;
// 同梱ファイル(index.html等)は __dirname（pkgではスナップショット内）から配信
const STATIC_DIR = __dirname;
const DATA_DIR = path.join(BASE_DIR, "data");

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

  // 医院共通設定（操作モード・治療工程）保存
  if (req.method === "POST" && pathname === "/api/settings") {
    let body = "";
    req.on("data", chunk => { body += chunk; if (body.length > 5e6) req.destroy(); });
    req.on("end", () => {
      try {
        const data = JSON.parse(body);
        fs.writeFileSync(path.join(DATA_DIR, "_clinic.json"), JSON.stringify(data, null, 2), "utf-8");
        return sendJson(res, 200, { ok: true });
      } catch (e) {
        return sendJson(res, 400, { ok: false, error: "invalid JSON" });
      }
    });
    return;
  }

  // 医院共通設定 読込
  if (req.method === "GET" && pathname === "/api/settings") {
    const file = path.join(DATA_DIR, "_clinic.json");
    if (!fs.existsSync(file)) return sendJson(res, 404, { ok: false, error: "not found" });
    try {
      res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
      return res.end(fs.readFileSync(file, "utf-8"));
    } catch (e) {
      return sendJson(res, 500, { ok: false, error: "read error" });
    }
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
    const file = path.join(STATIC_DIR, rel);
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

function lanIPs() {
  const list = [];
  const ifs = os.networkInterfaces();
  for (const name in ifs) for (const ni of ifs[name] || []) {
    if (ni.family === "IPv4" && !ni.internal) list.push(ni.address);
  }
  return list;
}
function openBrowser(url) {
  const cmd = process.platform === "win32" ? `start "" "${url}"`
            : process.platform === "darwin" ? `open "${url}"`
            : `xdg-open "${url}"`;
  exec(cmd, () => {});
}

server.on("error", (e) => {
  if (e.code === "EADDRINUSE") {
    console.error(`\n[エラー] ポート ${PORT} は既に使用されています。`);
    console.error(`  すでに DentalSupport Pro が起動している可能性があります。`);
    console.error(`  別のポートで起動するには、環境変数 PORT を変更してください（例: PORT=3001）。\n`);
  } else {
    console.error(e);
  }
  setTimeout(() => process.exit(1), 100);
});

server.listen(PORT, HOST, () => {
  const local = `http://localhost:${PORT}`;
  console.log("==================================================");
  console.log("  🦷 DentalSupport Pro サーバーを起動しました");
  console.log("==================================================");
  console.log(`  このPCで開く : ${local}`);
  lanIPs().forEach(ip => console.log(`  院内の他端末 : http://${ip}:${PORT}`));
  console.log(`  データ保存先 : ${DATA_DIR}`);
  console.log("--------------------------------------------------");
  console.log("  ※ このウィンドウは開いたままにしてください（閉じると停止）");
  console.log("==================================================");
  if (process.env.NO_OPEN !== "1") openBrowser(local);
});
