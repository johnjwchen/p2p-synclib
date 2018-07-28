//
//  ColoredItemCell.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/27/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

class ColoredItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    var coloredItem:ColoredItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadWith(_ coloredItem: ColoredItem) {
        self.coloredItem = coloredItem
        contentView.backgroundColor = coloredItem.color ?? .clear
        nameLabel.text = coloredItem.name
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        guard let context = coloredItem?.managedObjectContext else { return }
        
        let color = ColoredItem.possibleColors[Int(arc4random_uniform(UInt32(ColoredItem.possibleColors.count)))]
        coloredItem?.color = color
        coloredItem?.name = (coloredItem?.name)! + "-"

        try? context.save()

    }
    
}
