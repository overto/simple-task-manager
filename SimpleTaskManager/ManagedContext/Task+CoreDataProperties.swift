//
//  Task+CoreDataProperties.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/17/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completionDate: NSDate?
    @NSManaged public var title: String
    @NSManaged public var categoryName: String?

}
