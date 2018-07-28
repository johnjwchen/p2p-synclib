//
//  QuickVC.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/27/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

class QuickVC: UIViewController {
    @IBAction func reset(_ sender: Any) {
        CoreDataStack.clearStore()
    }
    
}
