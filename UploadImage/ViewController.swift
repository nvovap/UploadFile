//
//  ViewController.swift
//  UploadImage
//
//  Created by Vladimir Nevinniy on 1/23/18.
//  Copyright © 2018 Vladimir Nevinniy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NVPUploadImageDelegate {

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

        uploaderFile.delegate = self

        if let path = Bundle.main.path(forResource: "1", ofType: "")  {
         //  if let url = URL(string: path)  {

                if let image = UIImage(contentsOfFile: path) {
                    if let data = UIImagePNGRepresentation(image) {
                        uploaderFile.uploadFile(data, fileName: "1.jpg", user: "manager1", folder: "images3")
                    }
                }



//                do {
//                    let data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedRead)
//                    uploaderFile.uploadFile(data, fileName: "1.jpg", user: "manager1", folder: "images")
//                } catch {
//
//                }


          //  }


        }
        
        
        let uploaderFile2 = NVPUploadImage()

        uploaderFile2.delegate = self

        if let path = Bundle.main.path(forResource: "2", ofType: "")  {
            //  if let url = URL(string: path)  {

            if let image = UIImage(contentsOfFile: path) {
                if let data = UIImagePNGRepresentation(image) {
                    uploaderFile2.uploadFile(data, fileName: "2.jpg", user: "manager1", folder: "images3")
                }
            }



            //                do {
            //                    let data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedRead)
            //                    uploaderFile.uploadFile(data, fileName: "1.jpg", user: "manager1", folder: "images")
            //                } catch {
            //
            //                }


            //  }


        }
        
        
    }
    
    func fullUploadFile(_ fileName: String, order: String) {
        print(order)
        print(fileName)
    }
    
}

