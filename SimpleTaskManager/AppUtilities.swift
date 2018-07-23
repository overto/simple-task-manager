//
//  AppUtilities.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/17/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//

import Foundation

func dateFromString(_ dateFormat: String, _ dateText: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.date(from: dateText)
}

func dateToString(_ date: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.medium
    dateFormatter.timeStyle = DateFormatter.Style.none
    return dateFormatter.string(from: date)
}
