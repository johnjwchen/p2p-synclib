//
//  PPSyncManger.swift
//  p2p-synclib
//
//  Created by Jiawei Chen on 7/26/18.
//

import UIKit
import MultipeerConnectivity

public class PPSyncManger: NSObject {
    public var receiveHandler: ((Data) -> Void)
    public func broadcast(userData: Data, handler: ((Data, Bool) -> Void)?) {
        _broadcast(userData: userData, handler: handler)
    }
    
    // public static let shared = PPSyncManger()
    
    private let serviceType = "p2p-sync"
    private let myPeerId = MCPeerID(displayName: UUID().uuidString)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    public init(handler: @escaping (Data)->Void) {
        self.receiveHandler = handler
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
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
    private var _session: MCSession?
    var session: MCSession {
        if (_session == nil) {
            _session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            _session?.delegate = self
        }
        return _session!
    }
    
    // changes
    var changes = [Change]()
//    var peerQueues = [String : [Change]]()
}

enum PayloadType: Int, Codable {
    case request
    case response
}

struct Payload: Codable {
    let type:PayloadType
    let changes: [Change]
}

struct Change: Codable, Equatable {
    let userData: Data
    let uuid = NSUUID().UUIDString
    let timeStamp = Date().timeIntervalSince1970
}

extension Payload {
    // max
    func toData() -> Data {
        return try! JSONEncoder().encode(self)
    }
    // max
//    init(from data: Data) {
//    }
}

