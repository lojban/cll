const fs = require("fs"),
  path = require("path");

function getFileContent(pathTo) {
  return fs.readFileSync(path.resolve(__dirname, pathTo), {
    encoding: "utf8"
  });
}

const options = {
  attributeNamePrefix: "",
  attrNodeName: "attr", //default is 'false'
  textNodeName: "text",
  ignoreAttributes: false,
  ignoreNameSpace: false,
  allowBooleanAttributes: false,
  parseNodeValue: true,
  parseAttributeValue: false,
  trimValues: true,
  cdataTagName: "__cdata", //default is 'false'
  cdataPositionChar: "\\c",
  localeRange: "", //To support non english character in tag/attribute values.
  parseTrueNumberOnly: false,
  arrayMode: false //"strict"
};

const raw = getFileContent("../build/cll_preglossary.xml");
const parser = require("fast-xml-parser");

const jsonObj = parser.parse(raw, options);

fs.writeFileSync(
  path.resolve(__dirname, "../build/cll.json"),
  JSON.stringify(jsonObj, null, 2)
);
const jp = require("jsonpath");
let valsi = jp.query(jsonObj, "$..valsi");
valsi = valsi.reduce((acc, v) => {
  if (Array.isArray(v)) {
    acc = acc.concat(v);
  } else acc = acc.concat([v]);
  return acc;
}, []);
valsi = valsi.filter(v => {
  if (v.attr && v.attr.valid && ["false", "maybe"].includes(v.attr.valid))
    return false;
  return true;
});

valsi = [...new Set(valsi)];

const select = require("xpath.js"),
  dom = require("xmldom").DOMParser,
  se = require("xmldom").XMLSerializer;
const xml = getFileContent("../xml/jbovlaste.xml");
const doc = new dom().parseFromString(xml);

let a = [];
valsi.forEach(v => {
  v = v.replace(/\./g, "").trim();
  let node = select(doc, `//valsi[@word="${v}"]`)[0];
  if (!node) {
    console.log(`word ${v} not found in jbovlaste.xml dump, skipping`);
    return;
  }
  node = node.toString();
  const doc_ = new dom().parseFromString(node);

  const user = doc_.getElementsByTagName("user")[0];
  doc_.documentElement.removeChild(user);
  const id = doc_.getElementsByTagName("definitionid")[0];
  doc_.documentElement.removeChild(id);

  node = new se().serializeToString(doc_);
  a.push(node);
});
a.unshift(`<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="jbovlaste.xsl"?>
<dictionary>
<direction from="lojban" to="English">`);
a.push(`</direction></dictionary>`);

a = a.join("\n");
a = new dom().parseFromString(a);
a = new se().serializeToString(a);

fs.writeFileSync(path.resolve(__dirname, "../build/jbovlaste-lite.xml"), a);

console.log(
  `file ${path.resolve(__dirname, "../build/jbovlaste-lite.xml")} generated.`
);
