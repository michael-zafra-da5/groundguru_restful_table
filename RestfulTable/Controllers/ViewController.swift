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
        
        AF.request("https://reqres.in/api/users?page=1").responseString(completionHandler: { response in
            switch response.result {
            case .success(let value):
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
                print(error)
            }
        })
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

