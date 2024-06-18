//
//  LoginViewController.swift
//  IOSFinalProj
//
//  Created by  한성 on 6/18/24.
//

import UIKit
import Firebase
//import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var isSegueEnabled: Bool = false // Segue 수행 여부를 결정하는 변수
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            print("Email is empty")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            print("Password is empty")
            return
        }
                
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                print("Error: \(e.localizedDescription)")
                self.isSegueEnabled = false
            } else {
                self.isSegueEnabled = true
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToHome" {
            // 조건을 체크합니다. 예를 들어, 텍스트 필드가 비어 있는지 확인합니다.
            if isSegueEnabled == true {
                return true // 조건을 만족하면 segue를 수행합니다.
            }else{
                // 조건을 만족하지 않으면 사용자에게 알림을 표시하거나 다른 처리를 합니다.
                let alert = UIAlertController(title: "Error", message: "계정을 생성해 주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return false // 조건을 만족하지 않으면 segue를 수행하지 않습니다.
            }
        }
        return true // 기본적으로 다른 모든 segue는 수행합니다.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
