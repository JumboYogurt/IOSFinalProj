//
//  CreateAcountViewController.swift
//  IOSFinalProj
//
//  Created by  한성 on 6/18/24.
//

import UIKit
import FirebaseAuth

class CreateAcountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var isCreateEnabled: Bool = false // Segue 수행 여부를 결정하는 변수
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        let passwordLength = emailTextField.text?.count ?? 0
        
        if passwordLength<=5{
            isCreateEnabled = true
        }
        Auth.auth().createUser(withEmail: email, password: password){authResult, error in
            if let e = error{
                print("Create error")
                self.isCreateEnabled = true
            }else{
                //Go to our home screen
                print("true")
                self.isCreateEnabled = true
                self.shouldPerformSegue(withIdentifier: "goToHome", sender: self)
            }
        }
        
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToHome" {
            // 조건을 체크합니다. 예를 들어, 텍스트 필드가 비어 있는지 확인합니다.
            if isCreateEnabled == true {
                return true // 조건을 만족하면 segue를 수행합니다.
            } else {
                // 조건을 만족하지 않으면 사용자에게 알림을 표시하거나 다른 처리를 합니다.
                let alert = UIAlertController(title: "Error", message: "비밀번호는 6자리 이상 입력해주세요", preferredStyle: .alert)
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
