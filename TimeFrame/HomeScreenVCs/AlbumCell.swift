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
        // TODO: include picture in the generated TimeFrame
    }
    
    // TODO: hide button if not creating timeframe
}
