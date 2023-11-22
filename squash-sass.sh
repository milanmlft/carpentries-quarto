#!/usr/bin/env bash

out=_extensions/carpentries/assets
mkdir -p ${out}/{fonts,images,icons}
cp -r source/fonts/* ${out}/fonts/
cp -r source/images/* ${out}/images/
cp -r source/icons/* ${out}/icons/

node_modules/.bin/sass -s compressed \
  source/stylesheets/styles.css.scss \
  ${out}/styles.css

