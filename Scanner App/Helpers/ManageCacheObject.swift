//
//  ManageCacheObject.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class ManageCacheObject: NSObject {
    
    // MARK: - setFirstRun
    static func setFirstRun(_ firt_run:Bool){
        UserDefaults.standard.set(firt_run, forKey:KEY_FIRST_RUN)
    }
    
    static func getFirstRun()->Bool{
        if let first_run : Bool = UserDefaults.standard.object(forKey: KEY_FIRST_RUN) as? Bool{
            return first_run
        }else{
            return false
        }
    }
    
    // MARK: - setTabIndex
    static func setTabIndex(_ tabIndex:Int){
        UserDefaults.standard.set(tabIndex, forKey:KEY_TAB_INDEX)
    }
    
    static func getCurrentTabIndex()->Int{
        if let tabIndex : Int = UserDefaults.standard.object(forKey: KEY_TAB_INDEX) as? Int{
            return tabIndex
        }else{
            return 0
        }
    }
    
    static func clearData() {
        UserDefaults.standard.set(nil, forKey:KEY_ACCOUNT)
    }
        
    static func saveCurrentAccount(_ account : Account){
        UserDefaults.standard.set(Mapper<Account>().toJSON(account), forKey:KEY_ACCOUNT)
    }
    
    static func getCurrentAccount() -> Account{
        if let userJson = UserDefaults.standard.object(forKey: KEY_ACCOUNT){
            let user : Account = Mapper<Account>().map(JSONObject: userJson)!
            return user
        }else
        {
            let account = Account()
            return account
        }
    }
    
    static func isLogin()->Bool{
        let account = ManageCacheObject.getCurrentAccount()
        if(account.email == ""){
            return false
        }
        return true
    }
    static func clearUser(){
        UserDefaults.standard.set(nil, forKey: KEY_ACCOUNT)
    }

}
