//
//  ChatViewController.swift
//  TeamUp!
//
//  Created by Alicia Ho on 6/7/20.
//  Copyright © 2020 Alicia Ho. All rights reserved.
//

import UIKit
import MessageKit

struct Message : MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    
}

struct Sender: SenderType{
    var photoURL: String
    var senderId: String
    var displayName: String
    
    
}

class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Joe")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello World Hello World Hello World")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello World Hello World Hello World")))
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
