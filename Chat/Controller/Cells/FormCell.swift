//
//  FormCell.swift
//  Chat
//
//  Created by Zizo Adel on 12/25/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit

class FormCell: UICollectionViewCell {
    
    
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var actionButton: CustomButton!
    @IBOutlet weak var slideButton: CustomButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        
        addbuttonToPasswordField()
    }
    
    func addbuttonToPasswordField() {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        rightButton.setBackgroundImage(UIImage(named: "pass"), for: .normal)
        rightButton.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
        passwordTF.rightView = rightButton
        passwordTF.rightViewMode = UITextField.ViewMode.always
    }
    
    @objc func showHidePassword() {
        passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
}

extension FormCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if userNameTF.isFirstResponder {
            emailTF.becomeFirstResponder()
        } else if emailTF.isFirstResponder {
            passwordTF.becomeFirstResponder()
        } else {
            passwordTF.resignFirstResponder()
        }
        return true
    }
}

