//
//  CustomerModel.swift
//  RxExample
//
//  Created by tungnd on 12/17/18.
//  Copyright © 2018 tungnd. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CustomerModel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var code = ""
    
    convenience init(with json: JSON) {
        self.init()
        id = json["Id"].intValue
        name = json["Name"].stringValue
        code = json ["Code"].stringValue
    }
    
    static override func primaryKey() -> String {
        return "id"
    }
}
