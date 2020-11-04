//
//  CoredataController.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {

    //variable declaration
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    var historyDataController: NSFetchedResultsController<History>?
    
    //initialization of the container
    override init() {
        persistantContainer = NSPersistentContainer(name: "SearchHistory")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
     
    //method to save the record to the database
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }

    //method to add a recordto the history
    func addHistory(antName: String, date: Date, favourite: Bool) -> History {
        let antHistory = NSEntityDescription.insertNewObject(forEntityName: "History", into:
        persistantContainer.viewContext) as! History
        antHistory.antName = antName
        antHistory.date = date
        antHistory.favourite = favourite
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return antHistory
    }
    
    //method to put a record as favourite or non favourite
    func addOrRemoveFavourites(history: History, favourite: Bool) {
        history.favourite = favourite
        saveContext()
    }
    
    //protocol methods for adding and removing listeners
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)

        if listener.listenerType == ListenerType.history || listener.listenerType == ListenerType.all {
            listener.onHistoryListChange(change: .update, historyList: fetchHistory())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    //A metho to fetch all the data from the database
    func fetchHistory() -> [History]{
        if historyDataController == nil {
            let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            historyDataController = NSFetchedResultsController<History>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            historyDataController?.delegate = self
            do {
                try historyDataController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }

        var history = [History]()
        if historyDataController?.fetchedObjects != nil {
            history = (historyDataController?.fetchedObjects)!
        }

        return history
    }
    
    //A function to fetch data whenever there is a change in the database
    func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
     if controller == historyDataController {
         listeners.invoke { (listener) in
             if listener.listenerType == ListenerType.history || listener.listenerType == ListenerType.all {
                listener.onHistoryListChange(change: .update, historyList: fetchHistory())
                }
            }
         }
     }
        
}
