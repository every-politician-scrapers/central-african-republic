#!/bin/bash

cd $(dirname $0)

# scraped.csv generated manually from results list at
# https://oubanguimedias.com/2021/07/12/centrafrique-liste-complete-de-134-deputes-de-la-nation/

wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid | qsv sort -s name,startDate > wikidata.csv
bundle exec ruby diff.rb | tee diff.csv

cd ~-
