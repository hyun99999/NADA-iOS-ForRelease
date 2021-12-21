//
//  GroupViewController.swift
//  NADA-iOS-forRelease
//
//  Created by 민 on 2021/10/08.
//

import Photos
import UIKit
import Kingfisher

class GroupViewController: UIViewController {
    
    // MARK: - Properties
    // 네비게이션 바
    @IBAction func presentToAddWithIdView(_ sender: Any) {
        let nextVC = AddWithIdBottomSheetViewController()
                    .setTitle("ID로 명함 추가")
                    .setHeight(184)
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: false, completion: nil)
    }
    
    @IBAction func presentToAddWithQrView(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            makeOKCancelAlert(title: "카메라 권한이 허용되어 있지 않아요.",
                        message: "QR코드 인식을 위해 카메라 권한이 필요합니다. 앱 설정으로 이동해 허용해 주세요.",
                        okAction: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)},
                        cancelAction: nil,
                        completion: nil)
        case .authorized:
            guard let nextVC = UIStoryboard.init(name: Const.Storyboard.Name.qrScan, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.qrScanViewController) as? QRScanViewController else { return }
            nextVC.modalPresentationStyle = .overFullScreen
            self.present(nextVC, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        guard let nextVC = UIStoryboard.init(name: Const.Storyboard.Name.qrScan, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.qrScanViewController) as? QRScanViewController else { return }
                        nextVC.modalPresentationStyle = .overFullScreen
                        self.present(nextVC, animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }
    }
    
    // 중간 그룹 이름들 나열된 뷰
    @IBAction func pushToGroupEdit(_ sender: Any) {
        guard let nextVC = UIStoryboard.init(name: Const.Storyboard.Name.groupEdit, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.groupEditViewController) as? GroupEditViewController else { return }
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // collectionview
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    // 그룹 이름들을 담을 변수 생성
    var serverGroups: Groups?
    var serverCards: CardsInGroupResponse?
    var serverCardsWithBack: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUI()
        // 그룹 리스트 조회 서버 테스트
        groupListFetchWithAPI(userID: "nada")
//         그룹 삭제 서버 테스트
//        groupDeleteWithAPI(groupID: 1)
//         그룹 추가 서버 테스트
//        groupAddWithAPI(groupRequest: GroupAddRequest(userId: "nada", groupName: "대학교"))
//         그룹 수정 서버 테스트
//        groupEditWithAPI(groupRequest: GroupEditRequest(groupId: 5, groupName: "수정나다"))
//         그룹 속 명함 추가 테스트
//        cardAddInGroupWithAPI(cardRequest: CardAddInGroupRequest(cardId: "cardC", userId: "nada", groupId: 18))
//         그룹 속 명함 조회 테스트
//        cardListInGroupWithAPI(cardListInGroupRequest: CardListInGroupRequest(userId: "nada", groupId: 5, offset: 0))
//         명함 검색 테스트
//        cardDetailFetchWithAPI(cardID: "cardA")
        
    }
    
}

extension GroupViewController {
    private func registerCell() {
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
         
        groupCollectionView.register(GroupCollectionViewCell.nib(), forCellWithReuseIdentifier: Const.Xib.groupCollectionViewCell)
        cardsCollectionView.register(CardInGroupCollectionViewCell.nib(), forCellWithReuseIdentifier: Const.Xib.cardInGroupCollectionViewCell)
    }
    
    private func setUI() {
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Network

extension GroupViewController {
    func groupListFetchWithAPI(userID: String) {
        GroupAPI.shared.groupListFetch(userID: userID) { response in
            switch response {
            case .success(let data):
                if let group = data as? Groups {
                    self.serverGroups = group
                    self.groupCollectionView.reloadData()
                    self.cardListInGroupWithAPI(cardListInGroupRequest: CardListInGroupRequest(userId: "nada", groupId: group.groups[0].groupID, offset: 0))
                }
            case .requestErr(let message):
                print("groupListFetchWithAPI - requestErr: \(message)")
            case .pathErr:
                print("groupListFetchWithAPI - pathErr")
            case .serverErr:
                print("groupListFetchWithAPI - serverErr")
            case .networkFail:
                print("groupListFetchWithAPI - networkFail")
            }
        }
    }
    
    func groupDeleteWithAPI(groupID: Int) {
        GroupAPI.shared.groupDelete(groupID: groupID) { response in
            switch response {
            case .success:
                print("groupDeleteWithAPI - success")
            case .requestErr(let message):
                print("groupDeleteWithAPI - requestErr: \(message)")
            case .pathErr:
                print("groupDeleteWithAPI - pathErr")
            case .serverErr:
                print("groupDeleteWithAPI - serverErr")
            case .networkFail:
                print("groupDeleteWithAPI - networkFail")
            }
        }
    }
    
    func groupAddWithAPI(groupRequest: GroupAddRequest) {
        GroupAPI.shared.groupAdd(groupRequest: groupRequest) { response in
            switch response {
            case .success:
                print("groupAddWithAPI - success")
            case .requestErr(let message):
                print("groupAddWithAPI - requestErr: \(message)")
            case .pathErr:
                print("groupAddWithAPI - pathErr")
            case .serverErr:
                print("groupAddWithAPI - serverErr")
            case .networkFail:
                print("groupAddWithAPI - networkFail")
            }
        }
    }
    
    func groupEditWithAPI(groupRequest: GroupEditRequest) {
        GroupAPI.shared.groupEdit(groupRequest: groupRequest) { response in
            switch response {
            case .success:
                print("groupEditWithAPI - success")
            case .requestErr(let message):
                print("groupEditWithAPI - requestErr: \(message)")
            case .pathErr:
                print("groupEditWithAPI - pathErr")
            case .serverErr:
                print("groupEditWithAPI - serverErr")
            case .networkFail:
                print("groupEditWithAPI - networkFail")
            }
        }
    }
    
    func cardListInGroupWithAPI(cardListInGroupRequest: CardListInGroupRequest) {
        GroupAPI.shared.cardListFetchInGroup(cardListInGroupRequest: cardListInGroupRequest) { response in
            switch response {
            case .success(let data):
                if let cards = data as? CardsInGroupResponse {
                    self.serverCards = cards
                    self.cardsCollectionView.reloadData()
                }
            case .requestErr(let message):
                print("cardListInGroupWithAPI - requestErr: \(message)")
            case .pathErr:
                print("cardListInGroupWithAPI - pathErr")
            case .serverErr:
                print("cardListInGroupWithAPI - serverErr")
            case .networkFail:
                print("cardListInGroupWithAPI - networkFail")
            }
        }
    }
    
    func cardDetailFetchWithAPI(cardID: String) {
        CardAPI.shared.cardDetailFetch(cardID: cardID) { response in
            switch response {
            case .success(let data):
                if let card = data as? Card {
                    self.serverCardsWithBack = card
                }
            case .requestErr(let message):
                print("cardDetailFetchWithAPI - requestErr: \(message)")
            case .pathErr:
                print("cardDetailFetchWithAPI - pathErr")
            case .serverErr:
                print("cardDetailFetchWithAPI - serverErr")
            case .networkFail:
                print("cardDetailFetchWithAPI - networkFail")
            }
        }
    }
    
    func cardAddInGroupWithAPI(cardRequest: CardAddInGroupRequest) {
        GroupAPI.shared.cardAddInGroup(cardRequest: cardRequest) { response in
            switch response {
            case .success:
                print("postCardAddInGroupWithAPI - success")
            case .requestErr(let message):
                print("postCardAddInGroupWithAPI - requestErr", message)
            case .pathErr:
                print("postCardAddInGroupWithAPI - pathErr")
            case .serverErr:
                print("postCardAddInGroupWithAPI - serverErr")
            case .networkFail:
                print("postCardAddInGroupWithAPI - networkFail")
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension GroupViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension GroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case groupCollectionView:
            return serverGroups?.groups.count ?? 0
        case cardsCollectionView:
            return serverCards?.cards.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case groupCollectionView:
            guard let groupCell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.Xib.groupCollectionViewCell, for: indexPath) as? GroupCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            groupCell.groupName.text = serverGroups?.groups[indexPath.row].groupName
            
            if indexPath.row == 0 {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
            }
            return groupCell
        case cardsCollectionView:
            guard let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.Xib.cardInGroupCollectionViewCell, for: indexPath) as? CardInGroupCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cardCell.backgroundImageView.updateServerImage(serverCards?.cards[indexPath.row].background ?? "")
            cardCell.cardId = serverCards?.cards[indexPath.row].cardID 
            cardCell.titleLabel.text = serverCards?.cards[indexPath.row].title
            cardCell.descriptionLabel.text = serverCards?.cards[indexPath.row].cardDescription
            cardCell.userNameLabel.text = serverCards?.cards[indexPath.row].name
            cardCell.birthLabel.text = serverCards?.cards[indexPath.row].birthDate
            cardCell.mbtiLabel.text = serverCards?.cards[indexPath.row].mbti
            cardCell.instagramIDLabel.text = serverCards?.cards[indexPath.row].instagram
            cardCell.lineURLLabel.text = serverCards?.cards[indexPath.row].link
            
            return cardCell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case groupCollectionView:
            cardListInGroupWithAPI(cardListInGroupRequest: CardListInGroupRequest(userId: "nada", groupId: serverGroups?.groups[indexPath.row].groupID ?? 0, offset: 0))
        case cardsCollectionView:
//            cardDetailFetchWithAPI(cardID: serverCards?.cards[indexPath.row].cardID ?? "")
            guard let nextVC = UIStoryboard.init(name: Const.Storyboard.Name.cardDetail, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.cardDetailViewController) as? CardDetailViewController else { return }

//            nextVC.cardDataModel = Card(cardID: serverCards?.cards[indexPath.row].cardID ?? "" ,
//                                        background: <#T##String#>,
//                                        title: serverCards?.cards[indexPath.row].title ?? "",
//                                        name: serverCards?.cards[indexPath.row].name ?? "",
//                                        birthDate: serverCards?.cards[indexPath.row].birthDate ?? "",
//                                        mbti: serverCards?.cards[indexPath.row].mbti ?? "",
//                                        instagram: serverCards?.cards[indexPath.row].instagram ?? "",
//                                        link: serverCards?.cards[indexPath.row].link ?? "",
//                                        cardDescription: serverCards?.cards[indexPath.row].cardDescription ?? "",
//                                        isMincho: serverCards?.cards[indexPath.row].,
//                                        isSoju: <#T##Bool#>, isBoomuk: <#T##Bool#>, isSauced: <#T##Bool#>,
//                                        oneTMI: <#T##String?#>, twoTMI: <#T##String?#>, thirdTMI: <#T##String?#>)
            navigationController?.pushViewController(nextVC, animated: true)
        default:
            print(indexPath.row)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat
        var height: CGFloat
        
        switch collectionView {
        case groupCollectionView:
            if serverGroups?.groups[indexPath.row].groupName.count ?? 0 > 4 {
                width = CGFloat(serverGroups?.groups[indexPath.row].groupName.count ?? 0) * 16
            } else {
                width = 62
            }
            height = collectionView.frame.size.height
        case cardsCollectionView:
            width = collectionView.frame.size.width/2 - collectionView.frame.size.width * 8/327
            height = collectionView.frame.size.height * 258/558
        default:
            width = 0
            height = 0
        }
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case groupCollectionView:
            return .init(top: 0, left: 0, bottom: 0, right: 10)
        case cardsCollectionView:
            return .init(top: 0, left: 0, bottom: 28, right: 0)
        default:
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case cardsCollectionView:
            return collectionView.frame.size.width * 15/327
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case groupCollectionView:
            return 5
        case cardsCollectionView:
            return collectionView.frame.size.width * 15/327
        default:
            return 0
        }
    }
}
