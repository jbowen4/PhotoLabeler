//
//  GroupViewCell.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/5/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class GroupViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectIndicator: UIImageView!
    @IBOutlet weak var highlightIndicator: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            highlightIndicator.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highlightIndicator.isHidden = !isSelected
            selectIndicator.isHidden = !isSelected
        }
    }
}
