//
//  PPSyncManger.swift
//  p2p-synclib
//
//  Created by Jiawei Chen on 7/26/18.
//

import UIKit



public class PPSyncManger: NSObject {
    public var receiveHandler: (Data) -> Void
    public func send(userData: Data, handler: ((Data, Bool) -> Void)?) {
        
    }
    
    // public static let shared = PPSyncManger()
    
    private let serviceType = "p2p-sync"
    private let myPeerId = MCPeerID(displayName: UUID().uuidString)
    private let serviceAdvertiser : MCNearbyServiceAdvertise
    private let serviceBrowser : MCNearbyServiceBrowser
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    //
    private var _session: MCSession = nil
    var session: MCSession {
        if (_session == nil) {
            _session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session.delegate = self
        }
        return _session
    }
    
    // changes
    var changes = [Change]()
    var peeQueues = [String:[Change]]()
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

