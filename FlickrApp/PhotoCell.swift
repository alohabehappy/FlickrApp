//
//  PhotoCell.swift
//  FlickrApp
//
//  Created by Vadim on 25/01/2018.
//  Copyright © 2018 Vadim. All rights reserved.
//

import UIKit
import Kingfisher

final class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                photoImageView.kf.setImage(with: url)
            } else {
                photoImageView.image = nil
                photoImageView.kf.cancelDownloadTask()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
    }
}
