const HtmlDiff = require("htmldiff-js").default;
const fs = require("fs"),
  path = require("path");

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
  `);
  let result_with_prefixes = result.replace("</body>",`<script>
  
  document.querySelectorAll('ins').forEach(function(ins) {
    var span = document.createElement('span');
    span.innerHTML = 'ins\`';
    span.className = 'diff_pre';
    ins.parentNode.insertBefore(span, ins);
  });
  document.querySelectorAll('del').forEach(function(del) {
    var span = document.createElement('span');
    span.innerHTML = 'del\`';
    span.className = 'diff_pre';
    del.parentNode.insertBefore(span, del);
  });
  </script></body>`);
  fs.writeFileSync(path.resolve(__dirname, diffFileName), result, {
    encoding: "utf8"
  });
  fs.writeFileSync(path.resolve(__dirname, diffPrefixedFileName), result_with_prefixes, {
    encoding: "utf8"
  });
} catch (error) {}
