//
//  PostEntity+CoreDataProperties.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 4/23/25.
//
//

import Foundation
import CoreData


extension PostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }

    @NSManaged public var asset: String?
    @NSManaged public var commentsData: Data?
    @NSManaged public var id: String?
    @NSManaged public var tagsData: Data?
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var upvotedByData: Data?
    @NSManaged public var upvotes: Int32
    @NSManaged public var user: String?

}

extension PostEntity : Identifiable {

}
