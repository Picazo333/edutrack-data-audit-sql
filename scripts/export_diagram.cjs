// Exporta diagram.png desde diagram.4geeks.com sin cuenta.
// Abre la herramienta, carga diagram.4geeks.json y pulsa Export as PNG.
// Requiere Google Chrome y el paquete puppeteer-core (no se commitea node_modules).
//
//   NODE_PATH=/tmp/node_modules node scripts/export_diagram.cjs
//
// Si la página pide login, el script termina con error y no inventa el PNG.

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const diagram = JSON.parse(
  fs.readFileSync(path.join(root, "diagram.4geeks.json"), "utf8")
);

async function main() {
  let puppeteer;
  try {
    puppeteer = require("puppeteer-core");
  } catch (err) {
    console.error("falta puppeteer-core. Instálalo y exporta con NODE_PATH.");
    process.exit(1);
  }

  const browser = await puppeteer.launch({
    executablePath: process.env.CHROME_PATH || "/usr/local/bin/google-chrome",
    headless: true,
    args: ["--no-sandbox", "--disable-dev-shm-usage"],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1400, height: 1000, deviceScaleFactor: 1 });
  const logs = [];
  page.on("console", (msg) => logs.push(msg.text()));

  const url = "https://diagram.4geeks.com/?readOnly=true";
  await page.goto(url, { waitUntil: "networkidle0", timeout: 60000 });

  const password = await page.$('input[type="password"]');
  const bodyText = await page.evaluate(() => document.body.innerText.slice(0, 500));
  if (password || /sign in|log in|iniciar sesión/i.test(bodyText)) {
    console.error("diagram.4geeks.com pidió autenticación. No se exporta un PNG sustituto.");
    await browser.close();
    process.exit(2);
  }

  await page.waitForSelector("#erdCanvas", { timeout: 20000 });
  await page.waitForFunction(() => window.isReadOnly === true, { timeout: 20000 });
  await page.waitForSelector("#exportImage", { timeout: 20000 });

  await page.evaluate((payload) => {
    window.postMessage({ type: "loadERD", diagram: payload }, "*");
  }, diagram);

  await page.waitForFunction(() => {
    const raw = localStorage.getItem("erdDiagram");
    if (!raw) return false;
    const data = JSON.parse(raw);
    const names = (data.tables || []).map((table) => table.name).sort();
    return names.join(",") === "courses,enrollments,students";
  }, { timeout: 20000 });

  await page.evaluate(() => {
    window.__exported = null;
    const original = HTMLAnchorElement.prototype.click;
    HTMLAnchorElement.prototype.click = function hookedClick() {
      if (typeof this.href === "string" && this.href.startsWith("data:image/png")) {
        window.__exported = this.href;
      }
      return original.apply(this, arguments);
    };
  });

  await page.evaluate(() => {
    const button = document.querySelector("#exportImage");
    if (!button) throw new Error("no está el control Export as PNG");
    button.click();
  });
  await page.waitForFunction(() => window.__exported, { timeout: 20000 });

  const href = await page.evaluate(() => window.__exported);
  const stored = await page.evaluate(() => localStorage.getItem("erdDiagram"));
  const png = Buffer.from(href.split(",")[1], "base64");
  if (png.length < 5000 || png.subarray(0, 8).toString("hex") !== "89504e470d0a1a0a") {
    console.error("la exportación no devolvió un PNG válido");
    await browser.close();
    process.exit(1);
  }

  fs.mkdirSync(path.join(root, "evidence", "diagram"), { recursive: true });
  fs.writeFileSync(path.join(root, "diagram.png"), png);
  await page.screenshot({
    path: path.join(root, "evidence", "diagram", "tool_screen.png"),
    fullPage: true,
  });

  const log = [
    `finished_at=${new Date().toISOString()}`,
    `url=${url}`,
    "login_form=no",
    "export=Export as PNG (exportAsImage del propio sitio)",
    `png_bytes=${png.length}`,
    "tables=courses,enrollments,students",
    "readOnly=true",
    "stored_diagram_starts=" + stored.slice(0, 180).replace(/\s+/g, " "),
    "console:",
    ...logs.slice(0, 40),
  ].join("\n");
  fs.writeFileSync(path.join(root, "evidence", "diagram", "export_log.txt"), log + "\n");
  console.log(log);
  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
