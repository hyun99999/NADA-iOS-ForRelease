//
//  MainCardCell.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2021/12/10.
//

import UIKit
import VerticalCardSwiper
import KakaoSDKCommon

class MainCardCell: CardCell {

    // MARK: - Properties
    
    private var isFront = true
    
    public var cardDataModel: Card?
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setGestureRecognizer()
    }
    
    // MARK: - Methods
    
    static func nib() -> UINib {
        return UINib(nibName: Const.Xib.mainCardCell, bundle: Bundle(for: MainCardCell.self))
    }
}

// MARK: - Extensions

extension MainCardCell {
    public func setFrontCard() {
        guard let frontCard = FrontCardCell.nib().instantiate(withOwner: self, options: nil).first as? FrontCardCell else { return }
        
        frontCard.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        guard let cardDataModel = cardDataModel else { return }
        frontCard.initCell(cardDataModel.background,
                           cardDataModel.title,
                           cardDataModel.cardDescription ?? "",
                           cardDataModel.name,
                           cardDataModel.birthDate,
                           cardDataModel.mbti,
                           cardDataModel.instagram ?? "",
                           cardDataModel.link ?? "")
        
        contentView.addSubview(frontCard)
    }
    private func setGestureRecognizer() {
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(transitionCardWithAnimation(_:)))
        swipeLeftGestureRecognizer.direction = .left
        self.contentView.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(transitionCardWithAnimation(_:)))
        swipeRightGestureRecognizer.direction = .right
        self.contentView.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    public func initCell(cardDataModel: Card) {
        self.cardDataModel = cardDataModel
    }
    // MARK: - @objc Methods
    
    @objc
    private func transitionCardWithAnimation(_ swipeGesture: UISwipeGestureRecognizer) {
        if isFront {
            guard let backCard = BackCardCell.nib().instantiate(withOwner: self, options: nil).first as? BackCardCell else { return }
            backCard.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
            guard let cardDataModel = cardDataModel else { return }
            backCard.initCell(cardDataModel.background,
                              cardDataModel.isMincho,
                              cardDataModel.isSoju,
                              cardDataModel.isBoomuk,
                              cardDataModel.isSauced,
                              cardDataModel.oneTMI ?? "",
                              cardDataModel.twoTMI ?? "",
                              cardDataModel.thirdTMI ?? "")
            
            contentView.addSubview(backCard)
            isFront = false
        } else {
            guard let frontCard = FrontCardCell.nib().instantiate(withOwner: self, options: nil).first as? FrontCardCell else { return }
            
            frontCard.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
            guard let cardDataModel = cardDataModel else { return }
            frontCard.initCell(cardDataModel.background,
                               cardDataModel.title,
                               cardDataModel.cardDescription ?? "",
                               cardDataModel.name,
                               cardDataModel.birthDate,
                               cardDataModel.mbti,
                               cardDataModel.instagram ?? "",
                               cardDataModel.link ?? "")
            
            contentView.addSubview(frontCard)
            isFront = true
        }
        if swipeGesture.direction == .right {
            UIView.transition(with: contentView, duration: 0.5, options: .transitionFlipFromLeft, animations: nil) { _ in
                self.contentView.subviews[0].removeFromSuperview()
            }
        } else {
            UIView.transition(with: contentView, duration: 0.5, options: .transitionFlipFromRight, animations: nil) { _ in
                self.contentView.subviews[0].removeFromSuperview()
            }
        }
    }
}
