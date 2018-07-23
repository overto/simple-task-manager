//
//  SettingsViewController.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/14/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import NotificationCenter

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var categories: [Category] = []
    var colorPicker: UIPickerView!
    var colors = ["#C6DA02","#79A700","#F68B2C","#E2B400","#F5522D", "#FF6E83"]
    var colorSelected: String = ""
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    @IBAction func localNotificationsSwitch(_ sender: Any) {
        
        if notificationsSwitch.isOn {
            self.checkNotificationsAuthorization()
        }
        else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.cancelAllNotifications()
            }
            //self.cancelAllNotifications()
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "LocalNotifications")
        }
    }
    
    func checkNotificationsAuthorization() {
        
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.getNotificationSettings { (settings) in
            
            if (settings.authorizationStatus == .authorized)
            {
                let permissionDataDict:[String:Bool] = ["granted": true]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .localNotificationsPermissionGranted, object: nil, userInfo: permissionDataDict)
                }
            }
            else {
                let permissionDataDict:[String:Bool] = ["granted": false]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .localNotificationsPermissionGranted, object: nil, userInfo: permissionDataDict)
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorSelected = colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel { label = view }
        else {
            label = UILabel()
        }
    
        label.textAlignment = .center
        label.backgroundColor = UIColor().colorFromHex(colors[row])
        
        return label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Place add button for navigator
        var addImage = UIImage(named: "AddIcon")
        addImage = addImage?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style:.plain, target: self, action: #selector(addCategory))
        
        // Set local notifications switchlet
        let defaults = UserDefaults.standard
        let notificationsPermission = defaults.bool(forKey: "LocalNotifications")
        self.notificationsSwitch.setOn(notificationsPermission, animated: true)
        
        // Register notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsPermissionGranted(_:)), name: .localNotificationsPermissionGranted, object: nil)
    }
    
    @objc func notificationsPermissionGranted(_ notification: Notification) {
        
        if let data = notification.userInfo as? [String: Bool] {
            
            for (permission, status) in data {
                if permission == "granted" && status == true {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.createLocalNotification()
                    }
                    //self.createLocalNotification()
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "LocalNotifications")
                    if !self.notificationsSwitch.isOn {
                        self.notificationsSwitch.setOn(true, animated: false)
                    }
                }
                else if permission == "granted" && status == false {
                    // Turn notifications toggle off
                    self.notificationsSwitch.setOn(false, animated: false)
                    
                    // Alert: Request user to authorize local notifications in Settings
                    let alert = UIAlertController(title: "Local Notifications Permission", message: "Please go to Settings and turn on permissions for this app", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alert.addAction(cancelAction)
                    alert.addAction(settingsAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData()
        
    }
    
    @objc func addCategory(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Add New Category", message: "Please enter the category below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Category Name"
        })
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let categoryName = alert.textFields?.first?.text else { return }
            if categoryName.isEmpty {
                let alert = UIAlertController(title: "Category Already Exists!", message: "Please enter a different category name", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.save(categoryName, self.colorSelected)
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
    
    func save(_ categoryName: String,_ categoryColor: String) {
        // Check if category already exists before adding
        for category in categories {
            if category.name == categoryName {
                return
            }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        let category = Category(entity: entity, insertInto: context)
        category.name = categoryName
        category.color = categoryColor
        
        do {
            try context.save()
            self.fetchData()
        } catch let err as NSError {
            print("Failed to save a task", err)
        }
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        categories.removeAll()
        do {
            if let result = try context.fetch(fetchRequest) as? [Category] {
                categories = result
            }
        } catch let err as NSError {
            print("Failed to fetch categories", err)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        
        cell?.textLabel?.textAlignment = NSTextAlignment.center
        cell?.textLabel?.text = categories[indexPath.row].name
        cell?.backgroundColor = UIColor().colorFromHex(categories[indexPath.row].color)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(categories[indexPath.row])
            do {
                try context.save()
                categories.removeAll()
                self.fetchData()
                self.tableView.reloadData()
            } catch let err as NSError {
                print("Failed to delete category", err)
            }
        }
    }

}
