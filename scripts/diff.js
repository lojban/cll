const fs = require("fs"),
  path = require("path");
const HtmlDiff = require(path.join(__dirname, "./htmldiff.js"))
  .default;

const oldFileName = "../build/cll_diffs/diff_old_xhtml_no_chunks/index.html";
const newFileName = "../build/cll_diffs/diff_new_xhtml_no_chunks/index.html";
const diffFileName =
  "../build/cll_diffs/diff_new_xhtml_no_chunks/difference.html";
const diffPrefixedFileName =
  "../build/cll_diffs/diff_new_xhtml_no_chunks/difference_prefixed.html";

function getFileContent(pathTo) {
  return fs.readFileSync(path.resolve(__dirname, pathTo), {
    encoding: "utf8"
  });
}
try {
  let result = HtmlDiff.execute(
    getFileContent(oldFileName),
    getFileContent(newFileName)
  ).replace(
    "<head>",
    `<head>
  <style>
  ins {
    background-color: #97f295;
  }
  del{
    background-color: #ffb6ba;
  }
  .diff_pre{
    font-size:50%;
  }
  </style>
  `
  ).replace("<body>",`
  <body>
    <div>Only a visual difference file: not for publication, hyperlinks might not work, images and complex formatting might not be displayed!<br/>
    Red blocks denote deletions, green blocks denote insertions.
    </div>
  
  `);
  let result_with_prefixes = result.replace(
    /<ins /g,
    `<span class="diff_pre">ins\`</span><ins `)
    .replace(
    /<del /g,
    `<span class="diff_pre">del\`</span><del `).replace("Red blocks denote deletions, green blocks denote insertions.",`
  Red blocks with the prefix del\` denote deletions, green blocks with the prefix ins\` denote insertions.
  
  `);
  fs.writeFileSync(path.resolve(__dirname, diffFileName), result, {
    encoding: "utf8"
  });
  fs.writeFileSync(
    path.resolve(__dirname, diffPrefixedFileName),
    result_with_prefixes,
    {
      encoding: "utf8"
    }
  );
} catch (error) {}
