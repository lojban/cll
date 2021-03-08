# npm install svgexport -g

for file in orig/chapter-letterals.svg orig/chapter-structure.svg orig/chapter-abstractions.svg orig/chapter-connectives.svg orig/chapter-relative-clauses.svg orig/chapter-2-diagram.svg orig/chapter-anaphoric-cmavo.svg orig/chapter-grammars.svg orig/chapter-selbri.svg orig/chapter-about.svg orig/chapter-catalogue.svg orig/chapter-lujvo.svg orig/chapter-tour.svg
do
echo "converting "$PWD/$file
svgexport $PWD/$file $PWD/$file.png 400:
done