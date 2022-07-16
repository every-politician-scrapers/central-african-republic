module.exports = function () {
  return `SELECT DISTINCT ?item ?itemLabel ?began ?ended
    WHERE {
      ?item wdt:P31 wd:Q5060273 .
      OPTIONAL { ?item wdt:P571|wdt:P580 ?began }
      OPTIONAL { ?item wdt:P576|wdt:P582 ?ended }
      SERVICE wikibase:label { bd:serviceParam wikibase:language "fr" }
    }
    # ${new Date().toISOString()}
    ORDER BY ?began ?item`
}
