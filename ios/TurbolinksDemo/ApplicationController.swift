import UIKit
import WebKit
import Turbolinks

class ApplicationController: UINavigationController, SessionDelegate {
    private let URL = NSURL(string: "http://localhost:9292/")!
    private let webViewProcessPool = WKProcessPool()

    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = self.webViewProcessPool
        configuration.applicationNameForUserAgent = "Bloomberg"
        return configuration
    }()

    private lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presentVisitableForSession(session, URL: URL)

        let rightButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(didSelectRightBarButtonItem))
        self.navigationController?.navigationItem.rightBarButtonItem = rightButton
        navigationController

    }
    
    private func presentVisitableForSession(session: Session, URL: NSURL, action: Action = .Advance) {
        let visitable = DemoViewController(URL: URL)

        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewControllerAnimated(false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }
    
    @objc private func didSelectRightBarButtonItem() {
        
    }

    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        presentVisitableForSession(session, URL: URL, action: action)
    }
    
    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let demoViewController = visitable as? DemoViewController, errorCode = ErrorCode(rawValue: error.code) else { return }

        switch errorCode {
        case .HTTPFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 404:
                demoViewController.presentError(.HTTPNotFoundError)
            default:
                demoViewController.presentError(Error(HTTPStatusCode: statusCode))
            }
        case .NetworkFailure:
            demoViewController.presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(session: Session) {
        application.networkActivityIndicatorVisible = true
    }

    func sessionDidFinishRequest(session: Session) {
        application.networkActivityIndicatorVisible = false
    }
}
