//
//  ViewController.swift
//  RxExample
//
//  Created by tungnd on 12/17/18.
//  Copyright © 2018 tungnd. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealmDataSources
import RxSwift
import RxAlamofire
import RxCocoa
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedNameLabel: UILabel!
    
    // DisposeBag
    let disposeBag = DisposeBag()
    // Config tableView Data Source
    let dataSource = RxTableViewRealmDataSource<CustomerModel>(cellIdentifier: CustomerCell.cellIdenfiter, cellType: CustomerCell.self) { (cell, indexPath, model) in
        cell.nameLabel.text = model.name
        cell.codeLabel.text = model.code
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        tableView.register(UINib(nibName: CustomerCell.cellIdenfiter, bundle: nil), forCellReuseIdentifier: CustomerCell.cellIdenfiter)
        textField.rx.text // Observable property
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            .subscribe(onNext: { query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
                print("search text \(query)")
                self.searchCustomer(with: query)
            })
            .disposed(by: disposeBag)
        
        let realm = try! Realm()
        
        Observable
            .changeset(from: realm.objects(CustomerModel.self)) // Handle change form realm
            .bind(to: tableView.rx.realmChanges(dataSource)) // Bind data to tableView
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected // Hanle tableView selected
            .map({self.dataSource.model(at: $0).name}) // Return Observable
            .bind(to: selectedNameLabel.rx.text) // Bind data to selectedName
            .disposed(by: disposeBag)
    }

    func searchCustomer(with keyword: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        // Init api manager and setup requite info
        let manager = SessionManager.default
        let bearerToken = "Bearer eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkExMjhDQkMtSFMyNTYiLCJraWQiOiJzQngifQ.AehmyuL0ayMusgotC6uW3pprcj7CF6Dw5jjuSFyFAkFA-U8yDM3VJl9fwkVlJHFM28c57Xq0bDrxpZNC5wqt8pHqFJxia-sTAa2fU_wJIFWDI7VO939rJSWcqKdgx1AdXqXHGYTfGwZgS_bGL62xlv7AGal8Sq-86cdh-LkthOQbJVIVuGn8e_cmYPVyhIIZ38CiPTDXDAff1cX4jh6GhNeL7vfAK-Gs3hXZOmaQblsAcTGnBfW6dArrGlOzq1McFEAz33O3ngrlNUlw3HrGM92IHEa357MDgWFNrPdvJ-paxA_-xcOy3yK4p8HuUJcL_TuaZQOrfaJc9yOuP92r0w._WOyZZWNqPMJZQgIODnG1Q.hhLTpeAqxZORsotw1LDDgQdHvpb9J2_jYRjHXjd6JJoohXtV1AjBekgSJXDRzSrwxBr1KiiGB67WZsa9KpzQqb4sUY01ayDf1Zd8zraph1-yXppYD4ZuJ3KsP94uJOp5uaFq7B093wtwmidGzRVImrMGARTBH0rQv4Si5rNO6wsmyGEDesFe4tvVv_dRPYgqZzZJ0o6JePX5dshNuJ0w8rsDr9vNe0kA5RvtolxBx3Df79yNEgD3_oYlNVEcuC5OXczu1d2DHfTEtohxw3wDGOSQpb1QNgGZfqaiTkcPbV_htZEWUnk5_iSC-aK4UODOV6-PDaqD4mqFdJEWZqbxBb1K3Kc8tsYukBNXc87fcqp9lnyyN_ITZDFWmyG_zHRJ1fDZRIaN_qaYWHh5cKAc5GilfqUW1fxJ-xTJ6EW9WJ0RaMt3XM0EG-hofqwf1nMPBhwxUW7IXSxwrjjqr7LK_elli0XeCH_HfTJBLio0JcV6WdL2M8cUsSD_ytFIplcGtRCUYNguhTy4OV9F0uVkug.OOcKhFXD5D7wLPxtnfNhba8OBGYFNasmUyLaA7NirAg"
        let headers : [String : String] = ["Retailer" : "gauto", "Authorization" : bearerToken]
        let parameters : [String : Any] = ["top" : 50, "skip" : 0, "FindString" : keyword]
        let apiPath = "https://kvpos.com:9033/customers"
        
        manager.rx.json(.get, apiPath, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .subscribe(onNext: { (next) in // When request success
                let json = JSON(next)
                guard let data = json["Data"].array else { return }
                let realm = try! Realm()
                try! realm.write {
                    realm.add(data.map({CustomerModel(with: $0)}))
                }
            }, onError: { (error) in
                print(error.localizedDescription) // When request error
            }, onCompleted: nil, onDisposed: nil) // On comple on this time unuse
            .disposed(by: self.disposeBag)
    }
    
}

