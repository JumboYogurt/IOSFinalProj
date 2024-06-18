/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A representation of a single landmark.
*/

import Foundation
import SwiftUI
import CoreLocation

struct Logiin: Hashable, Codable, Identifiable {
    var id: Int
    var lginID: String
    var password: String
    
    init(id:Int, lginID: String, password: String) {
        self.lginID = lginID
        self.password = password
    }
}

extension Logiin{
    static func toDict(logiin: Logiin) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = city.id
        dict["name"] = city.name
        dict["country"] = city.country
        dict["tel"] = city.tel
        dict["fax"] = city.fax
        dict["email"] = city.email
        dict["description"] = city.description
        dict["imageName"] = city.imageName

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> City{
        
        let id = dict["id"] as! Int
        let name = dict["name"] as! String
        let country = dict["country"] as! String
        let tel = dict["tel"] as! String
        let fax = dict["fax"] as! String
        let email = dict["email"] as! String
        let description = dict["description"] as! String
        let imageName = dict["imageName"] as! String
        
        return City(id: id, name: name, country: country, tel: tel, fax: fax, email: email, description: description, imageName: imageName)
    }
}

