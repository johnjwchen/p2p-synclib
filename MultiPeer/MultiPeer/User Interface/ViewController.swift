//
//  ViewController.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/25/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit
import p2p_synclib
import CoreData

enum MessageDirection {
    case inbound
    case outbound
}

struct Message {
    var body:String
    var direction:MessageDirection
}


class ViewController: UIViewController {
    
    var syncManager:PPSyncManger!
    let context = CoreDataStack.newChildContext(withName: "tableview_controller")
    
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ColoredItem> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<ColoredItem> = ColoredItem.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataStack.addChangeListener(forListener: self) { (changes) in
            print("ViewController is listening")
        }
        try? self.fetchedResultsController.performFetch()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ColoredItemCell", bundle: nil), forCellReuseIdentifier: "ColoredItemCell")
    }
}






extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let indexToInsert = newIndexPath else { return }
            tableView.insertRows(at: [indexToInsert], with: .automatic)
        case .delete:
            guard let indexToDelete = indexPath else { return }
            tableView.deleteRows(at: [indexToDelete], with: .automatic)
        case .move:
            guard let indexToMoveFrom = indexPath, let indexToMoveTo = newIndexPath else { return }
            tableView.moveRow(at: indexToMoveFrom, to: indexToMoveTo)
        case .update:
            guard let indexToUpdate = indexPath else { return }
            tableView.reloadRows(at: [indexToUpdate], with: .automatic)
        }
    }
}







extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let coloredItems = fetchedResultsController.fetchedObjects else { return 0 }
        return coloredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coloredItem = fetchedResultsController.object(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColoredItemCell", for: indexPath) as? ColoredItemCell else {
            return UITableViewCell()
        }
        cell.loadWith(coloredItem)
        return cell
    }
    
}
