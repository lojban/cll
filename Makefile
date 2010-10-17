documents = $(shell find -iname '*.html')

tidy:
	tidy -config config.yml $(documents)

validate:
	validate $(documents)

serve:
	python -mSimpleHTTPServer
