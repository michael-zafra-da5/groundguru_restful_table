//
//  DetailsViewController.swift
//  RestfulTable
//
//  Created by Michael Angelo Zafra on 1/12/22.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class DetailsViewController: UIViewController {
    
    var segueData:UserData? = nil
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fnameLbl: UILabel!
    @IBOutlet weak var lnameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        
        stackView.setCustomSpacing(15, after: fnameLbl)
        stackView.setCustomSpacing(15, after: lnameLbl)
        stackView.setCustomSpacing(15, after: emailLbl)
        
        let userId = segueData?.id ?? 0
        AF.request("https://reqres.in/api/users/\(userId)").responseString(completionHandler: { response in
            switch response.result {
            case .success(let value):
                print("value**: \(value)")
                do {
                    let data = try value.data(using: .utf8)!
                    print("data \(data)")
                    let decoder = JSONDecoder()
                    if let responseDetails = try? decoder.decode(DetailResponse.self, from: data) {
                        print("responseDetails \(responseDetails)")
                        self.fnameLbl.text = responseDetails.data.first_name
                        self.lnameLbl.text = responseDetails.data.last_name
                        self.emailLbl.text = responseDetails.data.email
                        
                        //Alamofire Image
                        AF.request(responseDetails.data.avatar, method: .get).response { response in
                            guard let image = UIImage(data:response.data!) else {
                                // Handle error
                                return
                            }
                            let imageData = image.jpegData(compressionQuality: 1.0)
                            self.avatarImageView.image = UIImage(data : imageData!)
                        }
                    }
                } catch {
                    // handle error
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
