//
//  ChatViewController.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 8.02.22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
    public var photoURL : String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
        return Sender(photoURL: "",
                      senderId: email,
                      displayName: "Uncle Bogdan")
    }
    
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
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}


//MARK: - Extensions

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email not cashed")
        return Sender(photoURL: "", senderId: "12", displayName: "Bodya")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       return messages.count
    }
    
    
    //MARK: - InputBarAccessoryViewDelegate  extensions
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let messageId = createMessageId()
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender else {return}
        
        print("Sending: \(text)")
        //Send message
        if isNewConversation {
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewCoversation(with: otherUserEmail,name: self.title ?? "User" ,firstMessage: message) {[weak self] success in
                if success {
                    print("message sent")
                } else {
                    print("failed to send")
                }
            }
        } else {
            //append to existing conversation
        }
    }
    
    private func createMessageId() -> String {
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {return ""}
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAdress: currentUserEmail)
        let newIdentifier = ("\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)")
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }

}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
