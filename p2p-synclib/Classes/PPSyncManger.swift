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
    
    public static let shared = PPSyncManger()
    
    private let serviceType = "p2p-sync"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
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
    fileprivate var session: MCSession {
        if (_session == nil) {
            _session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session.delegate = self
        }
        return _session
    }
}

extension MultiPeerService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        debugPrint("peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        debugPrint("didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.didReceiveMessage(manager: self, message: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        debugPrint("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        debugPrint("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        debugPrint("didFinishReceivingResourceWithName")
    }
    
}

extension MultiPeerService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        debugPrint("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        debugPrint("foundPeer: \(peerID)")
        debugPrint("invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        debugPrint("lostPeer: \(peerID)")
    }
    
}

extension PPSyncManger : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
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
        let change = Change(userData: userData)
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(change.toData(), toPeers: session.connectedPeers, with: .reliable)
                handler(userData, true)
            }
            catch let error {
                handler(userData, false)
            }
        }
    }
}
