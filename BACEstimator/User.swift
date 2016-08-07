//
//  User.swift
//  BACEstimator
//
//  Created by H Hugo Falkman on 2016-08-05.
//  Copyright © 2016 H Hugo Falkman. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(userData: FIRUser) {
        uid = userData.uid
        
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
