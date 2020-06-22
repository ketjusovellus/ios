import UIKit
import DP3TSDK_CALIBRATION
import MessageUI

class DebugViewController: UITableViewController {

    struct DebugViewModel {
        let title: String
        let value: String
    }

    private let dateFormatter = DateFormatter()
    private var viewModels: [DebugViewModel] = []
    private var sharedFileUrl: URL?

    init() {
        super.init(style: .grouped)

        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close_button", comment: ""),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Share_db_button", comment: ""),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(shareDatabase))

        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: tracingStateChangedNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        ExposureManager.shared.sync()

        updateView()
    }

    @objc private func updateView() {
        if let tracingState = ExposureManager.shared.tracingState {
            viewModels = readData(tracingState)
            tableView.reloadData()
        }
    }

    private func readData(_ state: TracingState) -> [DebugViewModel] {
        var viewModels: [DebugViewModel] = []

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"

        viewModels.append(DebugViewModel(title: "Ketju version", value: "\(appVersion) (\(buildNumber))"))
        viewModels.append(DebugViewModel(title: "Identifier", value: Configuration.pilotId() ?? "-"))
        viewModels.append(DebugViewModel(title: "Handshakes", value: "\(state.numberOfHandshakes)"))
        viewModels.append(DebugViewModel(title: "Contacts", value: "\(state.numberOfContacts)"))
        viewModels.append(DebugViewModel(title: "Tracking state", value: "\(state.trackingState.title())"))

        if let lastSync = state.lastSync {
            viewModels.append(DebugViewModel(title: "Last sync", value: "\(dateFormatter.string(from: lastSync))"))
        } else {
            viewModels.append(DebugViewModel(title: "Last sync", value: "-"))
        }

        switch state.infectionStatus {
        case .healthy:
            viewModels.append(DebugViewModel(title: "Status", value: "Healthy"))
        case .infected:
            viewModels.append(DebugViewModel(title: "Status", value: "Infected"))
        case let .exposed(days: exposureDays):
            viewModels.append(DebugViewModel(title: "Status", value: "Exposed"))

            exposureDays.enumerated().forEach { index, day in
                viewModels.append(DebugViewModel(title: "\(index+1). exposure id",
                                                 value: "\(day.identifier)"))
                viewModels.append(DebugViewModel(title: "\(index+1). exposed date",
                                                 value: "\(dateFormatter.string(from: day.exposedDate))"))
                viewModels.append(DebugViewModel(title: "\(index+1). reported date",
                                                 value: "\(dateFormatter.string(from: day.reportDate))"))
            }
        }

        viewModels.append(DebugViewModel(title: "Background", value: "\(state.backgroundRefreshState.title())"))

        return viewModels
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func shareDatabase() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databasePath = documentsDirectory.appendingPathComponent("DP3T_tracing_db").appendingPathExtension("sqlite")

        let tempDirectory = FileManager.default.temporaryDirectory
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy_HH.mm"
        let dateString = dateFormatter.string(from: Date())
        let tempFilename = "Ketju_db_\(Configuration.pilotId() ?? "unknown")_\(dateString)"
        sharedFileUrl = tempDirectory.appendingPathComponent(tempFilename).appendingPathExtension("sqlite")

        do {
            try FileManager.default.copyItem(at: databasePath, to: sharedFileUrl!)
            if MFMailComposeViewController.canSendMail() {
                openShareSelectionSheet()
            } else {
                openActivityViewController()
            }
        } catch {
            print("Copying database file failed: \(error)")
        }
    }

    private func openShareSelectionSheet() {
        let actionSheet = UIAlertController(title: NSLocalizedString("Share_db_button", comment: ""), message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Share_email", comment: ""), style: .default) { [weak self] _ in
            self?.openMailComposer()
        })

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Share_other", comment: ""), style: .default) { [weak self] _ in
            self?.openActivityViewController()
        })

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel_button", comment: ""), style: .cancel) { [weak self] _ in
            self?.removeSharedFile()
        })

        present(actionSheet, animated: true)
    }

    private func openActivityViewController() {
        let acv = UIActivityViewController(activityItems: [sharedFileUrl!], applicationActivities: nil)
        acv.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, activityError) in
            self?.removeSharedFile()
        }
        present(acv, animated: true)
    }

    private func openMailComposer() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["ketjudev@gmail.com"])

        let subject = sharedFileUrl!.deletingPathExtension().lastPathComponent
        composeVC.setSubject(subject)

        if let url = sharedFileUrl, let file = try? Data(contentsOf: url) {
            composeVC.addAttachmentData(file, mimeType: "application/x-sqlite3", fileName: url.lastPathComponent)
        }

        present(composeVC, animated: true, completion: nil)
    }

    private func removeSharedFile() {
        if let url = sharedFileUrl {
            try? FileManager.default.removeItem(at: url)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "DebugCell")

        let vm = viewModels[indexPath.row]
        cell.textLabel?.text = vm.title
        cell.detailTextLabel?.text = vm.value

        return cell
    }

}

extension DebugViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        removeSharedFile()
        controller.dismiss(animated: true)
    }
}

extension TrackingState {
    func title() -> String {
        switch self {
        case .active:
            return "active"
        case .stopped:
            return "stopped"
        case let .inactive(error: error):
            return "error \(error)"
        case .activeReceiving:
            return "active receiving"
        case .activeAdvertising:
            return "active advertising"
        }
    }
}

extension UIBackgroundRefreshStatus {
    func title() -> String {
        switch self {
        case .available:
            return "available"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        default:
            return "unknown"
        }
    }
}
