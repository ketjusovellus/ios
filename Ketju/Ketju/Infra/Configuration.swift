import Foundation

class Configuration {

    private enum Key: String {
        case userHasSeenOnboarding
        case exposureIdentifiers
        case pilotId
    }

    static func backendUrl() -> URL? {
        if let urlString = Bundle.main.infoDictionary?["KETJU_BACKEND_URL"] as? String {
            return URL(string: urlString)
        }
        return nil
    }

    static func backendPublicKey() -> String? {
        return Bundle.main.infoDictionary?["KETJU_BACKEND_JWT_PUBLIC_KEY"] as? String
    }

    static func certificateFileName() -> String? {
        return Bundle.main.infoDictionary?["KETJU_BACKEND_CERTIFICATE_FILENAME"] as? String
    }

    static func setHasSeenOnboarding(seen: Bool) {
        UserDefaults.standard.set(seen, forKey: Key.userHasSeenOnboarding.rawValue)
    }

    static func hasSeenOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: Key.userHasSeenOnboarding.rawValue)
    }

    static func setExposureIdentifiers(identifiers: [Int]) {
        UserDefaults.standard.set(identifiers, forKey: Key.exposureIdentifiers.rawValue)
    }

    static func exposureIdentifiers() -> [Int] {
        UserDefaults.standard.array(forKey: Key.exposureIdentifiers.rawValue) as? [Int] ?? []
    }

    static func setPilotId(_ id: String) {
        UserDefaults.standard.set(id, forKey: Key.pilotId.rawValue)
    }

    static func pilotId() -> String? {
        UserDefaults.standard.string(forKey: Key.pilotId.rawValue)
    }
    
}
