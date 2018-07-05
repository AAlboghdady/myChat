//
//  Constants.swift
//  myChat
//
//  Created by Sain-R Edwards on 7/4/18.
//  Copyright © 2018 Swift Koding 4 Everyone. All rights reserved.
//

import Foundation
import Firebase

struct Constants {
    
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
    
}
