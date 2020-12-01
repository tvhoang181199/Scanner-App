//
//  Account.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class Account : Mappable {
    
    var firstName = ""
    var lastName = ""
    var email = ""
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        firstName           <- map["firstName"]
        lastName            <- map["lastName"]
        email               <- map["email"]
    }
    
}
