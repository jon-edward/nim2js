import fs from "fs";

const demoPath = "demo.html";
const copyPath = "index.html";

fs.copyFile(demoPath, copyPath, (err) => {
  if (err) {
    console.error("Error copying file:", err);
  }
});
