//
//  PhotoGridCollectionViewCell.swift
//  NameIt
//
//  Created by Ranosys on 05/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class PhotoGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var selectUnselectImageView: UIImageView!
    @IBOutlet var cameraRollImageView: UIImageView!
    @IBOutlet var photoName: UILabel!
    @IBOutlet var renameTextField: UITextField!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var editIcon: UIImageView!
}
