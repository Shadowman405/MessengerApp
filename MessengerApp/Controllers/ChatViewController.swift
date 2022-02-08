//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 8.02.22.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Uncle Bogdan")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello bebra")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Do you wanna suck some leather things for 300 bucks ??")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}


//MARK: - Extensions

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       return messages.count
    }
    
    struct Message: MessageType {
        var sender: SenderType
        var messageId: String
        var sentDate: Date
        var kind: MessageKind
    }

    struct Sender: SenderType {
        var photoURL : String
        var senderId: String
        var displayName: String
    }
}
