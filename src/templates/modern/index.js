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

	  Handlebars.registerPartial(name, template);
	});

	// Register helpers
	Handlebars.registerHelper('dateFormat', function(context, block) {
		if(moment) {
			var f = block.hash.format || "MMM Do, YYYY";
			return moment(context, 'YYYY-MM-DD').format(f);
		} else {
			return context;
		}
	});

	Handlebars.registerHelper('yearFormat', function(context) {
		if(moment) {
			return moment(context, 'YYYY-MM-DD').format('YYYY');
		} else {
			return context;
		}
	});

	Handlebars.registerHelper('eq', function(a, b) {
		return a === b;
	});

	Handlebars.registerHelper('or', function() {
		var args = Array.prototype.slice.call(arguments, 0, -1);
		return args.some(Boolean);
	});

	Handlebars.registerHelper('substring', function(str, start, end) {
		if (typeof str === 'string') {
			return str.substring(start, end);
		}
		return '';
	});

	return Handlebars.compile(tpl)({
		resume: resume
	});
}

module.exports = {
	render: render
};
