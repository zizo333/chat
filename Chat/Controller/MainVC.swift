//
//  ViewController.swift
//  Chat
//
//  Created by Zizo Adel on 12/25/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var btnHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -100
        }
    }

}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FormCell", for: indexPath) as! FormCell
        btnHeight = self.view.frame.height - (cell.actionButton.frame.origin.y + cell.actionButton.frame.size.height)
        if indexPath.row == 0 {
            cell.textFieldContainer.isHidden = true
            cell.slideButton.setTitle("Sign Up 👉", for: .normal)
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(goToSignUpForm(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(signInAction(_:)), for: .touchUpInside)
        } else {
            cell.textFieldContainer.isHidden = false
            cell.slideButton.setTitle("👈 Sign In", for: .normal)
            cell.actionButton.setTitle("Sign Up", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(goToSignInForm(_:)), for: .touchUpInside)
            
            // excute sign up
            cell.actionButton.addTarget(self, action: #selector(signUpAction(_:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    
    @objc func goToSignUpForm(_ sender: CustomButton) {
        let indexPath = IndexPath(row: 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func goToSignInForm(_ sender: CustomButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func signUpAction(_ sender: CustomButton) {
        let indexpath = IndexPath(row: 1, section: 0)
        let cell = self.collectionView.cellForItem(at: indexpath) as! FormCell
        guard let email = cell.emailTF.text, !email.isEmpty,
            let password = cell.passwordTF.text, !password.isEmpty,
            let userName = cell.userNameTF.text, !userName.isEmpty else {
            showAlert(title: "Warning", message: "Check empty fields")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                guard let userId = result?.user.uid else { return }
                self.dismiss(animated: true, completion: nil)
                let ref = Database.database().reference()
                let user = ref.child("users").child(userId)
                let dataArray: [String: Any] = ["username" : userName]
                user.setValue(dataArray)
                // MARK: - Empty Fields
                cell.userNameTF.text = ""
                cell.passwordTF.text = ""
                cell.emailTF.text = ""
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
    
    @objc func signInAction(_ sender: CustomButton) {
        let indexpath = IndexPath(row: 0, section: 0)
        let cell = self.collectionView.cellForItem(at: indexpath) as! FormCell
        guard let email = cell.emailTF.text, !email.isEmpty,
            let password = cell.passwordTF.text, !password.isEmpty else {
            showAlert(title: "Warning", message: "Check empty fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
                cell.passwordTF.text = ""
                cell.emailTF.text = ""
            } else {
                self.showAlert(title: "Error", message: "Wrong password or email")
            }
        }
    }
    
    // MARK: - show alert
    private func showAlert(title: String,message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Mark: - Set size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

