import CoreData
import Foundation

/// Manages the Core Data stack and provides CRUD helpers for local persistence.
final class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "ItaliaHobbyMotociclismo")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Save

    func save() {
        let ctx = viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }

    // MARK: - User

    func saveUser(_ user: User) {
        let ctx = viewContext
        let fetched: CDUser = fetchOrCreate(id: user.id, in: ctx)
        fetched.id             = user.id
        fetched.nickname       = user.nickname
        fetched.name           = user.name
        fetched.surname        = user.surname
        fetched.city           = user.city
        fetched.country        = user.country
        fetched.motorbikeBrand = user.motorbikeBrand
        fetched.motorbikeModel = user.motorbikeModel
        fetched.motorbikeType  = user.motorbikeType
        save()
    }

    func fetchUser(id: String) -> User? {
        let request = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        guard let cd = (try? viewContext.fetch(request))?.first else { return nil }
        return User(
            id:             cd.id ?? "",
            nickname:       cd.nickname ?? "",
            name:           cd.name ?? "",
            surname:        cd.surname ?? "",
            city:           cd.city ?? "",
            country:        cd.country ?? "",
            motorbikeBrand: cd.motorbikeBrand ?? "",
            motorbikeModel: cd.motorbikeModel ?? "",
            motorbikeType:  cd.motorbikeType ?? ""
        )
    }

    // MARK: - Events

    func saveEvents(_ events: [Event]) {
        let ctx = viewContext
        for event in events {
            let cd: CDEvent = fetchOrCreate(id: event.id, in: ctx)
            cd.id               = event.id
            cd.title            = event.title
            cd.desc             = event.description
            cd.date             = event.date
            cd.latitude         = event.latitude
            cd.longitude        = event.longitude
            cd.participantCount = Int32(event.participantCount)
            cd.isSubscribed     = event.isSubscribed
        }
        save()
    }

    func fetchEvents() -> [Event] {
        let request = CDEvent.fetchRequest()
        guard let results = try? viewContext.fetch(request) else { return [] }
        return results.compactMap { cd in
            guard let id = cd.id, let title = cd.title, let date = cd.date else { return nil }
            return Event(
                id:               id,
                title:            title,
                description:      cd.desc ?? "",
                date:             date,
                latitude:         cd.latitude,
                longitude:        cd.longitude,
                participantCount: Int(cd.participantCount),
                isSubscribed:     cd.isSubscribed
            )
        }
    }

    func updateEventSubscription(eventId: String, isSubscribed: Bool) {
        let request = CDEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", eventId)
        request.fetchLimit = 1
        if let cd = (try? viewContext.fetch(request))?.first {
            cd.isSubscribed = isSubscribed
            cd.participantCount += isSubscribed ? 1 : -1
            save()
        }
    }

    // MARK: - Messages

    func saveMessages(_ messages: [Message]) {
        let ctx = viewContext
        for message in messages {
            let cd: CDMessage = fetchOrCreate(id: message.id, in: ctx)
            cd.id             = message.id
            cd.eventId        = message.eventId
            cd.senderId       = message.senderId
            cd.senderNickname = message.senderNickname
            cd.text           = message.text
            cd.timestamp      = message.timestamp
        }
        save()
    }

    func fetchMessages(for eventId: String) -> [Message] {
        let request = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "eventId == %@", eventId)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        guard let results = try? viewContext.fetch(request) else { return [] }
        return results.compactMap { cd in
            guard let id = cd.id, let eid = cd.eventId,
                  let sid = cd.senderId, let nick = cd.senderNickname,
                  let text = cd.text, let ts = cd.timestamp else { return nil }
            return Message(id: id, eventId: eid, senderId: sid,
                           senderNickname: nick, text: text, timestamp: ts)
        }
    }

    // MARK: - Helpers

    private func fetchOrCreate<T: NSManagedObject>(id: String, in ctx: NSManagedObjectContext) -> T {
        let entityName = String(describing: T.self)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        if let existing = (try? ctx.fetch(request))?.first {
            return existing
        }
        return T(context: ctx)
    }
}
