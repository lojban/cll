const fs = require("fs"),
  path = require("path");
const HtmlDiff = require(path.join(__dirname, "./htmldiff.js")).default;

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
  let result0 = HtmlDiff.execute(
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
  );
  let result = result0.replace(
    "<body>",
    `<body>
    <div>Only a visual difference file: not for publication, hyperlinks might not work, images and complex formatting might not be displayed!<br/>
    <del class="cll_diff diffmod">Red blocks</del> denote deletions, <ins class="diffmod">green blocks</ins> denote insertions.
    </div>
  `
  );
  let result_with_prefixes = result0
    .replace(
      "<body>",
      `
      <body>
    <div>Only a visual difference file: not for publication, hyperlinks might not work, images and complex formatting might not be displayed!<br/>
    <del class="cll_diff diffmod">Red blocks</del> with the prefix del\` denote deletions, <ins class="diffmod">green blocks</ins> with the prefix ins\` denote insertions.
    </div>`
    )
    .replace(/<ins /g, `<span class="diff_pre">ins\`</span><ins `)
    .replace(/<del /g, `<span class="diff_pre">del\`</span><del `);

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
