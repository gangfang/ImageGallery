//
//  SingleImageViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/26.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit
// make scroll view
class SingleImageViewController: UIViewController {

    var imageHolderForSegue: UIImage?
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = imageHolderForSegue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
