//
//  StorageManager.swift
//  MessengerApp
//
//  Created by Maxim Mitin on 9.02.22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    
    private let storage = Storage.storage().reference()
    
    
    /// Upload picture to FB Storage
    public typealias uploadPictureCompletion = (Result<String, Error>)->Void
    public func uploadProfilePictrue(withData data: Data,
                                     filename: String, completionHandler : @escaping uploadPictureCompletion ) {
        storage.child("image/\(filename)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completionHandler(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // child was image, not images/  that planned to be
            self.storage.child("image/\(filename)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL")
                    completionHandler(.failure(StorageErrors.failedTogetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completionHandler(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedTogetDownloadUrl
    }
}
