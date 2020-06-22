import UIKit

protocol HomeStatusViewDelegate: class {
    func settingsTapped()
}

class HomeStatusView: UIView {

    weak var delegate: HomeStatusViewDelegate?

    var status: HomeStatus = .active {
        didSet {
            updateView()
        }
    }

    private let icon: UIImageView = UIImageView()
    private let titleLabel: TitleBigLabel = TitleBigLabel()
    private let descriptionLabel: BodyLabel = BodyLabel()
    private let appSettingsButton: KetjuButton = KetjuButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    private func configure() {
        appSettingsButton.style = .secondaryInfo
        appSettingsButton.contentHorizontalAlignment = .center
        appSettingsButton.setTitle(NSLocalizedString("Home_app_settings_button", comment: ""), for: .normal)
        appSettingsButton.addTarget(self, action: #selector(appSettingsButtonTapped), for: .touchUpInside)
        appSettingsButton.isHidden = true

        icon.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center

        addSubview(icon)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(appSettingsButton)

        makeConstraints()

        updateView()
    }

    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginM)
        }

        icon.snp.makeConstraints { make in
            make.width.height.equalTo(AppAppearance.HomeIconWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).inset(AppAppearance.MarginS)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppAppearance.MarginS)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }

        appSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(AppAppearance.MarginS)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }
    }

    private func updateView() {

        appSettingsButton.isHidden = status != .bluetoothDenied

        switch status {
        case .active, .exposed:
            icon.image = UIImage(named: "checkmark")
            titleLabel.text = NSLocalizedString("Home_title_active", comment: "")
            descriptionLabel.text = NSLocalizedString("Home_description_active", comment: "")

        case .bluetoothDenied:
            icon.image = UIImage(named: "warning")
            titleLabel.text = NSLocalizedString("Home_title_bluetooth_denied", comment: "")
            descriptionLabel.text = NSLocalizedString("Home_description_bluetooth_denied", comment: "")

        case .bluetoothOff:
            icon.image = UIImage(named: "warning")
            titleLabel.text = NSLocalizedString("Home_title_bluetooth_off", comment: "")
            descriptionLabel.text = NSLocalizedString("Home_description_bluetooth_off", comment: "")

        case .diagnosisKeyUploaded:
            icon.image = UIImage(named: "checkmark")
            titleLabel.text = NSLocalizedString("Home_title_uploaded", comment: "")
            descriptionLabel.text = NSLocalizedString("Home_description_uploaded", comment: "")

        case .error:
            break
        }
    }

    @objc private func appSettingsButtonTapped() {
        delegate?.settingsTapped()
    }

}
