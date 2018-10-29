//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/29.
//  Copyright © 2018 gfang. All rights reserved.
//

import Foundation

class ImageGallery {
    var name: String
    var images: [[String : Any]]

    init(name: String, images: [[String : Any]]) {
        self.name = name
        self.images = images
    }
}
