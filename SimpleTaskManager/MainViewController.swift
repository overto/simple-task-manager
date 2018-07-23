//
//  MainViewController.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/8/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var categories = [Category]()
    var categorySelected: Category?
    let sections = ["Current Tasks", "Completed Tasks"]
    var tasksCurrent = [Task]()
    var tasksCompleted = [Task]()
    var colorPicker: UIPickerView!
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var settingsImage = UIImage(named: "SettingsIcon")
        settingsImage = settingsImage?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: settingsImage, style:.plain, target: self, action: #selector(editSettings))
        
        var addImage = UIImage(named: "AddIcon")
        addImage = addImage?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style:.plain, target: self, action: #selector(addTask))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData()
        self.tableView.reloadData()
    }
    
    @objc func editSettings() {
        performSegue(withIdentifier: "editSettings", sender: nil)
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        // Retrieve Tasks
        let fetchRequestForTasks = NSFetchRequest<NSManagedObject>(entityName: "Task")
        tasksCurrent.removeAll()
        tasksCompleted.removeAll()
        do {
            if let result = try context.fetch(fetchRequestForTasks) as? [Task] {
                for task in result {
                    if let taskDate = task.completionDate as Date? {
                        if taskDate > Date() {
                            tasksCurrent.append(task)
                        }
                        else {
                            tasksCompleted.append(task)
                        }
                    }
                    else {
                        tasksCurrent.append(task)
                    }
                }
            }
        } catch let err as NSError {
            print("Failed to fetch tasks", err)
        }
        // Retrieve Categories
        let fetchRequestCategories = NSFetchRequest<NSManagedObject>(entityName: "Category")
        categories.removeAll()
        do {
            if let result = try context.fetch(fetchRequestCategories) as? [Category] {
                categories = result
            }
        } catch let err as NSError {
            print("Failed to fetch categories", err)
        }
    }
    
    @objc func addTask(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Add New Task", message: "Please enter the task below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Task Title"
        })
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let taskTitle = alert.textFields?.first?.text else { return }
            if taskTitle.isEmpty {
                return
            }
            self.createTask(taskTitle, self.categorySelected?.name)
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.40)
        alert.view.addConstraint(height);
        
        present(alert, animated: true, completion: { () in
            self.colorPicker = UIPickerView(frame:
                CGRect(x: 20, y: 100, width: (alert.view.frame.size.width - 40), height: 150))
            self.colorPicker.dataSource = self
            self.colorPicker.delegate = self
            alert.view.addSubview(self.colorPicker)
        })
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categorySelected = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel { label = view }
        else {
            label = UILabel()
        }
        
        label.textAlignment = .center
        label.text = categories[row].name
        label.backgroundColor = UIColor().colorFromHex(categories[row].color)
        
        return label
    }
    
    func createTask(_ taskTitle: String, _ categoryName: String?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
        let task = Task(entity: entity, insertInto: context)
        task.title = taskTitle
        
        if let taskCategory = categoryName {
            task.categoryName = taskCategory
        }
        
        do {
            try context.save()
            self.fetchData()
        } catch let err as NSError {
            print("Failed to save a task", err)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            if indexPath.section == 0 {
                context.delete(tasksCurrent[indexPath.row])
            }
            else if indexPath.section == 1{
                context.delete(tasksCompleted[indexPath.row])
            }
            
            do {
                try context.save()
                self.fetchData()
                self.tableView.reloadData()
            } catch let err as NSError {
                print("Failed to delete task", err)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return tasksCurrent.count
        }
        else if section == 1 {
            return tasksCompleted.count
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = "Task: \(tasksCurrent[indexPath.row].title)"
            
            if let date = tasksCurrent[indexPath.row].completionDate as Date? {
                cell?.detailTextLabel?.text = "Completion Date: \(dateToString(date)!)"
            }
            else {
                cell?.detailTextLabel?.text = "Completion Date: None"
            }
            
            if let taskName = tasksCurrent[indexPath.row].categoryName {
                cell?.backgroundColor = UIColor().colorFromHex(getCategoryColor(taskName)!)
            }
            
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = "Task: \(tasksCompleted[indexPath.row].title)"
            if let date = tasksCompleted[indexPath.row].completionDate as Date? {
                cell?.detailTextLabel?.text = "Completion Date: \(dateToString(date)!)"
            }
            else {
                cell?.detailTextLabel?.text = "Completion Date: None"
            }
            
            if let taskName = tasksCompleted[indexPath.row].categoryName {
                cell?.backgroundColor = UIColor().colorFromHex(getCategoryColor(taskName)!)
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "editTask", sender: tasksCurrent[indexPath.row])
        } else if indexPath.section == 1 {
            performSegue(withIdentifier: "editTask", sender: tasksCompleted[indexPath.row])
        }
        
    }
    
    func getCategoryColor(_ categoryName: String) -> String? {
        var categoryColor: String = ""
        for category in categories {
            if category.name == categoryName {
                categoryColor = category.color
                return categoryColor
            }
        }
        return categoryColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "editSettings" {
        }
        else if segue.identifier == "editTask" {
            let vc = segue.destination as! DetailViewController
            guard let task = sender as? Task else { return }
            vc.task = task
        }
    }

}
