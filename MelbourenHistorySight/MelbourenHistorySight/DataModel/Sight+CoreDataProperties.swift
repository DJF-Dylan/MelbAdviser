//
//  Sight+CoreDataProperties.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 4/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//
//

import Foundation
import CoreData


extension Sight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sight> {
        return NSFetchRequest<Sight>(entityName: "Sight")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var image: String?
    @NSManaged public var icon: String?

}
