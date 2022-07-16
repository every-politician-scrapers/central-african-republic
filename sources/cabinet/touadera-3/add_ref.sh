#!/bin/zsh

wikidata_rows=$(qsv search -i $1 wikidata.csv)
wikidata_count=$(printf "%s" "$wikidata_rows" | grep -c "^")
if [[ $wikidata_count != 2 ]]
then
  echo "No unique match to wikidata.csv:"
  echo $wikidata_rows | tail +2 | sed -e 's/^/	/g'
  return
fi
item=$(echo $wikidata_rows | qsv select item | qsv behead)

scraped_rows=$(qsv search -i $1 scraped.csv)
scraped_count=$(printf "%s" "$scraped_rows" | grep -c "^")
if [[ $scraped_count != 2 ]]
then
  echo "No unique match to scraped.csv:"
  echo $scraped_rows | tail +2 | sed -e 's/^/	/g'
  return
fi

statementid=$(echo $wikidata_rows | qsv select psid | qsv behead)
claims=$(echo $scraped_rows | qsv select name,position | qsv behead | qsv fmt --out-delimiter " ")
name=$(echo $scraped_rows | qsv select name | qsv behead)

echo "Add reference: $statementid -> $claims"
echo "$statementid $claims" | xargs wd ar --maxlag 20 add-source-name.js > /dev/null

existing=$(wd label $item)
if [[ $existing != $name ]]
then
  echo "Add alias: $item -> $name ($existing)"
  wd add-alias $item en $name > /dev/null
fi
