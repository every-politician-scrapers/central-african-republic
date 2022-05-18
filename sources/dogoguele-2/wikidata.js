const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  let fromd = `"${meta.cabinet.start}T00:00:00Z"^^xsd:dateTime`
  let until = meta.cabinet.end ? `"${meta.cabinet.end}T00:00:00Z"^^xsd:dateTime` : "NOW()"

  return `SELECT DISTINCT ?item ?name ?source ?sourceDate
               ?positionItem ?position ?start ?end
               (STRAFTER(STR(?held), '/statement/') AS ?psid)
        WHERE {
          # Positions currently in the cabinet
          ?positionItem p:P361 ?ps .
          ?ps ps:P361 wd:${meta.cabinet.parent} .
          FILTER NOT EXISTS { ?ps pq:P582 [] }

          # Who held those positions
          ?item wdt:P31 wd:Q5 ; p:P39 ?held .
          ?held ps:P39 ?positionItem ; pq:P580 ?start .
          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?held pq:P582 ?end }

          FILTER (
            IF(?start > ${fromd}, ?start, ${fromd}) < IF(?end < ${until}, ?end, ${until})
          )

          OPTIONAL {
            ?held prov:wasDerivedFrom ?ref .
            ?ref pr:P4656 ?source FILTER CONTAINS(STR(?source), '${meta.source}') .
            OPTIONAL { ?ref pr:P1810 ?sourceName }
            OPTIONAL { ?ref pr:P1932 ?statedName }
            OPTIONAL { ?ref pr:P813  ?sourceDate }
          }

          OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.lang}") }
          BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

          OPTIONAL { ?positionItem wdt:P1705  ?nativeLabel   FILTER(LANG(?nativeLabel)   = "${meta.lang}") }
          OPTIONAL { ?positionItem rdfs:label ?positionLabel FILTER(LANG(?positionLabel) = "${meta.lang}") }
          BIND(COALESCE(?statedName, ?nativeLabel, ?positionLabel) AS ?position)
        }
        # ${new Date().toISOString()}
        ORDER BY STR(?name) STR(?position) ?began ?wdid ?sourceDate`
}
