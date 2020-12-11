//
//  Utils.swift
//  Scanner App
//
//  Created by Gia Huy on 01/12/2020.
//

import UIKit
import Foundation

class Utils: NSObject {
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$")
        return passwordTest.evaluate(with: password)
    }
}
