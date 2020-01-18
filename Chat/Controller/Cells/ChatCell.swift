//
//  ChatCell.swift
//  Chat
//
//  Created by Zizo Adel on 12/27/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    enum BubbleType {
        case incoming
        case outgoing
    }

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var containerTextView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    
    func generateCell(message: Message) {
        senderNameLabel.text = message.senderName
        messageTextView.text = message.messageText
        
        containerTextView.layer.cornerRadius = 6
    }
    
    func updateBubble(type: BubbleType) {
        if type == .incoming {
            containerStackView.alignment = .leading
            containerTextView.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            messageTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else if type == .outgoing {
            containerStackView.alignment = .trailing
            containerTextView.backgroundColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
            messageTextView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

}
