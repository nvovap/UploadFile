//
//  ViewController.swift
//  UploadImage
//
//  Created by Vladimir Nevinniy on 1/23/18.
//  Copyright © 2018 Vladimir Nevinniy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onButtonUploadFile(_ sender: UIButton) {
        let uploaderFile = NVPUploadImage()
        
//        if let image = UIImage(named: "1") {
//            if let data = UIImagePNGRepresentation(image) {
//                 uploaderFile.uploadFile(data, fileName: "1.jpg", user: "manager1", folder: "images")
//            }
//
//        }
        
       // Bundle.main.path(forResource: "1", ofType: "jpg")
        
        if let path = Bundle.main.path(forResource: "1", ofType: "")  {
            if let url = URL(string: path)  {
                
                do {
                    let data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedRead)
                    uploaderFile.uploadFile(data, fileName: "1.jpg", user: "manager1", folder: "images")
                } catch {
                    
                }
                
                
            }


        }
        
        
    }
    
}

