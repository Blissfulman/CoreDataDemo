//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 23.11.2020.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    // MARK: - Properties
    private let cellID = "cell"
    private let storageManager = StorageManager.shared
    private var tasks = StorageManager.shared.fetchData()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    // MARK: - Actions
    @objc private func addNewTaskPressed() {
        showAddTaskAlert(withTitle: "Add New Task",
                         andMessage: "What do you want to do?")
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes =
            [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes =
            [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar
            .standardAppearance = navBarAppearance
        navigationController?.navigationBar
            .scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTaskPressed)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func addTask(withName taskName: String) {
        let newTask = storageManager.addTask(withName: taskName)
        tasks.append(newTask)
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func showAddTaskAlert(withTitle title: String,
                                  andMessage message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        let saveAction = UIAlertAction(title: "Add", style: .default) {
            [weak self] _ in
            
            guard let taskName = alert.textFields?.first?.text,
                  !taskName.isEmpty else { return }
            self?.addTask(withName: taskName)
        }
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showEditTaskAlert(withTitle title: String,
                                   andMessage message: String,
                                   taskName: String,
                                   completion: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            guard let newTaskName = alert.textFields?.first?.text,
                  !newTaskName.isEmpty else { return }
            completion(newTaskName)
        }
        
        alert.addTextField { textField in
            textField.text = taskName
        }
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - TableViewDataSource
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    // Удаление задачи
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            storageManager.deleteTask(tasks[indexPath.row])
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {

    // Редактирование задачи
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTask = tasks[indexPath.row]

        showEditTaskAlert(withTitle: "Edit Task",
                          andMessage: "Insert a new task name",
                          taskName: selectedTask.name ?? "") {
            [weak self] (newTaskName) in
            
            guard let self = self else { return }
                                    
            guard selectedTask.name != newTaskName else { return }
            
            self.storageManager.editTask(selectedTask, withNewName: newTaskName)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
