/* eslint-disable no-useless-escape */
import { readdirSync, readFileSync, writeFileSync } from "fs";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const getPath = (path) => resolve(join(__dirname, ...path.split("/")));

const assets = readdirSync(getPath("dist/assets")).filter(
  (file) => file.endsWith(".js") || file.endsWith(".css")
);

assets.forEach((assetFileName) => {
  const assetPath = getPath(`dist/assets/${assetFileName}`);
  let assetContent = readFileSync(assetPath, "utf-8");
  const assetMatch = assetContent.match(/\/assets\//gim);
  if (assetMatch) {
    assetMatch.forEach((el, i) => {
      const searchIndex = assetContent.indexOf(el, i) - 1;
      let _content = assetContent.substring(searchIndex);
      if (_content.charAt(0) == ".") return;
      else {
        if (assetFileName.endsWith("css")) _content = _content.replace('/assets/', './');
        if (assetFileName.endsWith("js")) _content = _content.replace('/assets/', './assets/');
      }

      assetContent = assetContent.substring(0, searchIndex) + _content;
    });
  }

  writeFileSync(assetPath, assetContent)
});

const htmlPath = getPath("dist/index.html");
let htmlContent = readFileSync(htmlPath, "utf-8");
const htmlMatch = htmlContent.match(/(src|href)=\"\//gim);
if (htmlMatch) {
  htmlMatch
    .filter((f) => f.startsWith("src"))
    .forEach((el, i) => {
      const searchIndex = htmlContent.indexOf(el, i);
      let _content = htmlContent.substring(searchIndex);
      _content = _content.replace('src="/', "");
      if (_content.charAt(0) == "/") return;
      else {
        _content = 'src="./' + _content;
      }

      htmlContent = htmlContent.substring(0, searchIndex) + _content;
    });
  htmlMatch
    .filter((f) => f.startsWith("href"))
    .forEach((el, i) => {
      const searchIndex = htmlContent.indexOf(el, i);
      let _content = htmlContent.substring(searchIndex);
      _content = _content.replace('href="/', "");
      if (_content.charAt(0) == "/") return;
      else {
        _content = 'href="./' + _content;
      }

      htmlContent = htmlContent.substring(0, searchIndex) + _content;
    });
}

writeFileSync(htmlPath, htmlContent);
