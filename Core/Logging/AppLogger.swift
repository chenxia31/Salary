import Foundation
import os

public enum AppLogger {
    private static let subsystem = "com.openclaw.salaryticker"

    public static let calculation = Logger(subsystem: subsystem, category: "calculation")
    public static let storage = Logger(subsystem: subsystem, category: "storage")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    public static let app = Logger(subsystem: subsystem, category: "app")
}
