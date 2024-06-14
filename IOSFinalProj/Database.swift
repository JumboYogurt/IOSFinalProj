//
//  Database.swift
//  MasterDetail
//
//  Created by mac022 on 2024/06/13.
//

import Foundation


enum DbAction{
    case add, delete, modify
}

protocol Database{
    // 생성자, 데이터베이스에 변경이 생기면 parentNotification를 호출하여 부모에게 알림
    init(parentNotification: (([String: Any]?, DbAction?) -> Void)? )
    // from ~ toD 사이의 데이터을 읽어 parentNotification를 호출하여 부모에게 알림
    func setQuery(from: Any, to: Any)
    // 데이터베이스에 plan을 변경하고 parentNotification를 호출하여 부모에게 알림
    func saveChange(key: String, object: [String: Any], action: DbAction)
}
