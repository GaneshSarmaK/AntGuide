//
//  DatabaseProtocol.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import Foundation
enum DatabaseChange {
 case add
 case remove
 case update
}

///History Storing listeners and protocols

enum ListenerType {
    case history
    case all
}

//database listeners. These are responsible for notifying when there is a change in the database
protocol DatabaseListener: AnyObject {
 var listenerType: ListenerType {get set}
    func onHistoryListChange(change: DatabaseChange, historyList: [History])
}
//these help to change the data in the datbase
protocol DatabaseProtocol: AnyObject {

    func addHistory(antName: String, date: Date, favourite: Bool) -> History
    func addOrRemoveFavourites(history: History, favourite: Bool)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}


/////Image Storing listeners and protocols
//enum imageListenerType{
//    case image
//    case all
//}
//
////database listeners. These are responsible for notifying when there is a change in the database
//protocol imageStoreListener: AnyObject {
// var listenerType: imageListenerType {get set}
//    func onImageStoreListChange(change: DatabaseChange, historyList: [History])
//}
////these help to change the data in the datbase
//protocol imageStoreProtocol: AnyObject {
//
//    func addImage(antName: String, urlPath: String)
//    func getImage(antName: String, urlPath: String) 
//    func addListener(listener: imageStoreListener)
//    func removeListener(listener: imageStoreListener)
//}
