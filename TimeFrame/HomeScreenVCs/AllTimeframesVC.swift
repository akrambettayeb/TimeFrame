//
//  AllTimeframesVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/23/24.
//

import UIKit

class AllTimeframesCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeframeNameLabel: UILabel!
}


class AllTimeframesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let cellID = "AllTimeframesCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        let collectionWidth = collectionView.bounds.width
        let cellSize = (collectionWidth - 11) / 2
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 20)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTimeframes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AllTimeframesCell
        let timeframeName = timeframeNames[indexPath.row]
        cell.timeframeNameLabel.text = timeframeName
        cell.imageView.image = allTimeframes[timeframeName]![0]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAllTimeframesToOpenVC",
           let nextVC = segue.destination as? OpenTimeframeVC {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                // Passes timeframe name to the next screen to display the specified timeframe
                let index = indexPaths[0].row
                nextVC.timeframeName = timeframeNames[index]
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
}
