//
//  SingleImageViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/26.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit

class SingleImageViewController: UIViewController, UIScrollViewDelegate {

    var imageHolderForSegue: UIImage?
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = imageHolderForSegue
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }
}
