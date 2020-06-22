import Foundation
import UserNotifications
import DP3TSDK_CALIBRATION

let stateChangedNotification = NSNotification.Name("stateChanged")
let tracingStateChangedNotification = NSNotification.Name("tracingStateChanged")

class ExposureManager {

    static let shared = ExposureManager()

    var exposures: [ExposureDay] = [] {
        didSet {
            let oldIdentifiers = Configuration.exposureIdentifiers()
            let newIdentifiers = exposures.map { $0.identifier }

            Configuration.setExposureIdentifiers(identifiers: newIdentifiers)

            for identifier in newIdentifiers {
                if !oldIdentifiers.contains(identifier) {
                    // There is a new identifier, need to show notification:
                    sendLocalNotification()

                    break // Send only one & stop
                }
            }
        }
    }

    var status: HomeStatus = .active {
        didSet {
            if oldValue != status {
                NotificationCenter.default.post(name: stateChangedNotification, object: nil)
            }
        }
    }
    var tracingState: TracingState?

    func initialize() {
        guard let backendUrl = Configuration.backendUrl(), backendUrl.absoluteString.count > 8 else {
            fatalError("Could not initialize DP3T Tracing, backendURL was missing")
        }

        var urlSession = URLSession.shared

        if Configuration.certificateFileName()?.isEmpty == false {
            urlSession = URLSession.certificatePinned
        }

        let publicKeyString = Configuration.backendPublicKey()
        let publicKey = publicKeyString != nil ? Data(base64Encoded: publicKeyString!) : nil

        let identifierPrefix = Configuration.pilotId() ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

        do {
            try DP3TTracing.initialize(with:
                    .manual(ApplicationDescriptor(appId: "fi.ketjusovellus.Ketju",
                                                  bucketBaseUrl: backendUrl,
                                                  reportBaseUrl: backendUrl,
                                                  jwtPublicKey: publicKey)),
                    urlSession: urlSession,
                    mode: .calibration(identifierPrefix: identifierPrefix, appVersion: appVersion))
            
            DP3TTracing.delegate = self

        } catch {
            print("Could not init DP3T: \(error)")
        }
    }

    func start() {
        do {
            sync()
            try DP3TTracing.startTracing()

        } catch {
            print("Could not start tracing with DP3T: \(error)")

            // This can happen at least in the case when user has already uploaded diagnosis key.
        }
    }

    func stop() {
        DP3TTracing.stopTracing()
    }

    func reset() {
        do {
            try DP3TTracing.reset()

        } catch {
            print("Could not reset DP3T: \(error)")
        }
    }

    func sync() {
        DP3TTracing.sync { result in
            switch result {
            case let .failure(error):
                print("Data sync error: \(error)")
            case .success:
                print("Data synced!")
            }
        }
    }

    func uploadDiagnosisKey(onsetDate: Date, authString: String, completed: @escaping (String?) -> Void) {
        let authentication = ExposeeAuthMethod.JSONPayload(token: authString)
        DP3TTracing.iWasExposed(onset: onsetDate, authentication: authentication) { result in
            switch result {
            case .success:
                print("success")
                completed(nil)
            case let .failure(e):
                print("failure \(e)")

                var errorMessage = ""
                switch e {
                case .userAlreadyMarkedAsInfected:
                    errorMessage = NSLocalizedString("Upload_error_already_infected", comment: "")
                default:
                    errorMessage = NSLocalizedString("Upload_error_network", comment: "")
                }

                completed(errorMessage)
            }
        }
    }

    private func handleTracingState(_ state: TracingState) {
        tracingState = state
        NotificationCenter.default.post(name: tracingStateChangedNotification, object: nil)

        switch state.infectionStatus {
        case let .exposed(days: exposureDays):
            print("You have been exposed!")

            exposures = exposureDays
            status = .exposed

            return

        case .infected:
            print("YOU HAVE THE VIRUS")

            status = .diagnosisKeyUploaded

            return

        case .healthy:
            break // Go to the next flow
        }

        switch state.trackingState {
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                status = .bluetoothOff
            case .permissonError:
                status = .bluetoothDenied
            default:
                status = .error
            }
        default:
            status = .active
        }
    }

    private func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        if #available(iOS 12.0, *) {
            content.sound = UNNotificationSound.defaultCritical
        } else {
            content.sound = UNNotificationSound.default
        }
        content.title = NSLocalizedString("Notification_title", comment: "")
        content.body = NSLocalizedString("Notification_message", comment: "")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { error in
            if let error = error {
                print(error)
            }
        })
    }

}

extension ExposureManager: DP3TTracingDelegate {

    func DP3TTracingStateChanged(_ state: TracingState) {
        print("Tracing state changed: \(state.trackingState)")

        handleTracingState(state)
    }

}

