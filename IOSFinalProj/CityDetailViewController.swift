//
//  ViewController.swift
//  MasterDetail
//
//  Created by mac022 on 2024/05/23.
//

import UIKit

class CityDetailViewController: UIViewController {
    @IBOutlet weak var cityImageView: UIImageView! //이미지뷰
    @IBOutlet weak var cityNameTextField: UITextField! //텍스트필드

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var countryPickerView: UIPickerView! //피커뷰
    @IBOutlet weak var descriptionTextView: UITextView! //텍스트뷰
    
    @IBOutlet weak var personTel: UITextField! //전화번호
    @IBOutlet weak var personFax: UITextField! //팩스번호
    @IBOutlet weak var personEmail: UITextField! //이메일번호
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    @objc func startEditing(sender: UITextField){
        stackViewTopConstraint.constant -= 250
        stackViewBottomConstraint.constant -= 250
    }
    @objc func endEditing(sender: UITextField){
        // 키보드가 없어지므로 전체화면(StackView)을 위로 250만큼 아래로 이동
        stackViewTopConstraint.constant += 250
        stackViewBottomConstraint.constant += 250
    }
    
    var countries = ["행정사무실", "컴퓨터공학부실습실", "상상력인재학부", "컴퓨터공학사무실", "웹공학트랙행정사무실", "디지털컨텐츠트랙 행정사무실", "모바일트랙행정사무실", "모바일트랙행정사무실", "창의융합지원센터", "IPP사업단"]
    
    var cityMasterViewController: CityMasterViewController!
    //var cities:[City]!
    var selectedCity:Int?
    //var imagePool:[String:UIImage]!
    
    func initCity(city:City){
        cityImageView.image = cityMasterViewController.imagePool[city.imageName] ?? city.uiImage()
        
        // imagePool에도 없고 cityData에도 없는 경우 파이어 스토리지에서 읽어온다
        if cityImageView.image == nil{
            cityMasterViewController.dbFirebase?.downloadImage(imageName: city.imageName, completion: {image in self.cityImageView.image = image})
        }
        
        for i in 0..<countries.count{
            if city.country == countries[i]{
                countryPickerView.selectRow(i, inComponent: 0,animated: true)
                break
            }
        }
        cityNameTextField.text = city.name
        personTel.text = city.tel
        personFax.text = city.fax
        personEmail.text = city.email
        descriptionTextView.text = city.description
    }
    
    @IBAction func savingCity(_ sender: UIButton) {
        guard let name = cityNameTextField.text,name.isEmpty == false else{return}
            let image = cityImageView.image
            let country = countries[countryPickerView.selectedRow(inComponent: 0)]
            guard let tel = personTel.text,tel.isEmpty == false else{return}
            guard let fax = personFax.text,fax.isEmpty == false else{return}
            guard let email = personEmail.text,email.isEmpty == false else{return}
            let description = descriptionTextView.text
            
        var id = cityMasterViewController.cities.count+1000
            var imageName = name
            if let selectedCity = selectedCity{
                id = cityMasterViewController.cities[selectedCity].id
                imageName = cityMasterViewController.cities[selectedCity].imageName
            }
        
        let city = City(id:id, name: name, country: country,tel: tel, fax: fax,email: email, description: description!, imageName: imageName)
        
        /*if let selectedCity = selectedCity{
            cityMasterViewController.cities[selectedCity]=city
        }else{
            cityMasterViewController.cities.append(city)
        }*/
        if let selectedCity = selectedCity{
            if id<1011{
                cityMasterViewController.cities[selectedCity]=city
            }else{
                let dict = City.toDict(city: city)
                cityMasterViewController.dbFirebase?.saveChange(key: String(id), object: dict, action: .modify)
            }
        }else{
            cityMasterViewController.dbFirebase?.saveChange(key: String(id), object: City.toDict(city: city), action: .add)
        }
        
        if let image = image{
            cityMasterViewController.dbFirebase?.uploadImage(imageName: city.imageName, image: image)
        }
        
        //cityMasterViewController.imagePool[imageName] = image
        
        cityImageView.image = nil; cityNameTextField.text=""; personTel.text=""; personFax.text="";
        personEmail.text=""; selectedCity=nil
        let alert = UIAlertController(title: "Saving Success", message: "저장되었습니다", preferredStyle: .alert)
        //alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in}))
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        if let selectedCity = selectedCity{
            initCity(city: cityMasterViewController.cities[selectedCity])
        }
        initCountryPickerView()
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(capturePicture))
        cityImageView.addGestureRecognizer(imageTapGesture)
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
        
        
        cityNameTextField.addTarget(self, action: #selector(startEditing),for:.editingDidBegin)
        cityNameTextField.addTarget(self, action: #selector(endEditing), for:.editingDidEnd)
        personTel.addTarget(self, action: #selector(startEditing),for:.editingDidBegin)
        personTel.addTarget(self, action: #selector(endEditing), for:.editingDidEnd)
        personFax.addTarget(self, action: #selector(startEditing),for:.editingDidBegin)
        personFax.addTarget(self, action: #selector(endEditing), for:.editingDidEnd)
        personEmail.addTarget(self, action: #selector(startEditing),for:.editingDidBegin)
        personEmail.addTarget(self, action: #selector(endEditing), for:.editingDidEnd)
        }
    
    @objc func capturePicture(sender: UITapGestureRecognizer){
        // 사진찍는 별도의 UIViewController가 UIImagePickerController이다.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이를 설정하면 사진을 찍은후 호출된다
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // 카메라가 있다면 카메라로부터
            imagePickerController.sourceType = .camera
        }else{
            // 카메라가 없으면 앨범으로부터
            imagePickerController.sourceType = .savedPhotosAlbum
        }
        // 시뮬레이터는 카메라가 없으므로, 실 아이폰의 경우 이라인 삭제
        imagePickerController.sourceType = .savedPhotosAlbum
        // UIImagePickerController이 전이 된다
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
}
extension CityDetailViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]as!UIImage
        cityImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
}
extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CityDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func initCountryPickerView(){ // dataSource, delegate를 등록한다
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 컴포턴트는 1개이다.
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return countries.count // 전체 나라의 갯수
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row] // 각 나라의 이름
    }
}
