//
//  DateHelper.swift
//  achievements
//
//  Created by Maximilian Schluer on 19.12.21.
//

import Foundation

class DateHelper {
    static func createDayArray(from beginDateComponents: DateComponents, to endDateComponents: DateComponents) -> [DateComponents] {
        // Verify, whether handed dates are valid
        guard let beginDate = Calendar.current.date(from: beginDateComponents) else {
            return []
        }
        guard let endDate = Calendar.current.date(from: endDateComponents) else {
            return []
        }
        
        // Verify, that the endDate is after the startDate, otherwise swap
        if(beginDate > endDate) {
            return createDayArray(from: endDateComponents, to: beginDateComponents)
        }
        
        var currentDate = beginDate
        var result = [ beginDateComponents ]
        
        // Loop till current day is reached
        while(currentDate < endDate) {
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            result.append(Calendar.current.dateComponents([.year, .month, .day], from: currentDate))
        }
        
        return result
    }
    
    static func createDayArray(from beginDate: Date, to endDate: Date) -> [DateComponents] {
        return createDayArray(from: Calendar.current.dateComponents([.year, .month, .day], from: beginDate), to: Calendar.current.dateComponents([.year, .month, .day], from: endDate))
    }
}
