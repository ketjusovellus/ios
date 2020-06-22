import UIKit
import SnapKit
import Lottie

enum HomeStatus {
    case active
    case bluetoothDenied
    case bluetoothOff
    case diagnosisKeyUploaded
    case error
    case exposed
}

class HomeViewController: UIViewController {

    private let pilotBanner: PilotBanner = PilotBanner()
    private let backgroundView: KetjuBackgroundView = KetjuBackgroundView()
    private let animationView: AnimationView = AnimationView()
    private let statusView: HomeStatusView = HomeStatusView()
    private let bottomPanel: UIView = UIView()
    private let uploadButton: KetjuButton = KetjuButton()
    private let debugButton: KetjuButton = KetjuButton()
    private let exposedIcon: UIImageView = UIImageView(image: UIImage(named: "error-sign"))
    private let exposedLabel: TitleSmallLabel = TitleSmallLabel()
    private let exposedButton: KetjuButton = KetjuButton()

    private var status: HomeStatus = .active {
        didSet {
            if oldValue != status {
                updateView()
            }
        }
    }

    private var isItTimeToKillYet: Bool {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 6
        dateComponents.day = 26
        let endOfJune = Calendar.current.date(from: dateComponents)?.timeIntervalSinceReferenceDate ?? 0
        let now = Date().timeIntervalSinceReferenceDate

        return now > endOfJune
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        statusView.delegate = self

        uploadButton.style = .upload
        uploadButton.setTitle(NSLocalizedString("Upload_button_title", comment: ""), for: .normal)
        uploadButton.addTarget(self, action: #selector(bottomButtonTapped), for: .touchUpInside)

        debugButton.style = .primaryInfo
        debugButton.setTitle("Debug", for: .normal)
        debugButton.addTarget(self, action: #selector(debugButtonTapped), for: .touchUpInside)

        exposedIcon.tintColor = UIColor.ketjuBlue
        exposedButton.style = .primaryAction
        exposedButton.setTitle(NSLocalizedString("Exposed_button", comment: ""), for: .normal)
        exposedButton.addTarget(self, action: #selector(exposedButtonTapped), for: .touchUpInside)

        exposedLabel.textAlignment = .center
        exposedLabel.textColor = UIColor.ketjuBlue
        
        exposedIcon.isHidden = true
        exposedButton.isHidden = true

        bottomPanel.backgroundColor = UIColor.ketjuFullWhite
        bottomPanel.layer.shadowColor = AppAppearance.ShadowColor
        bottomPanel.layer.shadowOpacity = 0.1
        bottomPanel.layer.shadowRadius = 10.0
        bottomPanel.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        bottomPanel.layer.cornerRadius = AppAppearance.CardCornerRadius
        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.addSubview(backgroundView)
        view.addSubview(animationView)
        view.addSubview(statusView)
        view.addSubview(bottomPanel)
        view.addSubview(uploadButton)
        view.addSubview(debugButton)
        view.addSubview(exposedIcon)
        view.addSubview(exposedLabel)
        view.addSubview(exposedButton)
        view.addSubview(pilotBanner)

        animationView.animation = Animation.named("homeview")
        animationView.contentMode = .scaleAspectFill
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = .loop

        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: stateChangedNotification, object: nil)

        makeConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isItTimeToKillYet {
            ExposureManager.shared.reset()
            showFinalMessage()
            return
        }

        if Configuration.hasSeenOnboarding() == false {
            let vc = CodeInputViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen

            present(nav, animated: false)
        }

        updateView()
    }

    private func makeConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        statusView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(animationView.snp.centerY).offset(-60)
        }

        uploadButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.greaterThanOrEqualTo(AppAppearance.ButtonHeight)
        }

        pilotBanner.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        debugButton.snp.makeConstraints { make in
            make.top.equalTo(pilotBanner.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppAppearance.MarginM)
            make.height.equalTo(AppAppearance.ButtonHeightS)
        }

        bottomPanel.snp.makeConstraints { make in
            make.top.equalTo(uploadButton)
            make.leading.trailing.bottom.equalToSuperview()
        }

        exposedButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomPanel.snp.top).offset(-AppAppearance.MarginM)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.ButtonHeight)
        }

        exposedLabel.snp.makeConstraints { make in
            make.bottom.equalTo(exposedButton.snp.top).offset(-AppAppearance.MarginM)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }

        exposedIcon.snp.makeConstraints { make in
            make.bottom.equalTo(exposedLabel.snp.top).offset(-AppAppearance.MarginS)
            make.centerX.equalToSuperview()
        }
    }

    private func showFinalMessage() {
        let alert = UIAlertController(title: NSLocalizedString("Final_title", comment: ""),
                                      message: NSLocalizedString("Final_message", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { _ in
            exit(0)
        })

        present(alert, animated: true)
    }

    @objc private func bottomButtonTapped() {
        let nav = UINavigationController(rootViewController: PhoneNumberViewController())
        nav.setNavigationBarHidden(true, animated: false)

        present(nav, animated: true)
    }

    @objc private func debugButtonTapped() {
        let vc = DebugViewController()
        let nav = UINavigationController(rootViewController: vc)

        present(nav, animated: true)
    }

    @objc private func exposedButtonTapped() {
        guard ExposureManager.shared.exposures.count > 0 else {
            return
        }

        let vc = ExposuresViewController()
        present(vc, animated: true)
    }

    @objc private func updateView() {

        let latestStatus = ExposureManager.shared.status
        statusView.status = latestStatus

        switch latestStatus {
        case .active, .exposed:
            animationView.isHidden = false
            if !animationView.isAnimationPlaying {
                animationView.play()
            }

        case .bluetoothDenied, .bluetoothOff, .diagnosisKeyUploaded:
            animationView.isHidden = true
            animationView.stop()

        case .error:
            break
        }

        updateExposureState()

    }

    private func updateExposureState() {
        let found = ExposureManager.shared.exposures.count > 0

        exposedButton.isHidden = !found
        exposedIcon.isHidden = !found

        if found {
            exposedLabel.text = NSLocalizedString("Exposed_label_found", comment: "")
        } else {
            exposedLabel.text = NSLocalizedString("Exposed_label_none", comment: "")
        }
    }

}

extension HomeViewController: HomeStatusViewDelegate {

    func settingsTapped() {
        if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettingsUrl, options: [:], completionHandler: nil)
        }
    }

}
