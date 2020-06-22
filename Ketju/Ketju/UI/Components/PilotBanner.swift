import UIKit
import SnapKit

@IBDesignable
class PilotBanner: UIView {

    private let titleLabel: TitleTinyLabel = TitleTinyLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    private func configure() {
        titleLabel.text = NSLocalizedString("Pilot_banner_text", comment: "")
        titleLabel.textAlignment = .center

        backgroundColor = UIColor.ketjuPink

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(AppAppearance.BannerHeight)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
