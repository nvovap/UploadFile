var express = require('express'),
	busboy = require('connect-busboy'),
	app = express(),
	server;


//Setup parser file from POST request
app.use(busboy());
app.use(busboy({ immediate: true }));

//================ Start SERVER ================  
var server = app.listen(process.env.PORT || 3000, function(){
	console.log('Server running on port '+(process.env.PORT || 3000)+'.');
	console.log('-----------------------------------');
	console.log(express.static(__dirname+'/public'));
	console.log(__dirname+'/public');
	console.log('-----------------------------------');

})



var uploadFile = require('./upload_file');

app.post('/uploadBlock', uploadFile.uploadBlock);
app.post('/getSizeFile', uploadFile.getSizeFile);
app.post('/endUpload', uploadFile.endUpload);