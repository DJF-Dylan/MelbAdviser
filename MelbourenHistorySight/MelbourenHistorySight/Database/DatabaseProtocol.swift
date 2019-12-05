//
//  DatabaseProtocol.swift
//  FIT5140A1
//
//  Created by Lynn on 2/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case sight
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onSightListChange(change: DatabaseChange, sight: [Sight])
    
}
protocol DatabaseProtocol: AnyObject {
    
    func addSight(name: String, desc: String, longitude:Double, latitude: Double, image: String, icon: String) -> Sight
    func deleteSight(sight: Sight)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
