//
//  GalleriesTableViewCell.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/30.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit

class GalleriesTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    var resignationHandler: (() -> Void)?
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
}
