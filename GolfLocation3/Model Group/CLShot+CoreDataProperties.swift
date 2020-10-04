//
//  CLShot+CoreDataProperties.swift
//  GolfLocation3
//
//  Created by Grant Lau on 2020-09-14.
//  Copyright © 2020 Grant Lau. All rights reserved.
//
//

import Foundation
import CoreData


extension CLShot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CLShot> {
        return NSFetchRequest<CLShot>(entityName: "CLShot")
    }

    @NSManaged public var clClub: String?
    @NSManaged public var clDate: Date?
    @NSManaged public var clDistance: Double
    @NSManaged public var clDistance2pin: Double
    @NSManaged public var clHole: Int64
    @NSManaged public var clProximity: Double
    @NSManaged public var clShot: Int64

}
