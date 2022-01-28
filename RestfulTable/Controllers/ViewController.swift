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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var listDisplaybtn: UIButton!
    
    var cellReuseIdentifier = "userCell"
    var userList: [UserData] = []
    
    //Collection
    let inset: CGFloat = 30
    let cellsPerRow = 2
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    
    @IBAction func taplistDisplay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.updateDisplay(isList: sender.isSelected)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.contentInsetAdjustmentBehavior = .always
        
        listDisplaybtn.isSelected = false
        
        listDisplaybtn.setImage(UIImage(named: "ic_grid")?.resizeImage(48, opaque: false), for: .selected)
        listDisplaybtn.setImage(UIImage(named: "ic_list")?.resizeImage(48, opaque: false), for: .normal)
//        listDisplaybtn.setImage(UIImage(), for: .disabled)
//        listDisplaybtn.setTitle("", for: .normal)
//        listDisplaybtn.setTitle("no check", for: .selected)
        
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
                        //                        self.tableview.reloadData()
                        self.updateDisplay(isList: false)
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
    
    func updateDisplay(isList:Bool){
        if isList {
            tableview.isHidden = false
            collectionView.isHidden = true
            tableview.reloadData()
        } else {
            tableview.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleting: \(userList[indexPath.row])")
            deleteToDatabase(user: userList[indexPath.row])
            userList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func deleteToDatabase(user: UserData) {
        print("Deleted: \(user)")
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCollectionCell", for: indexPath as IndexPath) as! UserCollectionCell
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Details", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "detailSB") as! DetailsViewController
        detailVC.segueData = userList[indexPath.row]
        self.present(detailVC, animated: true, completion: nil)
    }
    
    //For Cell Layout
    //    func collectionView(_ collectionView: UICollectionView,
    //                        layout collectionViewLayout: UICollectionViewLayout,
    //                        sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: 90, height: 180)
    //    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}


