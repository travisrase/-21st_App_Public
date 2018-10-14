import Foundation

public struct Notification: Decodable {
    public let notificationID: Int
    public let notificationDate: String?
    public let message: String?
    public let sourceLink: String?
    public let userID: String?
    public let posted: Bool?
}
