//
//  PPSyncManger.swift
//  p2p-synclib
//
//  Created by Jiawei Chen on 7/26/18.
//

import UIKit



public class PPSyncManger: NSObject {
    public static var receiveHandler: (Data) -> Void
    public static func send(change: Data, handler: ((Data, Bool) -> Void)?) {
        
    }
    
}
