//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by User on 24.11.2020.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let context: NSManagedObjectContext
            
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData() -> [Task]? {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func addTask(withName taskName: String) -> Task? {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        
        task.name = taskName
        saveContext()
        return task
    }
    
    func editTask(_ editingTask: Task, withNewName newName: String) {
        editingTask.name = newName
        saveContext()
    }
    
    func deleteTask(_ deletingTask: Task) {
        context.delete(deletingTask)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
