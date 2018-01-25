//
//  Photo.swift
//  FlickrApp
//
//  Created by Vadim on 25/01/2018.
//  Copyright © 2018 Vadim. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Photo {
    var bigImageURL: String
    var smallImageURL: String
    
    init?(json: JSON) {
        guard let urlQ = json["url_q"].string,
            let urlZ = json["url_z"].string else {
                return nil
        }
        
        self.bigImageURL = urlZ
        self.smallImageURL = urlQ
    }
}
