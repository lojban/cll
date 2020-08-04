function encodeValsiForWeb(v) {
	return encodeURIComponent(v).replace(/'/g, 'h')
}

function processNode(urli, Node, text, func) {
	try {
		var http = new XMLHttpRequest()
		http.open('HEAD', urli, false)
		http.send()
		if (http.status == 200) {
			var sance = new Audio(urli)
			sance.id = "sance_" + encodeValsiForWeb(text)
			sance.addEventListener('canplaythrough', function (event) {
				Node = func(Node, sance, text)
			})
		}
	} catch (error) { console.log(error) }
}

function funcContentGloss(Node, sance, text) {
	Node.parentNode.parentNode.appendChild(sance);
	Node.parentNode.parentNode.innerHTML +=
		"<button class='tutci' onclick=\"document.getElementById('sance_" +
		encodeValsiForWeb(text) +
		"').play()\">▶</button>";
	return Node
}

function funcExample(Node, sance, text) {
	Node.parentNode.appendChild(sance);
	Node.parentNode.innerHTML +=
		"<button class='tutci tutci-mupli' onclick=\"document.getElementById('sance_" +
		encodeValsiForWeb(text) +
		"').play()\">▶</button>";

	return Node
}

document.addEventListener("DOMContentLoaded", function () {
	var words = document.querySelectorAll("em.glossterm");
	words = Array.from(words)
	for (var i = 0; i < words.length; i++) {
		var Node = words[i]
		var text = Node.innerText;
		processNode(document.location.href.replace(/\/[^\/]+$/, '/') + "assets/media/vreji/" + encodeValsiForWeb(text) + ".mp3", Node, text, funcContentGloss)
	}

	var examples = Array.from(document.querySelectorAll(".example > .title > strong"));
	for (var i = 0; i < examples.length; i++) {
		var Node = examples[i]
		var text = Node.innerText.trim().replace(/ *Example (.*?)\. *$/, '$1');
		processNode(document.location.href.replace(/\/[^\/]+$/, '/') + "assets/media/examples/" + text + ".ogg", Node, text, funcExample)
	}

	var terms = Array.from(document.querySelectorAll(".guibutton"));
	for (var i = 0; i < terms.length; i++) {
		var Node = terms[i]
		var slug = encodeValsiForWeb(Node.innerText);
		var li = "<button class='tutci' onclick=\"(function (){var s=new Audio('./assets/media/vreji/" + slug + ".mp3');s.play()})()\">▶</button>"
		Node.parentNode.insertAdjacentHTML('beforeend', li)
		Node.remove()
	}
});