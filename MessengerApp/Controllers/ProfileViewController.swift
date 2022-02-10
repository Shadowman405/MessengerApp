//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 2.02.22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTablewHeader()
    }
    
    func createTablewHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let filename = safeEmail + "_progile_picture.png"
        let path = "image/"+filename
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        headerView.addSubview(imageView)
        headerView.contentMode = .scaleAspectFill
        headerView.layer.borderColor = UIColor.white.cgColor
        headerView.layer.borderWidth = 3
        headerView.layer.masksToBounds = true
        
        return headerView
    }

}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
            guard let strongSelf = self else {return}
            //Logout FB
            FBSDKLoginKit.LoginManager().logOut()
            
            //Logout Google
            GIDSignIn.sharedInstance().signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                
                strongSelf.present(nav, animated: false)
            } catch {
                print("Fialed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
}
