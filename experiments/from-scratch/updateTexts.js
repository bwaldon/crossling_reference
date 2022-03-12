const getJSON = require('get-json')
const fs = require('fs');

const apiKey = fs.readFileSync("api_keys/googlesheets")

getJSON('https://sheets.googleapis.com/v4/spreadsheets/1KPdMdS0BkTGfRDejqsVtcBQx6gqneLitntGPAQpg8Eg/values/Sheet1?key=' + apiKey)

.then( function(json) {

	// utility for converting google sheets api call to interpretable json 

  function convertToObjects(headers, rows)
    {
      return rows.reduce((ctx, row) => {
        ctx.objects.push(ctx.headers.reduce((item, header, index) => {
          item[header] = row[index];
          return item;
        }, {}));
        return ctx;
      }, { objects: [], headers}).objects;
    }

  const jsonObjects = convertToObjects(json.values[0],json.values.slice(1))

  fs.writeFileSync('client/gameText.js', "export const gameText = " + JSON.stringify(jsonObjects) )


 });