import Foundation
import os.signpost

enum LaunchTrace {
    private static let log = OSLog(subsystem: "chat.bitchat", category: "launch")
    private static let signposter = OSSignposter()
    private static var state = signposter.makeSignpostID()

    static func mark(_ name: StaticString) {
        os_signpost(.event, log: log, name: name)
    }

    static func begin(_ name: StaticString) {
        state = signposter.makeSignpostID()
        signposter.beginInterval(name, id: state)
    }

    static func end(_ name: StaticString) {
        signposter.endInterval(name, id: state)
    }
}

