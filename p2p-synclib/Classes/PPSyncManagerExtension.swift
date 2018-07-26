//
//  PPSyncManagerExtension.swift
//  Pods
//
//  Created by Jiawei Chen on 7/26/18.
//

import Foundation
import MultipeerConnectivity

extension PPSyncManger {
    
    
    func _broadcast(userData: Data, handler: ((Data, Bool) -> Void)?) {
        let change = Change(userData: userData)
        let payload = Payload(type: .response, changes: [change])
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(payload.toData(), toPeers: session.connectedPeers, with: .reliable)
                handler?(userData, true)
            }
            catch let error {
                // to da
                handler?(userData, false)
            }
        }
    }
}

extension PPSyncManger : MCSessionDelegate {
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        debugPrint("peer \(peerID) didChangeState: \(state.rawValue)")
        if state == .connected {
            let payloadToSend = Payload(type: .request, changes: changes.last == nil ? [] : [changes.last!])
            try? self.session.send(payloadToSend.toData(), toPeers: [peerID], with: .reliable)
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        debugPrint("didReceiveData: \(data)")
        //
        let payload = try! JSONDecoder().decode(Payload.self, from: data)
        switch payload.type {
        
        case .request:
            print("Send back sel.log - payload.log")
            let wantedChanges:[Change]
            if let first = payload.changes.first {
                if let index = changes.index(of: first) {
                wantedChanges = Array(changes[index..<changes.count])
                } else {
                    break
                }
            } else {
                wantedChanges = changes
            }
            let payloadToSend = Payload(type: .response, changes: wantedChanges)
            try? self.session.send(payloadToSend.toData(), toPeers: [peerID], with: .reliable)
            
        case .response:
            print("CoreData check and update")
            let neededChanges = payload.changes.filter { (change) -> Bool in
                return !self.changes.contains(change)
            }
            changes = changes + neededChanges
            
            for change in neededChanges {
                self.receiveHandler(change.userData)
            }
        }
        
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        debugPrint("didReceiveStream")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        debugPrint("didStartReceivingResourceWithName")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        debugPrint("didFinishReceivingResourceWithName")
    }
    
}

extension PPSyncManger : MCNearbyServiceBrowserDelegate {
    
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        debugPrint("didNotStartBrowsingForPeers: \(error)")
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        debugPrint("foundPeer: \(peerID)")
        debugPrint("invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        debugPrint("lostPeer: \(peerID)")
    }
    
}

extension PPSyncManger : MCNearbyServiceAdvertiserDelegate {
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}
