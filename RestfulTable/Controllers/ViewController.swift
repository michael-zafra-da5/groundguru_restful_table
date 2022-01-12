//
//  ViewController.swift
//  RestfulTable
//
//  Created by Michael Angelo Zafra on 1/12/22.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    
    var cellReuseIdentifier = "userCell"
    var userList: [UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        //Start loading...
        AF.request("https://reqres.in/api/users?page=1").responseString(completionHandler: { response in
            switch response.result {
            case .success(let value):
                //end loading..
                print("value**: \(value)")
                do {
                    let data = try value.data(using: .utf8)!
                    print("data \(data)")
                    let decoder = JSONDecoder()
                    if let responseListData = try? decoder.decode(ListResponse.self, from: data) {
                        print("responseListData \(responseListData)")
                        self.userList = responseListData.data
                        self.tableview.reloadData()
                    }
                } catch {
                    // handle error
                    print("error")
                }
            case .failure(let error):
                //end loading..
                print(error)
                let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Details", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "detailSB") as! DetailsViewController
        detailVC.segueData = userList[indexPath.row]
        self.present(detailVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "userCell") as! UserTableCell
        
        let user = userList[indexPath.row]
        cell.nameLbl.text = "\(user.first_name) \(user.last_name)"
        cell.email.text = user.email
        
        //Alamofire Image
        AF.request(user.avatar, method: .get).response { response in
            guard let image = UIImage(data:response.data!) else {
                // Handle error
                return
            }
            let imageData = image.jpegData(compressionQuality: 1.0)
            cell.avatarImageView.image = UIImage(data : imageData!)
        }
        return cell
    }
    
}

