//
//  PPSyncManger.swift
//  p2p-synclib
//
//  Created by Jiawei Chen on 7/26/18.
//

import UIKit



public class PPSyncManger: NSObject {
    public static var receiveHandler: (Data) -> Void
    public static func send(userData: Data, handler: ((Data, Bool) -> Void)?) {
        
    }
    
}

struct Change {
    let userData: Data
    let uuid = NSUUID().UUIDString
    let timeStamp = Date().timeIntervalSince1970
}

extension Change {
    // max
    func toData() -> Data {
    }
    // max
    init(from data: Data) {
    }
}



extension PPSyncManger {
    func _send(userData: Data, handler: ((Data, Bool) -> Void)?) {
        if let change = Change(userData: userData) as? Data {
            // send the change as Data
        }
    }
}
