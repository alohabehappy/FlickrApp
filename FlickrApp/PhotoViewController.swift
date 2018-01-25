//
//  PhotoViewController.swift
//  FlickrApp
//
//  Created by Vadim on 25/01/2018.
//  Copyright © 2018 Vadim. All rights reserved.
//

import UIKit
import Kingfisher

final class PhotoViewController: UIViewController {
    var photo: Photo?
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photo = photo, let url = URL(string: photo.bigImageURL) {
            photoImageView.kf.setImage(with: url)
        }
    }
}
