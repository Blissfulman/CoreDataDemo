//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by User on 24.11.2020.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext!
            
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData() -> [Task]? {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        var tasks = [Task]()
        
        do {
            tasks = try context.fetch(fetchRequest)
            return tasks
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func getTask(at index: Int) -> Task? {
        guard let tasks = fetchData() else { return nil }
        return tasks[index]
    }
    
    func addTask(withName taskName: String) -> Task? {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        
        task.name = taskName
        
        if context.hasChanges {
            do {
                try context.save()
                return task
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        return nil
    }
    
    func editTask(newName: String, at index: Int) {
        guard let editingTask = getTask(at: index) else { return }
        
        editingTask.name = newName
        saveContext()
    }
    
    func deleteTask(at index: Int) {
        guard let deletingTask = getTask(at: index) else { return }

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
