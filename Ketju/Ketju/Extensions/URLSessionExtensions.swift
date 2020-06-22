import Foundation
import Security

extension URLSession {
    static let evaluator = CertificateEvaluator()

    static let certificatePinned: URLSession = {
        let session = URLSession(configuration: .default,
                                 delegate: URLSession.evaluator,
                                 delegateQueue: nil)
        return session
    }()
}

class CertificateEvaluator: NSObject, URLSessionDelegate {

    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let leafCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {

            print("Server trust is missing and/or certificate could not be created")
            completionHandler(.cancelAuthenticationChallenge, nil)

            return
        }

        // Set ssl policies for domain name check
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust, policies)

        // Evaluate server certificate
        var result = SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(serverTrust, &result)
        let isServerTrusted = result == .unspecified || result == .proceed

        // Get Local and Remote certificate Data

        let remoteCertificateData: NSData = SecCertificateCopyData(leafCertificate)
        let certUrl = URL(fileURLWithPath: Configuration.certificateFileName()!)
        if let pathToCertificate = Bundle.main.url(forResource: certUrl.deletingPathExtension().lastPathComponent, withExtension: certUrl.pathExtension),
            let localCertificateData: NSData = NSData(contentsOf: pathToCertificate) {

            // Compare certificates
            if isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)

                return // Success
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }

}
