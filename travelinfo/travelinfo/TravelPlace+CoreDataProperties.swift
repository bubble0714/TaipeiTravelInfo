//
//  TravelPlace+CoreDataProperties.swift
//  travelinfo
//
//  Created by Milly on 9/25/16.
//  Copyright © 2016 Milly. All rights reserved.
//

import Foundation
import CoreData


extension TravelPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelPlace> {
        return NSFetchRequest<TravelPlace>(entityName: "TravelPlace");
    }

    @NSManaged public var id: Int32
    @NSManaged public var type: String?
    @NSManaged public var introduction: String?
    @NSManaged public var filename: String?
    @NSManaged public var placename: String?

}
