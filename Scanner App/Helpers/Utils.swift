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
        return (password.count<8) ? false : true
    }
}
