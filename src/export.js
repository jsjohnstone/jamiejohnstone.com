var fs = require('fs');
var path = require('path');

// Parse command line arguments
var args = process.argv.slice(2);
var template = 'modern'; // default template

args.forEach(function(arg) {
    if (arg.startsWith('--template=')) {
        template = arg.split('=')[1];
    }
});

// Validate template exists
var templatePath = path.join(process.cwd(), 'templates', template);
if (!fs.existsSync(templatePath)) {
    console.error('Template "' + template + '" not found at ' + templatePath);
    console.log('Available templates:');
    var templatesDir = path.join(process.cwd(), 'templates');
    if (fs.existsSync(templatesDir)) {
        fs.readdirSync(templatesDir).forEach(function(dir) {
            var stat = fs.statSync(path.join(templatesDir, dir));
            if (stat.isDirectory()) {
                console.log('  - ' + dir);
            }
        });
    }
    process.exit(1);
}

var file = process.cwd() + '/resume/resume.json';
fs.readFile(file, function(err, resumeJson) {
    var resumeJson;
    if (err) {
        console.log('resume.json does not exist');
        return;
    } else {
        resumeJson = JSON.parse(resumeJson);
    }
    
    console.log('Building resume with template: ' + template);
    
    var render = require(templatePath + '/index').render;
    var outputDir = process.cwd() + '/export';
    
    // Ensure export directory exists
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Write HTML
    fs.writeFileSync(outputDir + '/index.html', render(resumeJson));
    
    // Copy template's CSS file
    var templateCss = path.join(templatePath, 'style.css');
    if (fs.existsSync(templateCss)) {
        fs.copyFileSync(templateCss, outputDir + '/style.css');
    }
    
    console.log('Resume built successfully! Output: export/index.html');
});
