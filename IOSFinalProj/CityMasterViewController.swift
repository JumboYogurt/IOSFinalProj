//
//  ViewController.swift
//  CH09_TableViewCollectionView
//
//  Created by mac022 on 2024/05/16.
//

import UIKit

class CityMasterViewController: UIViewController {

    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cities:[City] = IOSFinalProj.load("cityData.json")
    var imagePool:[String:UIImage] = [:]
    
    var dbFirebase: DbFirebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cityTableView.dataSource = self
        cityTableView.delegate = self
        
        cityTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        descriptionLabel.text = cities[0].description
        
        dbFirebase = DbFirebase(parentNotification: manageDatabase)
        
        dbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    func manageDatabase(dict:[String:Any]?, dbaction: DbAction?){
        let city = City.fromDict(dict: dict!)
        if dbaction == .add{ // 단순히 배열에 더한다
            cities.append(city)
        }
        if dbaction == .modify{ // 수정인 경우 선택된 row가 있으므로 그것을 수정
            if let indexPath = cityTableView.indexPathForSelectedRow{
                cities[indexPath.row] = city // 선택된 row의 시티정보 수정
            }
        }
        if dbaction == .delete{
            for i in 0..<cities.count{
                if city.id == cities[i].id{
                    cities.remove(at: i)
                    break
                }
            }
        }
        // 삭제 대상을 찾아야 한다. // 삭제한다
        cityTableView.reloadData() //tableView의내용을업데이트한다
        if let indexPath = cityTableView.indexPathForSelectedRow{
            // 만약 선택된 row가 있다면 그 도시의 description 내용을 업데이트 한다
            descriptionLabel.text = cities[indexPath.row].description
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = cityTableView.indexPathForSelectedRow{
            descriptionLabel.text = cities[indexPath.row].description
        }
        cityTableView.reloadData()
    }
    
    @IBAction func addingCity(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GotoDetail", sender: nil)
    }
}
extension CityMasterViewController:UITableViewDataSource   {
    // 이 함수는 Option이다. 구현하지 않으면 섹션이 1이다.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1의 섹션만 한다.
    }
    // 각 섹션에 대하여 몇개의 행을 가진것인가. 섹션이 하나이므로 한번만 호출된다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    // 각 섹션의 row에 해당하는 UITableViewCell를 만들어 달라
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell() // contentView와 [accessaryType or accessoryView]로 구성
        let cell = tableView.dequeueReusableCell(withIdentifier: "yelee")!
        let city = cities[indexPath.row]
        if let image = imagePool[city.imageName]{
            cell.imageView?.image = image.resized(to: CGSize(width: 200, height: 100))
        }else{
            cell.imageView?.image = city.uiImage()?.resized(to: CGSize(width: 200, height: 100))
        }
        if cell.imageView?.image == nil{
            // 스레드에 의하여 나중에 호출된다.
            // 주의할 점은 스레드에 의하여 completion이 호출되는 시점에서 cell은 이미 화면에 나타나고
            // 그래서 cell의 layout이 이미 끝난 상태이다.
            // 따라서 이미지를 적용하기 위해서는 레이우웃이 필요,
            cell.setNeedsLayout()
            dbFirebase?.downloadImage(imageName: city.imageName, completion: {
                image in
                cell.imageView?.image = image?.resized(to: CGSize(width: 200, height: 100))
                cell.setNeedsLayout() // 이미 layout이 설정되었으므로 재설정이 필요
            })
        }
                                      
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = "in \(city.country)"
        cell.textLabel?.textAlignment = .right
        cell.accessoryType = .none
        
        return cell
        
    }
}
extension CityMasterViewController: UITableViewDelegate{
// 특정 row를 클릭하면 이 함수가 호출된다
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //descriptionLabel.text = " \(indexPath.row)th row was selected"
        tableView.cellForRow(at: indexPath)?.accessoryType = .detailDisclosureButton
        descriptionLabel.text = cities[indexPath.row].description
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        performSegue(withIdentifier: "GotoDetail", sender: indexPath)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let city = cities[indexPath.row]
            
            if city.id<1011{
                cities.remove(at: indexPath.row)
                tableView.reloadData()
            }else{
                dbFirebase?.saveChange(key: String(city.id), object: City.toDict(city: city), action: .delete)
            }
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let city = cities.remove(at: sourceIndexPath.row)
        cities.insert(city, at: destinationIndexPath.row)
        tableView.reloadData()
    }
}

extension CityMasterViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cityDetailViewController = segue.destination as? CityDetailViewController
        
        cityDetailViewController!.cityMasterViewController = self
        //cityDetailViewController?.cities = cities
        //cityDetailViewController?.imagePool = imagePool
        
        if let indexPath = sender as? IndexPath{
            cityDetailViewController?.selectedCity = indexPath.row
        }
    }
}
