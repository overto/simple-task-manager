//
//  Category+CoreDataProperties.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/17/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var color: String
    @NSManaged public var name: String

}
