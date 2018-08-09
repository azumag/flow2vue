var uiflow = require("uiflow");

var fs = require('fs');

const data = fs.readFileSync('./flow.txt', 'utf-8');

uiflow.build(data, 'svg').pipe(process.stdout);
