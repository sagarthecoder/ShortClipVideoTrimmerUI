//
//  ShortClipThumbnailsCollectionViewCell.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit

class ShortClipThumbnailsCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
