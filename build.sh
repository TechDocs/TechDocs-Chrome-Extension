#!/bin/bash

SKETCHAPP=/Applications/Sketch.app
SKTECHTOOL=$SKETCHAPP/Contents/Resources/sketchtool/bin/sketchtool

mkdir -p dist/
cp src/manifest.json dist/
cp src/popup.html dist/
cp node_modules/font-awesome/fonts/*.woff2 dist/
cp node_modules/riot/riot.csp.js dist/riot.js

if [ -f $SKTECHTOOL ]; then
  $SKTECHTOOL export artboards src/icon.sketch --format=png --scales=1.0 --output=dist/
fi

postcss src/global.css -u postcss-cssnext -u postcss-import -o dist/global.css
sed -i -e 's/\.\.\/fonts\///g' dist/global.css
rollup -c -i src/background.js -o dist/background.js
rollup -c -i src/popup.js -o dist/popup.js
