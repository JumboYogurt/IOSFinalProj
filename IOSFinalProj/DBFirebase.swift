//
//  DBFirebase.swift
//  MasterDetail
//
//  Created by mac022 on 2024/06/13.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class DbFirebase: Database{
    
    var reference: CollectionReference = Firestore.firestore().collection("cities")
    
    var parentNotification: (([String: Any]?, DbAction?) -> Void)? // PlanGroup에서 설정
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: (([String: Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
    }
    func setQuery(from: Any, to: Any) {
        if let query = existQuery{
            query.remove()
        }
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 10000)
        existQuery = query.addSnapshotListener(onChangingData)
    }
    func saveChange(key:String, object: [String: Any], action: DbAction){
        if action == .delete {
            reference.document(key).delete()
            return
        }
        reference.document(key).setData(object)
    }
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?){
        guard let querySnapshot = querySnapshot else {return}
        
        if(querySnapshot.documentChanges.count == 0){
            return
        }
        for documentChange in querySnapshot.documentChanges{
            let dict = documentChange.document.data()
            var action: DbAction?
            switch(documentChange.type){
            case .added: action = .add
            case.modified: action = .modify
            case .removed: action = .delete
            }
            if let parentNotification = parentNotification{parentNotification(dict, action)}
        }
    }
    
    func uploadImage(imageName: String, image: UIImage){
    // uiimage를 jpeg 파일에 맞게 변형, png도 가능
    guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
    // 파이어베이스내에 스토리지의 레퍼런스를 만든다.
    let reference = Storage.storage().reference().child("cities").child(imageName)
    let metaData = StorageMetadata() // 보내고자 하는 데이터에 대한 메타정보
        metaData.contentType = "image/jpeg" // 이것은 jpeg 데이터임을 표시
    // 여기서 업로드하여 저장한다
    reference.putData(imageData, metadata: metaData, completion: nil /* 할일이 없음*/)
    }
    func downloadImage(imageName: String, completion: @escaping (UIImage?) -> Void) { // completion 함수는 이미지 로딩이 다 이루어지면 알려 달라는 함수
        let reference = Storage.storage().reference().child("cities").child(imageName)
        let megaByte = Int64(10 * 1024 * 1024) // 충분히 크야한다.
        reference.getData(maxSize: megaByte) { data, error in
            // 스레드에 의하여 실행된다.
            completion( data != nil ? UIImage(data: data!): nil)
        }
    }
}
