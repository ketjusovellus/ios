import UIKit

class PhoneVerificationViewController: UIViewController {

    private let mainTitleLabel: TitleMediumLabel = TitleMediumLabel()
    private let titleLabel: TitleMediumLabel = TitleMediumLabel()
    private let infoLabel: BodyLabel = BodyLabel()
    private let digitTextFieldStack: UIStackView = UIStackView()
    private let digit1TextField: KetjuTextField = KetjuTextField()
    private let digit2TextField: KetjuTextField = KetjuTextField()
    private let digit3TextField: KetjuTextField = KetjuTextField()
    private let digit4TextField: KetjuTextField = KetjuTextField()
    private let digit5TextField: KetjuTextField = KetjuTextField()
    private let digit6TextField: KetjuTextField = KetjuTextField()
    private let confirmButton: KetjuButton = KetjuButton()
    private let closeButton: UIButton = UIButton(type: .custom)
    private let uploadSpinnerView: UIView = UIView()
    private let uploadSpinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    var phoneNumber: String!

    private var verificationCode: String? {
        if let digit1 = digit1TextField.text,
            let digit2 = digit2TextField.text,
            let digit3 = digit3TextField.text,
            let digit4 = digit4TextField.text,
            let digit5 = digit5TextField.text,
            let digit6 = digit6TextField.text {
            return digit1 + digit2 + digit3 + digit4 + digit5 + digit6
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ketjuFullWhite

        closeButton.setImage(UIImage(named: "down-arrow"), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.contentMode = .scaleAspectFit
        closeButton.tintColor = UIColor.ketjuBlue
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

        mainTitleLabel.text = NSLocalizedString("Upload_title", comment: "")
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.textColor = AppAppearance.TitleTextColor
        titleLabel.text = NSLocalizedString("Phone_verify_pin_title", comment: "")
        infoLabel.text = NSLocalizedString("Phone_verify_pin_subtitle", comment: "")

        digitTextFieldStack.spacing = AppAppearance.MarginS
        digitTextFieldStack.axis = .horizontal
        digitTextFieldStack.alignment = .fill
        digitTextFieldStack.distribution = .fillEqually

        view.addSubview(mainTitleLabel)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(infoLabel)
        view.addSubview(digitTextFieldStack)
        view.addSubview(confirmButton)

        uploadSpinnerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        uploadSpinner.color = UIColor.ketjuBlue
        uploadSpinnerView.addSubview(uploadSpinner)
        view.addSubview(uploadSpinnerView)
        uploadSpinnerView.isHidden = true

        addDigitTextField(textField: digit1TextField)
        addDigitTextField(textField: digit2TextField)
        addDigitTextField(textField: digit3TextField)
        addDigitTextField(textField: digit4TextField)
        addDigitTextField(textField: digit5TextField)
        addDigitTextField(textField: digit6TextField)

        confirmButton.isEnabled = false
        confirmButton.style = .primaryAction
        confirmButton.setTitle(NSLocalizedString("Confirm_upload_title", comment: ""), for: .normal)
        confirmButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        view.addGestureRecognizer(tap)

        makeConstraints()
    }

    private func addDigitTextField(textField: KetjuTextField) {
        textField.delegate = self
        textField.textAlignment = .center
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(digitEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(digitEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(digitEditingDidEnd), for: .editingDidEnd)

        digitTextFieldStack.addArrangedSubview(textField)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if digit1TextField.text?.isEmpty == true {
            digit1TextField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func makeConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(AppAppearance.MarginM)
            make.height.width.equalTo(40.0)
        }

        mainTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(AppAppearance.MarginM)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(AppAppearance.MarginL)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
        }

        infoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.top.equalTo(titleLabel.snp.bottom).offset(AppAppearance.MarginM)
        }

        digitTextFieldStack.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(AppAppearance.MarginL)
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.TextFieldHeight)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppAppearance.MarginL)
            make.height.equalTo(AppAppearance.ButtonHeight)
            make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
        }

        uploadSpinnerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        uploadSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
        closeKeyboard()
    }

    @objc private func digitEditingDidBegin(_ sender: KetjuTextField) {
        sender.text = nil
    }

    @objc private func digitEditingChanged(_ sender: KetjuTextField) {
        if sender == digit1TextField && digit1TextField.text?.count == 1 {
            digit2TextField.becomeFirstResponder()
        } else if sender == digit2TextField && digit2TextField.text?.count == 1 {
            digit3TextField.becomeFirstResponder()
        } else if sender == digit3TextField && digit3TextField.text?.count == 1 {
            digit4TextField.becomeFirstResponder()
        } else if sender == digit4TextField && digit4TextField.text?.count == 1 {
            digit5TextField.becomeFirstResponder()
        } else if sender == digit5TextField && digit5TextField.text?.count == 1 {
            digit6TextField.becomeFirstResponder()
        } else if sender == digit6TextField && digit6TextField.text?.count == 1 {
            digit6TextField.resignFirstResponder()
        }
    }

    @objc private func digitEditingDidEnd(_ sender: KetjuTextField) {
        sender.isCompleted = sender.text?.count == 1
        validateCode()
    }

    @objc private func continueButtonTapped(_ sender: KetjuButton) {

        guard let phone = phoneNumber?.replacingOccurrences(of: " ", with: "") else {
            print("Phone number is missing")
            return
        }

        guard let code = verificationCode, let day = Int(code.suffix(2)) else {
            print("Code was not given completely")
            return
        }

        uploadSpinnerView.isHidden = false
        uploadSpinner.startAnimating()

        // Need to use UTC timezone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // Code gives us the day as the last 2 digits. We need to find this day's exact date from the past.
        // Can be today so we start from tomorrow.
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let onsetDate = calendar.nextDate(after: tomorrow,
                                          matching: DateComponents(day: day),
                                          matchingPolicy: .strict,
                                          direction: .backward)

        guard onsetDate != nil else {
            print("Something wrong with the date generation")
            return
        }

        let authString = "\(phone)//\(code)"

        ExposureManager.shared.uploadDiagnosisKey(onsetDate: onsetDate!, authString: authString) { [weak self] errorMsg in

            self?.uploadSpinner.stopAnimating()

            guard errorMsg == nil else {
                self?.showAlert(message: errorMsg!)
                return
            }

            self?.close()
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Upload_error_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
            self?.close()
        }))

        present(alert, animated: true)
    }

    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            confirmButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL + keyboardFrame.height)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            confirmButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(AppAppearance.MarginL)
            }

            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    private func validateCode() {
        if let code = verificationCode, code.count == 6, let day = Int(code.suffix(2)), day <= 31 && day > 0 {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }

    private func closeKeyboard() {
        digit1TextField.resignFirstResponder()
        digit2TextField.resignFirstResponder()
        digit3TextField.resignFirstResponder()
        digit4TextField.resignFirstResponder()
        digit5TextField.resignFirstResponder()
        digit6TextField.resignFirstResponder()
    }

}

extension PhoneVerificationViewController: KetjuTextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Special case, if pasting complete verification code into the first text field.
        if textField == digit1TextField && string.count == 6 && string.allSatisfy({ $0.isNumber }) {
            let digits = Array(string)
            digit1TextField.text = String(digits[0])
            digit2TextField.text = String(digits[1])
            digit3TextField.text = String(digits[2])
            digit4TextField.text = String(digits[3])
            digit5TextField.text = String(digits[4])
            digit6TextField.text = String(digits[5])
            closeKeyboard()
            validateCode()

            return false
        }

        // Allow only one digit input in the text field.
        return string.count == 0 || (string.count == 1 && string.first!.isNumber)
    }

    func textFieldDidReceiveBackspace(_ textfField: KetjuTextField) {
        if textfField == digit2TextField {
            digit1TextField.becomeFirstResponder()
        } else if textfField == digit3TextField {
            digit2TextField.becomeFirstResponder()
        } else if textfField == digit4TextField {
            digit3TextField.becomeFirstResponder()
        } else if textfField == digit5TextField {
            digit4TextField.becomeFirstResponder()
        } else if textfField == digit6TextField {
            digit5TextField.becomeFirstResponder()
        }
    }

}
