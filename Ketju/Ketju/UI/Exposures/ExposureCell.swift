import UIKit

class ExposureCell: UITableViewCell {

    private let dateLabel: TitleSmallLabel = TitleSmallLabel()
    private let descriptionLabel: TitleSmallLabel = TitleSmallLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    private func configure() {

        dateLabel.textColor = UIColor.ketjuBlue

        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)

        makeConstraints()
    }

    private func makeConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(AppAppearance.MarginM)
            make.width.greaterThanOrEqualTo(50.0)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(AppAppearance.MarginM)
            make.trailing.equalToSuperview().inset(AppAppearance.MarginM)
            make.centerY.equalToSuperview()
        }
    }

    func set(viewModel: ExposureViewModel) {
        dateLabel.text = viewModel.dateString.capitalized
        descriptionLabel.text = viewModel.title
    }
    
}
