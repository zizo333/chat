//
//  ChatRoomVC.swift
//  Chat
//
//  Created by Zizo Adel on 12/26/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Outlets
    @IBOutlet weak var chatTF: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var keyboardHeightLayout: NSLayoutConstraint!
    
    // MARK: - Variables
    var room: Room?
    var messages: [Message] = []
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room?.roomName!
        chatTable.separatorStyle = .none
        chatTable.allowsSelection = false
        observeMessageFromFirebase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatTF.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        self.keyboardHeightLayout.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        @objc func keyboardDidShow(notification: NSNotification) {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardHeightLayout.constant = keyboardRect.height
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    
    // MARK: - Actionc
    func observeMessageFromFirebase() {
        let ref = Database.database().reference()
        guard let roomId = room?.roomId else { return }
        let messagesRef = ref.child("rooms").child(roomId).child("messages")
        messagesRef.observe(.childAdded) { (snapshot) in
            if let dataArray = snapshot.value as? [String : Any] {
                guard let senderName = dataArray["senderName"] as? String,
                    let messageText = dataArray["text"] as? String,
                    let senderId = dataArray["senderId"] as? String else { return }
                let message = Message.init(messageId: snapshot.key, senderName: senderName, messageText: messageText, senderId: senderId)
                self.messages.append(message)
                self.chatTable.reloadData()
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
    }
    
    @IBAction func sendMessagseAction() {
        guard let chatText = chatTF.text, !chatText.isEmpty else {
            showAlert(title: "Warning", message: "Please enter chat text")
            return
        }
        sendMessage(text: chatText) { (isSuccess) in
            if isSuccess {
                self.chatTF.text = ""
            }
        }
        
    }
    // MARK: - send message
    func sendMessage(text: String, completion: @escaping(_ isSuccess: Bool) -> ()) {
        
        let ref = Database.database().reference()
        if let userId = Auth.auth().currentUser?.uid {
            getUsernameById(userId: userId) { (userName) in
                if userName != nil {
                    let dataArray:[String : Any] = ["senderName" : userName!, "text" : text, "senderId" : userId]
                    if let roomId = self.room?.roomId, let _ = self.room?.roomName {
                        let room = ref.child("rooms").child(roomId)
                        room.child("messages").childByAutoId().setValue(dataArray) { (error, ref) in
                            if error == nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - get username by id
    func getUsernameById(userId: String, completion: @escaping(_ userName: String?) -> ()) {
        let ref = Database.database().reference()
        let user = ref.child("users")
        user.child(userId).child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let userName = snapshot.value as? String {
                completion(userName)
            } else {
                completion(nil)
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
    
}

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ChatCell
        cell.generateCell(message: message)
        if let currentUserId = Auth.auth().currentUser?.uid {
            if message.senderId == currentUserId {
                cell.updateBubble(type: .outgoing)
            } else {
                cell.updateBubble(type: .incoming)
            }
        }
        return cell
    }
    
}

extension ChatRoomVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessagseAction()
        return true
    }
}
