import UIKit
import SnapKit

class CodeInputViewController: UIViewController {

    private let pilotBanner: PilotBanner = PilotBanner()
    private let titleLabel: TitleMediumLabel = TitleMediumLabel()
    private let codeTextField: KetjuTextField = KetjuTextField()
    private let nextButton: KetjuButton = KetjuButton()

    private var code: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ketjuNaturalWhite
        navigationController?.setNavigationBarHidden(true, animated: false)

        codeTextField.delegate = self
        codeTextField.placeholder = "ID"
        codeTextField.keyboardType = .alphabet
        codeTextField.autocapitalizationType = .none
        codeTextField.autocorrectionType = .no
        codeTextField.clearButtonMode = .always
        codeTextField.addTarget(self, action: #selector(codeEditingChanged), for: .editingChanged)

        titleLabel.text = NSLocalizedString("Code_input_title", comment: "")

        nextButton.isEnabled = false
        nextButton.style = .primaryAction
        nextButton.setImage(UIImage(named: "right-arrow"), for: .normal)
        nextButton.setTitle(NSLocalizedString("Next_button", comment: ""), for: .normal)
        nextButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        view.addGestureRecognizer(tap)

        view.addSubview(pilotBanner)
        view.addSubview(titleLabel)
        view.addSubview(codeTextField)
        view.addSubview(nextButton)

        makeConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        codeTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func makeConstraints() {
        pilotBanner.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(pilotBanner.snp.bottom).offset(AppAppearance.MarginL * 2)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }

        codeTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppAppearance.MarginM)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.TextFieldHeight)
        }

        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.ButtonHeight)
            make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
        }
    }

    @objc private func codeEditingChanged(_ sender: KetjuTextField) {
        validateCode()
    }

    @objc private func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
        codeTextField.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            nextButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL + keyboardFrame.height)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            nextButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    private func validateCode() {
        code = codeTextField.text

        let isValid = code?.count == 4
        codeTextField.isCompleted = isValid
        nextButton.isEnabled = isValid
    }

    // MARK: - Navigation

    @objc private func confirmTapped(_ sender: KetjuButton) {

        guard let code = code else {
            return
        }

        Configuration.setPilotId(code)

        let vc = OnboardingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }
    
}

extension CodeInputViewController: KetjuTextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.allSatisfy({ !$0.isWhitespace })
    }

}
