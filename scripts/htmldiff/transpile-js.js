const babel = require('@babel/core')
const env = require('@babel/preset-env')
const fs = require('fs')
const path = require('path')

let output = fs.readFileSync(path.join(__dirname, '../../assets/scripts/sance-next.js'), {
	encoding: 'utf8',
})

output = babel.transformSync(output, {
	plugins: [
		// 'minify-dead-code-elimination',
	],
	presets: [
		[
			env,
			{
				// corejs: '3.6.5',
				// "useBuiltIns": "entry",
				targets: '> 0.25%, not dead',
			},
		],
	],
}).code

fs.writeFileSync(
	path.join(__dirname, '../../assets/scripts/sance.js'),
	output
)