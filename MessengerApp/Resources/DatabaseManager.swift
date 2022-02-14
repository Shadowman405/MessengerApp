//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 5.02.22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAdress: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: - Account Managment

extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool)-> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String:String]] {
                    //append new user
                    let newElement = [
                        "name" : user.firstName + " " + user.lastName,
                        "email" : user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
                else {
                    // create array
                    let newCollection: [[String: String]] = [
                        [
                            "name" : user.firstName + " " + user.lastName,
                            "email" : user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAdress: String
    
    var safeEmail: String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}

//MARK: - Sending messages/conversations with Database

extension DatabaseManager {
    
    //Creates a new conv with target user email and first message sent
    public func createNewCoversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {return}
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentEmail)
        let reference = database.child("\(safeEmail)")
        
        reference.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversaionData: [String:Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String:Any]] {
                conversations.append(newConversaionData)
                userNode["conversations"] = conversations
                reference.setValue(userNode) {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }

            } else {
                userNode["conversations"] = [
                    newConversaionData
                ]
                
                reference.setValue(userNode) {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name, conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping ((Bool) -> Void)) {
        
        var message = ""
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return}
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
        
        let collectionMessage: [String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation],Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMesageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMesageObject)
            })
            completion(.success(conversations))
        }
    }
    
    
    // Get all messages for a given conversation
    public func getAllMessagesForConversation(with id:String, copmletion: @escaping (Result<String,Error>) -> Void){
        
    }
    
    //Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
}
