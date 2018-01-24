
var fs = require('fs');

var jsftp = require("jsftp");




//installing FTP Server



// ftp.on('error', function(err){
//   console.log(err);
// });


//         //./manager1/images3/
// ftp.list("./manager1/images3/", (err, res) => {
//   console.log(res);
//   // Prints something like
//   // -rw-r--r--   1 sergi    staff           4 Jun 03 09:32 testfile1.txt
//   // -rw-r--r--   1 sergi    staff           4 Jun 03 09:31 testfile2.txt
//   // -rw-r--r--   1 sergi    staff           0 May 29 13:05 testfile3.txt
//   // ...
// });


// ftp.on('jsftp_debug', function(eventType, data) {
//     console.log('DEBUG: ', eventType);
//     console.log(JSON.stringify(data, null, 2));
// });



exports.endUpload = function(req,res){



  var filename = "";
  var username = ""; 
  var folder = "";

  req.pipe(req.busboy);

  req.busboy.on('field', function(fieldname, val, fieldnameTruncated, valTruncated, encoding, mimetype) {
    

    console.log('Field ON');

    val  = val.replace( "\r\n", "" );
    

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

   // var pathToFTP   = username+"/"+folder+"/"+filename;
    var pathToLocal = "./public/"+username+"/"+folder+"/"+filename;

    if (folder == "") {
    //  pathToFTP   = username+"/"+filename;
      pathToLocal = "./public/"+username+"/"+filename;
    } 

    //pathToLocal = pathToLocal.replace( "\r\n", "" );
   
    console.log(pathToLocal);

    var USER = "allmanager";
    var PASS = "iq7mKydXMnWk";

    var ftp = new jsftp({
      host: "ftp.mlife.dp.ua",
      port: 21, // defaults to 21
      user: USER, // defaults to "anonymous"
      pass: PASS // defaults to "@anonymous"
    });


    // ftp.raw("quit", (err, data) => {
    //   if (err) {}
    
 
      
    

    ftp.auth(USER, PASS, err => { 
      console.log(err);
      console.log("USERRRR");


      console.log(folder);

      ftp.raw("CWD", username, (err, data) => { 

          if (err) { 
            console.log("ERROR");
            console.log(err);
            res.send('Error');
          } else {

              if (folder != "") {
                ftp.raw("CWD", folder, (err, data) => { 

                  if (err) {
                    ftp.raw("mkd", folder, (err, data) => {});
                    ftp.raw("CWD", folder, (err, data) => {});
                  }


                  ftp.put(pathToLocal, filename, err => {
                    if (err) {
                      console.log("ERROR");
                      console.log(err);
                      res.send('Error');
                    } else {
                      //console.log("File (" + pathToFTP + ") copied successfully!" );
                      res.send('OK'); 
                    }
                  });


                });
              } else {
                ftp.put(pathToLocal, filename, err => {
                  if (err) {
                    console.log("ERROR");
                    console.log(err);
                    res.send('Error');
                  } else {
                 //   console.log("File (" + pathToFTP + ") copied successfully!" );
                    res.send('OK'); 
                  }
                });

              }
              
              

          };
      }); 

     // });



    });


    


    // fs.readFile("./public/manager1/images3/1.jpg", "binary", function(err, data) {
    //   if (err) {
    //     console.log(err);
    //     res.send('Error');
    //   } else {

    //     console.log(" Data -------- Read");
    //   //  console.log(data);

    //   //  var buffer = new Buffer(data, "binary");

    //     ftp.put(data, "./1.jpg", err => {
    //       if (!err) {
    //         console.log("File transferred successfully!");
    //         res.send('Error');
    //       } else {
    //         console.log("File (" + pathToFTP + ") copied successfully!" );
    //         res.send('OK'); 
    //       }
    //     });
    //   }
    // });

    

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

        val  = val.replace( "\r\n", "" );

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


      val  = val.replace( "\r\n", "" );

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