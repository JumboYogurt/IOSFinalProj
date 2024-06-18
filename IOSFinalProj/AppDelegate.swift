//
//  AppDelegate.swift
//  MasterDetail
//
//  Created by mac022 on 2024/05/23.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 2.0)
        FirebaseApp.configure()
        Firestore.firestore().collection("test").document("name").setData(["name":"YeEun Lee"])
        Firestore.firestore().collection("test").document("tel").setData(["tel":"02-0000-0000"])
        Firestore.firestore().collection("test").document("fax").setData(["fax":"02-0000-0000"])
        Firestore.firestore().collection("test").document("email").setData(["email":"hansung@hansung.com"])
        
        let image = UIImage(named: "Seoul")
        let imageData = image?.jpegData(compressionQuality: 1.0)
        let reference = Storage.storage().reference().child("test").child("Seoul")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        reference.putData(imageData!,metadata: metaData){_ in}
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

