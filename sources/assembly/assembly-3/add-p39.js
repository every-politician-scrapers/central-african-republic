const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, label, party, startdate, enddate) => {
  qualifier = { }
  if(meta.term.id)       qualifier['P2937'] = meta.term.id
  if(meta.term.election) qualifier['P2715'] = meta.term.election
  if(party)              qualifier['P4100'] = party
  if(startdate)          qualifier['P580']  = startdate
  if(enddate)            qualifier['P582']  = enddate

  reference = {
    ...meta.reference,
    P813: new Date().toISOString().split('T')[0],
    P1810: label,
  }

  return {
    id,
    claims: {
      P39: {
        value:      meta.position,
        qualifiers: qualifier,
        references: reference,
      }
    }
  }
}
