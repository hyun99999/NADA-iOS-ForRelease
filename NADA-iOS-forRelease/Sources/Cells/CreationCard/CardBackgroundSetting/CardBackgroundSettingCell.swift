//
//  CardBackgroundSettingCell.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2021/09/26.
//

import UIKit

class CardBackgroundSettingCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "CardBackgroundSettingCell"
    
    // MARK: - @IBOutlet Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Cell Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

}

// MARK: - Extensions

extension CardBackgroundSettingCell {
    private func setUI() {
        bgView.backgroundColor = .black
        bgView.layer.cornerRadius = bgView.frame.height / 2
//        bgView.layer.cornerRadius = 10
        imageView.layer.cornerRadius = imageView.frame.height / 2
//        imageView.layer.cornerRadius = 10
    }
    func initCell(image: String) {
        if let image = UIImage(named: image) {
            imageView.image = image
        }
    }
}
