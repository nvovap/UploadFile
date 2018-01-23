import UIKit


//public protocol NVPUploadImageDelegate : NSObjectProtocol {
//    
//    
//  //  optional public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?
//  func NVPUploadImage(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
//    
//}

//\ if let image = myImageView.image {
//    NVPUploadImage.sharedInstance.uploadFile(image, fileName: "2.jpg", user: "manager45", folder: "")
//}


class NVPUploadImage : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
//    private static var __once: () = {
//            Static.instance = NVPUploadImage()
//            
//            
//            
//            let configuration = URLSessionConfiguration.background(withIdentifier: "bgNVOVAPSessionConfiguration")
//            configuration.httpMaximumConnectionsPerHost = 4; //iOS Default is 4
//            configuration.timeoutIntervalForRequest = 600.0; //30min allowance; iOS default is 60 seconds.
//            configuration.timeoutIntervalForResource = 120.0; //2min; iOS Default is 7 days
//            configuration.allowsCellularAccess = true
//                
//            Static.instance!.backgroundSession = Foundation.URLSession(configuration: configuration, delegate: Static.instance!, delegateQueue: nil) //Static.instance!.downloadQueue)
//        }()
    
   // var backgroundSession: Foundation.URLSession!
    
    
    private lazy var backgroundSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return Foundation.URLSession.init(configuration: config, delegate: self, delegateQueue: nil)  //(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    
    var server = "http://10.10.1.56:3000"
    
    //var server = "https://myftp.herokuapp.com"
    
    //var server = "http://myftp.eu-gb.mybluemix.net"
    
    
    fileprivate var data: Data!
    fileprivate var fileName = ""
    fileprivate var currentTask = 0
    fileprivate var user = ""
    fileprivate var folder = ""
    
    fileprivate var allSend: Bool = false
    var runing = false
    
//    var delegate: NVPUploadImageDelegate?
    
    fileprivate let SIZE_BLOCK = 500_000
    
//    static let shared: GetLocation = {
//        let instance = GetLocation()
//        return instance
//    }()


    
    static let sharedInstance: NVPUploadImage = {
        let instance = NVPUploadImage()
        return instance
    }()
    
    
    //MARK: session delegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("session \(session) occurred error \(error?.localizedDescription)")
            
            runing = false
            
        }
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
      //  let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        
        //print("session \(session) uploaded \(uploadProgress * 100)%.")
        
        //        dispatch_async(dispatch_get_main_queue()) {
        //            self.myProgressView.progress = uploadProgress;
        //        }
        
    }
    
    private func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: @escaping (Foundation.URLSession.ResponseDisposition) -> Void) {
        
        
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        
    }
    
    
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        //        responseData.appendData(data)
    }
    
    
    
    
    //=================================
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("session error: \(error?.localizedDescription).")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
       // print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
        
        
        if downloadTask.taskDescription == "--GetInfoFile--" {

            var size = 0
            
            if let data = try? Data(contentsOf: location), let str = String(data: data, encoding: String.Encoding.utf8), let sizeTemp = Int(str) {
                size = sizeTemp 
            }
            
            
            self.uploadFileBlock(size)
            
            
            return
        } else if downloadTask.taskDescription == "--GetFile--" {
            
            if allSend == false {
                self.getInfoFile()
            }
        }
    }
    

   
    
    //MARK: - Create Tasks
    
    func uploadFile(_ data: Data, fileName: String, user: String, folder: String) {
        
        self.fileName = fileName
        self.user = user
        self.folder = folder
        
        
        allSend = false
        
        if runing == false {
            runing = true
            
            self.data = data
                
            self.getInfoFile()
        }
            
        
    }
    
    
    
    
    fileprivate func getInfoFile() {
        
        //let uri  = NSURL(string: "https://myftp.herokuapp.com/igor")!
        
       // fileName = fileNames[currentTask]
        
        
        let uri  = URL(string: server+"/getSizeFile")!
        
        var req = URLRequest(url: uri)
        
        
        req.httpMethod = "POST"
        
        let boundary = "Boundary\(arc4random())\(arc4random())"
        let boundaryStart = "--\(boundary)\r\n"
        let boundaryEnd = "--\(boundary)--\r\n"
        
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        let body = NSMutableData()
        let tempData = NSMutableData()
        
        tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
        let nameData = "Content-Disposition: form-data; name=\"user\"\r\n\r\n\(user)\r\n"
        tempData.append(nameData.data(using: String.Encoding.utf8)!)
        
        
        tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
        let foolderData = "Content-Disposition: form-data; name=\"folder\"\r\n\r\n\(folder)\r\n"
        tempData.append(foolderData.data(using: String.Encoding.utf8)!)
        
        
        
        tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
        let fileNameData = "Content-Disposition: form-data; name=\"fileName\"\r\n\r\n\(fileName)\r\n"
        tempData.append(fileNameData.data(using: String.Encoding.utf8)!)
        
        //tempData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.append(tempData as Data)
        body.append("\(boundaryEnd)".data(using: String.Encoding.utf8)!)
        
        
        //print("\(body.length)")
        
        req.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        req.httpBody = body as Data
        
        
        
        
        //        for stringUrl in data {
        let task = backgroundSession.downloadTask(with: req)
        
        task.taskDescription = "--GetInfoFile--"
        
        
        //        }
        
        
        
        //            let task = backgroundSession.dataTaskWithRequest(req, completionHandler: { (data, res, error) in
        //                print(data)
        //            })
        
        task.resume()
        
        
    }
    
    
    fileprivate func uploadFileBlock(_ size: Int) {
        //if let data = imageJPEG {
            
            //  let filePath = NSBundle.mainBundle().pathForResource("1", ofType:"")!
            
            //if let data = NSData(contentsOfFile:filePath) {
        var lengthData = data.count
            
            
            if lengthData > size {
                
                lengthData -= size
                
                if lengthData > SIZE_BLOCK {
                    lengthData = SIZE_BLOCK
                }
                
                
                let blockData = NSMutableData()
                
                
                
                blockData.append(data.subdata(in: size..<lengthData+size))
                
                
               // blockData.append(data.subdata(in: Range(location: size, length: lengthData)))
                
                
                
                
                //     tempData.appendData(data.bytes[point])
                
                
                let uri  = URL(string: server+"/uploadBlock")!
                
                
                var req = URLRequest(url: uri)
                
                
                req.httpMethod = "POST"
                
                
                let boundary = "-----Boundary\(arc4random())\(arc4random())"
                let boundaryStart = "--\(boundary)\r\n"
                let boundaryEnd = "--\(boundary)--\r\n"
                
                
                let contentType = "multipart/form-data; boundary=\(boundary)"
                req.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                
                let body = NSMutableData()
                let tempData = NSMutableData()
                
                
                //                tempData.appendData("\(boundaryStart)".dataUsingEncoding(NSUTF8StringEncoding)!)
                //                tempData.appendData("Content-Disposition: form-data; name=\"description\"\r\n\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                
                
                //USER
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let nameData = "Content-Disposition: form-data; name=\"user\"\r\n\r\n\(user)\r\n"
                tempData.append(nameData.data(using: String.Encoding.utf8)!)
                
                
                
                //FOLDER
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let foolderData = "Content-Disposition: form-data; name=\"folder\"\r\n\r\n\(folder)\r\n"
                tempData.append(foolderData.data(using: String.Encoding.utf8)!)
                
                
                //FILE NAME
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let fileNameData = "Content-Disposition: form-data; name=\"fileName\"\r\n\r\n\(fileName)\r\n"
                tempData.append(fileNameData.data(using: String.Encoding.utf8)!)
                
                
                //File
                let mimeType = "data"
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let fileNameContentDisposition =  "filename=\"\(user)_\(folder)_\(fileName)\""
                let contentDisposition = "Content-Disposition: form-data; name=\"\(mimeType)\"; \(fileNameContentDisposition)\r\n"
                
                
                tempData.append(contentDisposition.data(using: String.Encoding.utf8)!)
                tempData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
                tempData.append(blockData as Data)
                //tempData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                
                body.append(tempData as Data)
                
                body.append("\r\n\(boundaryEnd)".data(using: String.Encoding.utf8)!)
                
                
                
                req.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
                
                
                
                
                req.httpBody = body as Data
                
                
                
                
                
                //        for stringUrl in data {
                let task = backgroundSession.downloadTask(with: req)
                //        }
                
                
                
                //            let task = backgroundSession.dataTaskWithRequest(req, completionHandler: { (data, res, error) in
                //                print(data)
                //            })
                
                task.taskDescription = "--GetFile--"
                
                task.resume()
                
                
            } else {
                allSend = true
                
                runing = false
                

                
                let uri  = URL(string: server+"/endUpload")!
                
                
                var req = URLRequest(url: uri)
                
                
                req.httpMethod = "POST"
                
                
                let boundary = "-----Boundary\(arc4random())\(arc4random())"
                let boundaryStart = "--\(boundary)\r\n"
                let boundaryEnd = "--\(boundary)--\r\n"
                
                
                let contentType = "multipart/form-data; boundary=\(boundary)"
                req.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                
                let body = NSMutableData()
                let tempData = NSMutableData()
                
                
                //                tempData.appendData("\(boundaryStart)".dataUsingEncoding(NSUTF8StringEncoding)!)
                //                tempData.appendData("Content-Disposition: form-data; name=\"description\"\r\n\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                
                
                //USER
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let nameData = "Content-Disposition: form-data; name=\"user\"\r\n\r\n\(user)\r\n"
                tempData.append(nameData.data(using: String.Encoding.utf8)!)
                
                
                
                //FOLDER
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let foolderData = "Content-Disposition: form-data; name=\"folder\"\r\n\r\n\(folder)\r\n"
                tempData.append(foolderData.data(using: String.Encoding.utf8)!)
                
                
                //FILE NAME
                tempData.append("\(boundaryStart)".data(using: String.Encoding.utf8)!)
                let fileNameData = "Content-Disposition: form-data; name=\"fileName\"\r\n\r\n\(fileName)\r\n"
                tempData.append(fileNameData.data(using: String.Encoding.utf8)!)
                
                
               
                
                
                body.append(tempData as Data)
                
                body.append("\r\n\(boundaryEnd)".data(using: String.Encoding.utf8)!)
                
                
                
                req.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
                
                
                
                
                req.httpBody = body as Data
                
                
                
                
                
                //        for stringUrl in data {
                let task = backgroundSession.downloadTask(with: req)
                //        }
                
                
                
                //            let task = backgroundSession.dataTaskWithRequest(req, completionHandler: { (data, res, error) in
                //                print(data)
                //            })
                
                task.taskDescription = "--EndSendFile--"
                
                task.resume()
                
                
                print("OK very well")
            }
            
        //}
    }
    
}
