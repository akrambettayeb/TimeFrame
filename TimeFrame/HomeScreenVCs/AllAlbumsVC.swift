//
//  AllAlbumsVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//

import UIKit

class AllAlbumsCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var photosCountLabel: UILabel!
}


class AllAlbumsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    let cellID = "AllAlbumsCell"
    
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
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 50)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AllAlbumsCell
        let albumName = albumNames[indexPath.row]
        let photosCount = allAlbums[albumName]!.count
        cell.albumNameLabel.text = albumName
        cell.photosCountLabel.text = "\(photosCount) photos"
        if photosCount == 0 {
            cell.imageView.image = UIImage(systemName: "person.crop.rectangle.stack.fill")
        } else {
            cell.imageView.image = allAlbums[albumName]![0]
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAllAlbumsToAlbumVC",
           let nextVC = segue.destination as? AlbumViewController {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                let index = indexPaths[0].row
                nextVC.albumName = albumNames[index]
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
}
