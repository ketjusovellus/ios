import UIKit
import SnapKit

struct ExposureViewModel {
    let dateString: String
    let title: String
}

class ExposuresViewController: UIViewController {

    private let exposedIcon: UIImageView = UIImageView(image: UIImage(named: "error-sign"))
    private let exposedLabel: TitleMediumLabel = TitleMediumLabel()
    private let tableView: UITableView = UITableView()
    private let closeButton: KetjuButton = KetjuButton()
    private let dateFormatter = DateFormatter()
    private var exposureViewModels: [ExposureViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ketjuFullWhite

        dateFormatter.dateFormat = "EE\nd.M."

        let exposures = ExposureManager.shared.exposures
        createViewModels(from: exposures.map { $0.exposedDate })

        title = NSLocalizedString("Exposed_label_found", comment: "")

        exposedIcon.tintColor = UIColor.ketjuBlue
        view.addSubview(exposedIcon)

        exposedLabel.textAlignment = .center
        exposedLabel.textColor = UIColor.ketjuBlue
        exposedLabel.text = NSLocalizedString("Exposed_label_found", comment: "")
        view.addSubview(exposedLabel)

        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(ExposureCell.self, forCellReuseIdentifier: "ExposureCell")
        view.addSubview(tableView)

        closeButton.style = .primaryAction
        closeButton.setTitle(NSLocalizedString("Close_button", comment: ""), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)

        makeConstraints()
    }

    private func makeConstraints() {
        exposedIcon.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(AppAppearance.MarginL)
            make.centerX.equalToSuperview()
        }

        exposedLabel.snp.makeConstraints { make in
            make.top.equalTo(exposedIcon.snp.bottom).offset(AppAppearance.MarginM)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginM)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(exposedLabel.snp.bottom).offset(AppAppearance.MarginL)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.bottom.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.ButtonHeight)
        }
    }

    private func createViewModels(from exposures: [Date]) {
        let groupedData: [Date: Int] = [:]

        let newData = exposures.reduce(into: groupedData) { result, exposedDate in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: exposedDate)
            let date = Calendar.current.date(from: components)!
            let existing = result[date] ?? 0

            result[date] = existing + 1
        }

        exposureViewModels = newData.map { key, value in
            let textKey = value == 1 ? "Exposure_text_one" : "Exposure_text"
            return ExposureViewModel(dateString: dateFormatter.string(from: key),
                                     title: "\(value) " + NSLocalizedString(textKey, comment: ""))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.reloadData()
    }

    @objc private func close() {
        dismiss(animated: true)
    }

}

extension ExposuresViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exposureViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExposureCell") as? ExposureCell

        let viewModel = exposureViewModels[indexPath.row]
        cell?.set(viewModel: viewModel)

        return cell ?? UITableViewCell()
    }

}
