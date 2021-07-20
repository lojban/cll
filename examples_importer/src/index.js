const xml2js = require('xml2js');
const fs = require('fs')
const lojban = require('lojban')
async function run() {
	const data = fs.readFileSync('/cll_examples_importer/dictionary/all_words.xml', { encoding: 'utf8' });
	const tsv = fs.readFileSync('/cll_examples_importer/dictionary/sl.tsv', { encoding: 'utf8' }).split(/[\n\r]+/).map(i => i.split("\t"));

	const result = await xml2js.parseStringPromise(data)
	for (const valsi of result.dictionary.direction[0].valsi) {
		const word = valsi.$.word
		const new_examples = tsv.filter(i => i[0] === word)
		if (new_examples.length === 0) {
			delete valsi.examples
		} else {
			if (!valsi.examples) valsi.examples = []
			if (!valsi.examples[0]) valsi.examples.push({ example: [] })
			valsi.examples[0].example = []
			// for (const example of valsi.examples[0].example) {
			// 	example.source = 'hi ' + example.source.toString().trim()
			// 	example.target[0].gloss[0] = example.target[0].gloss[0].toString().trim()
			// 	example.target[0].translation[0] = example.target[0].translation[0].toString().trim()
			// }
			for (const n of new_examples) {
				let lojbo = lojban.romoi_lahi_cmaxes(n[1])
				if (lojbo.tcini === 'fliba') continue

				lojbo = lojbo.kampu.filter(i => i[0] !== 'drata').map(i => {
					let valsi = i[1]
					if (/^[aeiouy]/.test(valsi)) valsi = `.${valsi}`
					if (!/[aeiouy\.]$/.test(valsi)) {
						valsi = `${valsi}.`
						if (!/^[aeiouy\.]/.test(valsi)) valsi = `.${valsi}`
					}
					if (/[y]$/.test(valsi)) valsi = `${valsi}.`
					return valsi
				}
				).join(" ").replace(/^\.i /g, '')
				valsi.examples[0].example.push({ "source": lojbo, "target": [{ "$": { "language": "English" }, "translation": [n[2]] }] })
			}
		}
	}

	const builder = new xml2js.Builder();
	const output = builder.buildObject(result);
	fs.writeFileSync('/cll_examples_importer/dictionary/all_words.xml', output);
}
run()