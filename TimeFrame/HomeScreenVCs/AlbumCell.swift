//
//  AlbumCell.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/6/24.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBAction func onSelectTapped(_ sender: Any) {
        selectButton.isSelected = !selectButton.isSelected
        if selectButton.isSelected {
            selectButton.imageView?.image = UIImage(systemName: "circle.inset.filled")
        } else {
            selectButton.imageView?.image = UIImage(systemName: "circle")
        }
    }
    
    // TODO: hide button if not creating timeframe
}
