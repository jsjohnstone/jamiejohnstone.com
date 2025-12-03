var fs = require("fs");
var path = require('path');
var Handlebars = require("handlebars");
var moment = require("moment");

function render(resume) {
	var tpl = fs.readFileSync(__dirname + "/resume.hbs", "utf-8");
	var partialsDir = path.join(__dirname, 'partials');
	var filenames = fs.readdirSync(partialsDir);

	filenames.forEach(function (filename) {
	  var matches = /^([^.]+).hbs$/.exec(filename);
	  if (!matches) {
	    return;
	  }
	  var name = matches[1];
	  var filepath = path.join(partialsDir, filename)
	  var template = fs.readFileSync(filepath, 'utf8');

	  Handlebars.registerHelper('dateFormat', function(context, block) {
		  if(moment) {
		  	var f = block.hash.format || "MMM Do, YYYY";
			  return moment(context, 'YYYY-MM-DD').format(f);
		  } else {
			  return context
		  }
	  });

	  Handlebars.registerPartial(name, template);
	});
	return Handlebars.compile(tpl)({
		resume: resume
	});
}

module.exports = {
	render: render
};