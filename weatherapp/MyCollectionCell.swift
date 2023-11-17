//
//  MyCollectionCell.swift
//  weatherapp
//
//  Created by Chiree Sherpa on 2023-11-16.
//

import UIKit

class MyCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var labelProperty: UILabel!
    
    @IBOutlet weak var labelValue: UILabel!
    
    
    override func layoutSubviews() {
       super.layoutSubviews()
       // Set corner radius and border for the cell
       layer.cornerRadius = 10 // Adjust the value to your desired corner radius
       layer.borderWidth = 1 // Adjust the border width if needed
       layer.borderColor = UIColor.lightGray.cgColor // Set the border color
       layer.masksToBounds = true // Clip subviews to the rounded corners
   }
    
}
