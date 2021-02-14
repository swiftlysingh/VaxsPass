//
//  HomeViewController.swift
//  VaxsPass
//
//  Created by Pushpinder Pal Singh on 13/02/21.
//

import UIKit
import Vision
import Alamofire

class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var GenerateQRButton: UIButton!
    var qrcodeImage: CIImage!
    let create_user_params : [String:Any] = [
        "oauth": "testing123",
        "name": "test123",
        "date" : "01/01/2021",
        "vaccine_type" : "None",
        "taken": 1,
        "completed": false
    ]
    @IBAction func GenerateQRCode(_ sender: Any) {
        AF.request("https://glacial-inlet-64915.herokuapp.com/create-user", method: .post, parameters: create_user_params, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
            }
        let passUrl = "https://glacial-inlet-64915.herokuapp.com/index.html?oauth=nada"
        let stringData = passUrl.data(using: .utf8)
        if qrcodeImage == nil {
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(stringData, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            qrcodeImage = filter?.outputImage
            imgQRCode.image = UIImage(ciImage: qrcodeImage)
        }
    }
    let image = UIImagePickerController()
    let headers: HTTPHeaders = [
        "Authorization": "Bearer AIzaSyBZZOFM9otkX6J0NsDtDoNyNybY3HG7xeE",
        "Content-Type": "application/json; charset=utf-8"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.delegate = self
        image.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage , let base64Image = userImage.jpegData(compressionQuality: 1)?.base64EncodedString(){
            
            let json = """
{
            "requests": [
              {
                "image": {
                  "content": \(base64Image)
                },
                "features": [
                  {
                    "type": "DOCUMENT_TEXT_DETECTION"
                  }
                ]
              }
            ]
          }
"""
            let parameters = json.data(using: .utf8)!
            let result = AF.request("https://vision.googleapis.com/v1/images:annotate", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            print(result.data)
        }
    }
    
    @IBAction func addDocumentsPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose a Source", message: "From where would you like to add the document?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.image.sourceType = .camera
            self.present(self.image, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.image.sourceType = .photoLibrary
            self.present(self.image, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}
