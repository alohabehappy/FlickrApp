//
//  MainViewController.swift
//  FlickrApp
//
//  Created by Vadim on 25/01/2018.
//  Copyright © 2018 Vadim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

final class MainViewController: UIViewController {
    var photos: [Photo] = []
    var layoutType: LayoutType = .grid
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getFlickrPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoViewController = segue.destination as? PhotoViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
            photoViewController.photo = photos[indexPath.row]
        }
    }
    
    @IBAction func segmentedControlDidChanged(_ control: UISegmentedControl) {
        guard let layoutType = LayoutType(rawValue: control.selectedSegmentIndex) else { return }
        
        self.layoutType = layoutType
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photos[indexPath.row]
        cell.imageURL = layoutType == .grid ? photo.smallImageURL : photo.bigImageURL
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchHeader", for: indexPath)
        }
        return reusableView
    }
}

// MARK: - UICollectionViewFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    enum LayoutType: Int {
        case grid
        case list
    }
    
    struct Constants {
        static let numberOfColumns: CGFloat = 3
        static let listRowHeight: CGFloat = 200
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if layoutType == .grid {
            let itemWidth = collectionView.bounds.width / Constants.numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return CGSize(width: collectionView.bounds.width, height: Constants.listRowHeight)
        }
    }
}

// MARK: - UISearchBar
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getFlickrPhotos(searchText: searchBar.text)
    }
}

// MARK: - Networking
extension MainViewController {
    func getFlickrPhotos(searchText: String? = nil) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        fetchFlickrPhotos(searchText: searchText) { [weak self] photos in
            guard let selfie = self else { return }
            MBProgressHUD.hide(for: selfie.view, animated: true)
            
            if let photos = photos {
                selfie.photos = photos
                selfie.collectionView.reloadData()
            }
        }
    }
    
    func fetchFlickrPhotos(searchText: String? = nil, completion: (([Photo]?) -> Void)? = nil) {
        let url = URL(string: "https://api.flickr.com/services/rest/")!
        var parameters = [
            "method" : "flickr.interestingness.getList",
            "api_key" : "86997f23273f5a518b027e2c8c019b0f",
            "sort": "relevance",
            "per_page" : "20",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras": "url_q,url_z"
            ]
        
        if let searchText = searchText {
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = searchText
        }
        
        Alamofire.request(url, method: .get, parameters: parameters)
            .validate()
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success:
                    guard let data = response.data, let json = try? JSON(data: data) else {
                        print("Error while parsing Flickr response")
                        completion?(nil)
                        return
                    }
                    
                    let photosJSON = json["photos"]["photo"]
                    let photos = photosJSON.arrayValue.flatMap { Photo(json: $0) }
                    completion?(photos)
                    
                case .failure(let error):
                    print("Error while fetching photos: \(error.localizedDescription)")
                    completion?(nil)
                }
        }
    }
}
