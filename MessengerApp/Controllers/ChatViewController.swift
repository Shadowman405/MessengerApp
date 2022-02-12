//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 8.02.22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Uncle Bogdan")
    
    init (with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello bebra")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Do you wanna suck some leather things for 300 bucks ??")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
}


//MARK: - Extensions

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
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
    
    //MARK: - InputBarAccessoryViewDelegate  extensions
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        
        //Send message
        if isNewConversation {
            //create new conversation in DB
        } else {
            //append to existing conversation
        }
    }
}

