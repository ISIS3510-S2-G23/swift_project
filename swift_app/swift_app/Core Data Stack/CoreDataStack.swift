//
//  CoreDataStack.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 4/23/25.
//
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded: \(storeDescription)")
            }
        }
        
        let model = container.managedObjectModel
            print("Managed Object Model: \(model.entitiesByName)")
        
        return container
    }()

    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("CoreDataStack: Unresolved error saving context \(error), \(error.userInfo)")
            }
        }
    }
    
    // Helper function to convert between Core Data and your Post model
    func post(from entity: PostEntity) -> Post {
        // Convert Binary Data back to arrays/dictionaries
        var tags: [String]? = nil
        if let tagsData = entity.tagsData {
            tags = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: tagsData) as? [String]
        }
        
        var upvotedBy: [String]? = nil
        if let upvotedByData = entity.upvotedByData {
            upvotedBy = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: upvotedByData) as? [String]
        }
        
        var comments: [String: String]? = nil
        if let commentsData = entity.commentsData {
            comments = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: commentsData) as? [String: String]
        }
        
        return Post(
            id: entity.id ?? "",
            asset: entity.asset,
            comments: comments,
            tags: tags,
            text: entity.text ?? "",
            timestamp: entity.timestamp ?? Date(),
            title: entity.title ?? "",
            upvotedBy: upvotedBy,
            upvotes: Int(entity.upvotes),
            user: entity.user ?? ""
        )
    }
    
    // Create a new post entity
    func createPostEntity(from post: Post) -> PostEntity {
        let entity = PostEntity(context: viewContext)
        
        entity.id = post.id
        entity.asset = post.asset
        entity.text = post.text
        entity.timestamp = post.timestamp
        entity.title = post.title
        entity.upvotes = Int32(post.upvotes)
        entity.user = post.user
        
        // Convert arrays and dictionaries to Binary Data
        if let tags = post.tags {
            entity.tagsData = try? NSKeyedArchiver.archivedData(withRootObject: tags, requiringSecureCoding: false)
        }
        
        if let upvotedBy = post.upvotedBy {
            entity.upvotedByData = try? NSKeyedArchiver.archivedData(withRootObject: upvotedBy, requiringSecureCoding: false)
        }
        
        if let comments = post.comments {
            entity.commentsData = try? NSKeyedArchiver.archivedData(withRootObject: comments, requiringSecureCoding: false)
        }
        
        return entity
    }
    
    // Clear all posts from Core Data
    func clearAllPosts() {
        print("INTENTE FETCH")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "PostEntity")
        print("INTENTE DELETE")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to clear posts: \(error)")
        }
    }
    
    // Get all saved posts
    func getAllSavedPosts() -> [Post] {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.map { post(from: $0) }
        } catch {
            print("Failed to fetch saved posts: \(error)")
            return []
        }
    }
}
