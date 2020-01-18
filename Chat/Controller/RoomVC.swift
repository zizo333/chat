//
//  RsoomVC.swift
//  Chat
//
//  Created by Zizo Adel on 12/26/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit
import Firebase

class RoomVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Outlets
    @IBOutlet weak var roomTable: UITableView!
    @IBOutlet weak var roomNameTF: UITextField!
    
    // MARK: - Variables
    var rooms = [Room]()
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        observeNewRooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser == nil {
            self.presentSignInScreen()
        }
    }
    
    // MARK: Observe new rooms
    func observeNewRooms() {
        let ref = Database.database().reference()
        ref.child("rooms").observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? [String : Any] {
                if let roomName = data["roomName"] as? String {
                    let room = Room.init(roomId: snapshot.key, roomName: roomName)
                    self.rooms.append(room)
                    self.roomTable.reloadData()
                }
            }
        }
    }
    
    // MARK: - log out
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        presentSignInScreen()
    }
    
    // MARK: - show sign in screen
    func presentSignInScreen() {
        let signInForm = storyboard?.instantiateViewController(identifier: "signinForm") as! MainVC
        present(signInForm, animated: true, completion: nil)
    }
    
    // MARK: - create new room 
    @IBAction func createRoomButton() {
        guard let roomName = roomNameTF.text, !roomName.isEmpty else {
            showAlert(title: "Warning", message: "Please enter chat room name")
            return
        }
        // check if the room name is exist or ont
        for room_name in rooms {
            if roomName == room_name.roomName {
                showAlert(title: "Warning", message: "Room name is exist")
                return
            }
        }
        let ref = Database.database().reference()
        let room = ref.child("rooms").childByAutoId()
        
        let dataArray:[String : Any] = ["roomName" : roomName]
        room.setValue(dataArray) { (error, refrence) in
            if error == nil {
                self.roomNameTF.text = ""
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


extension RoomVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let roomName = rooms[indexPath.row].roomName
        cell.textLabel?.text = roomName
        cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomVC = self.storyboard?.instantiateViewController(identifier: "chatRoom") as! ChatRoomVC
        chatRoomVC.room = rooms[indexPath.row]
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension RoomVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createRoomButton()
        return true
    }
}
