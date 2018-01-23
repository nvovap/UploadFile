
var fs = require('fs');



exports.endUpload = function(req,res){

  var filename = "";
  var username = ""; 
  var folder = "";

  req.pipe(req.busboy);

  req.busboy.on('field', function(fieldname, val, fieldnameTruncated, valTruncated, encoding, mimetype) {
    

    console.log('Field ON');

    if (fieldname == 'user') {
      username = val;
    }

    if (fieldname == 'fileName') {
      filename = val;
    }
    
    if (fieldname == 'folder') {
      folder = val;
    }

  });

  req.busboy.on('finish', function() {
    console.log("username = " + username + " folder = " + folder + " filename = " + filename);

    var DBFiles =  require('./Mongo/DBFiles');

      
    DBFiles.newFile(username, folder, filename, 0, 0,  res);


    //res.send('OK');
  });


}





exports.uploadBlock = function(req,res){

	var filename = "";
	var username = ""; 
	var folder = "";

	req.pipe(req.busboy);


  req.busboy.on('field', function(fieldname, val, fieldnameTruncated, valTruncated, encoding, mimetype) {
        console.log('Field [' + fieldname + ']: value: ' + val);

        console.log('Field ON');

        if (fieldname == 'user') {
          username = val;
        }

        if (fieldname == 'fileName') {
          filename = val;
        }
    
      if (fieldname == 'folder') {
          folder = val;
      }
  });


	req.busboy.on('file', function(fieldname, file, file_name){
		console.log("OK busboy file");


		//var stream = new fs.WriteStream("public/img/"+filename);
		console.log('FILE ON');


		console.log("fieldname = "+fieldname+"; filename = "+filename);

		var stream;

		if (folder == "") {
			stream = new fs.WriteStream("public/"+username+"/"+filename, {flags: 'a', defaultEncoding: 'binary'});
		} else {
			stream = new fs.WriteStream("public/"+username+"/"+folder+"/"+filename, {flags: 'a', defaultEncoding: 'binary'});
		}
		

		// file.on('data', function(data) {

		// 	stream.write(data);

		// 	fs.appendFileSync
		// });


		// file.on('end', function() {
  //       	stream.close()
  //       	res.send('OK');
  //     	});

		file.pipe(stream);


		stream.on('close', function(){
			res.send('OK');
		});


	});

	
}

exports.getSizeFile = function(req,res){

	var filename = "";
	var username = ""; 
	var folder = "";


	req.pipe(req.busboy); 

	 req.busboy.on('file', function(fieldname, file, filename, encoding, mimetype) {
      
      console.log('File [' + fieldname + ']: filename: ' + filename + ', encoding: ' + encoding + ', mimetype: ' + mimetype);
      
      file.on('data', function(data) {
        console.log('File [' + fieldname + '] got ' + data.length + ' bytes');
      });

      file.on('end', function() {
        console.log('File [' + fieldname + '] Finished');
      });

    });
    

    req.busboy.on('field', function(fieldname, val, fieldnameTruncated, valTruncated, encoding, mimetype) {
      console.log('Field [' + fieldname + ']: value: ' + val);

      if (fieldname == 'user') {
      	username = val;
      }

      if (fieldname == 'fileName') {
      	filename = val;
      }


      if (fieldname == 'folder') {
      	folder = val;
      }

    });

    req.busboy.on('finish', function() {

      console.log("Finish file info !!!!")

    	var exist = true;
      	
    	if (!fs.existsSync("public/"+username)){

  			fs.mkdirSync("public/"+username);

  			exist = false;

    	};

    	if (folder != "") {
    		if (!fs.existsSync("public/"+username+"/"+folder)){

  				fs.mkdirSync("public/"+username+"/"+folder);

  				exist = false;
    		};
    	};

    	if (exist) {

			var filePath = "public/"+username+"/"+folder+"/"+filename; 

			if (folder == "") {
				filePath = "public/"+username+"/"+filename; 
			}

			var sizeFile = 0;	

			console.log(filePath);

			if (fs.existsSync(filePath)){
				var stat = fs.statSync(filePath);
    			console.log('Size file = '+ stat.size);

    			sizeFile =  stat.size;
    		}

    		res.send(""+sizeFile);
    		console.log('OK');
    	} else {
    		res.send('END');
    		console.log('END');
    	};


    });
    
};