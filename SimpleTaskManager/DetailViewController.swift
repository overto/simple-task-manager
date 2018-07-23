//
//  DetailViewController.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/8/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    var task: Task?
    var categories: [Category] = []
    var categorySelected: Int = -1
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        
        dateTextField.text = dateToString(sender.date)
    }
    
    @IBAction func saveTask(_ sender: Any) {
        
        if titleTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            titleTextField.layer.borderColor = UIColor.red.cgColor
            titleTextField.layer.borderWidth = 1.0
            titleTextField.setNeedsDisplay()
            return
        }
        
        let taskDate = dateFromString("MMM dd, yyyy", dateTextField.text!) as NSDate?
        
        self.save(titleTextField.text!, taskDate)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func deleteTask(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Task", message: "Confirm deletion of this task", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.deleteTaskSave()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion:nil)
    }
    
    func deleteTaskSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        if let taskToDelete = task {
            context.delete(taskToDelete)
            do {
                try context.save()
                
            } catch let err as NSError {
                print("Failed to delete task", err)
            }
        }
    }
    
    func save(_ taskTitle: String,_ taskCompletionDate: NSDate?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        task?.title = taskTitle
        task?.completionDate = taskCompletionDate
        if categorySelected > -1 {
            task?.categoryName = categories[categorySelected].name
        }
        
        do {
            try context.save()
        } catch let err as NSError {
            print("Failed to save a task", err)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = UIDatePickerMode.date
        titleTextField.text = task?.title ?? ""
        
        if let completionDate = task?.completionDate as Date? {
            dateTextField.text = dateToString(completionDate)
            datePicker.date = completionDate
        } else {
            dateTextField.text = ""
        }
        
        categoryTextField.isUserInteractionEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData()
        
        if let taskCategory = task?.categoryName {
            categoryTextField.backgroundColor = UIColor().colorFromHex(getCategoryColor(taskCategory)!)
            categoryTextField.text = taskCategory
        }
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        do {
            if let result = try context.fetch(fetchRequest) as? [Category]  {
                categories = result
            }
        } catch let err as NSError {
            print("Failed to fetch categories", err)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        label.textAlignment = .center
        label.text = categories[row].name
        label.backgroundColor = UIColor().colorFromHex(categories[row].color)
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categories.count >= 1 {
            categorySelected = row
            categoryTextField.backgroundColor = UIColor().colorFromHex(categories[row].color)
            categoryTextField.text = categories[row].name
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
    
}
