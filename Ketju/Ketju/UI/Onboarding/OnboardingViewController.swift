import CoreBluetooth
import UIKit
import SnapKit

enum OnboardingPhase: Int {
    case introduction
    case bluetooth
    case notifications
}

class OnboardingViewController: UIViewController {

    private let pilotBanner: PilotBanner = PilotBanner()
    private let titleLabel: TitleBigLabel = TitleBigLabel()
    private let button: KetjuButton = KetjuButton()

    private var bluetoothManager: CBCentralManager?

    var phase: OnboardingPhase = .introduction

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ketjuNaturalWhite
        navigationController?.setNavigationBarHidden(true, animated: false)

        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        view.addSubview(pilotBanner)
        view.addSubview(titleLabel)
        view.addSubview(button)

        makeConstraints()

        setTexts()
    }

    private func makeConstraints() {
        pilotBanner.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.centerY.equalToSuperview().offset(-AppAppearance.ButtonHeight)
        }

        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppAppearance.MarginL)
            make.height.greaterThanOrEqualTo(AppAppearance.ButtonHeight)
        }
    }

    private func setTexts() {
        titleLabel.text = NSLocalizedString("Onboarding_title_\(phase.rawValue + 1)", comment: "")

        switch phase {
        case .introduction:
            button.setTitle(NSLocalizedString("Next_button", comment: ""), for: .normal)
            button.setImage(UIImage(named: "right-arrow"), for: .normal)
        case .bluetooth:
            button.setTitle(NSLocalizedString("Next_bluetooth", comment: ""), for: .normal)
            button.setImage(UIImage(named: "bluetooth"), for: .normal)
        case .notifications:
            button.setTitle(NSLocalizedString("Next_notifications", comment: ""), for: .normal)
            button.setImage(UIImage(named: "notification-icon"), for: .normal)
        }
    }

    @objc private func buttonPressed() {
        switch phase {
        case .introduction:
            showNextPhase()
        case .bluetooth:
            requestBluetoothPermission()
        case .notifications:
            requestNotificationPermission()
        }
    }

    private func showNextPhase() {
        if phase.rawValue < OnboardingPhase.notifications.rawValue {
            let nextVC = OnboardingViewController()
            if let nextPhase = OnboardingPhase(rawValue: phase.rawValue + 1) {
                nextVC.phase = nextPhase
                navigationController?.pushViewController(nextVC, animated: true)
            }
        } else {
            Configuration.setHasSeenOnboarding(seen: true)

            // Resetting & re-initialization is needed after onboarding because
            // EphID prefix for Pilot testing is set on initialization.
            ExposureManager.shared.reset()
            ExposureManager.shared.initialize()
            ExposureManager.shared.start()

            dismiss(animated: true, completion: nil)
        }
    }

    private func requestBluetoothPermission() {
        // Request Bluetooth authorization implicitly by creating a central manager object
        // and request also an additional alert in case of Bluetooth is powered off.
        bluetoothManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:1])
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            // Regardless of the user selection to the notification permission request, move forward.
            DispatchQueue.main.async {
                self.showNextPhase()
            }
        })
    }

}

extension OnboardingViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Make sure this is not getting called twice.
        self.bluetoothManager = nil

        // Regardless of the user selection to the Bluetooth permission request, move forward.
        DispatchQueue.main.async {
            self.showNextPhase()
        }
    }

}
