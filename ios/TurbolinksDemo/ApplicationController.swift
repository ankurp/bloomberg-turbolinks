import UIKit
import WebKit
import Turbolinks

class ApplicationController: UINavigationController, SessionDelegate, AuthenticationControllerDelegate, WKScriptMessageHandler {
    private let URL = NSURL(string: "http://localhost:9292/")!
    private let webViewProcessPool = WKProcessPool()

    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addScriptMessageHandler(self, name: "bloomberg")
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
    }
    
    private func presentVisitableForSession(session: Session, URL: NSURL, action: Action = .Advance) {
        let visitable = ViewController(URL: URL)

        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewControllerAnimated(false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }
    
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        presentVisitableForSession(session, URL: URL, action: action)
    }
    
    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let viewController = visitable as? ViewController, errorCode = ErrorCode(rawValue: error.code) else { return }

        switch errorCode {
        case .HTTPFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 404:
                viewController.presentError(.HTTPNotFoundError)
            default:
                viewController.presentError(Error(HTTPStatusCode: statusCode))
            }
        case .NetworkFailure:
            viewController.presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(session: Session) {
        application.networkActivityIndicatorVisible = true
    }

    func sessionDidFinishRequest(session: Session) {
        application.networkActivityIndicatorVisible = false
    }
    
    func authenticationControllerDidAuthenticate(authenticationController: AuthenticationController) {
        session.reload()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentAuthenticationController() {
        let authenticationController = AuthenticationController()
        authenticationController.delegate = self
        authenticationController.webViewConfiguration = webViewConfiguration
        authenticationController.URL = NSURL(string: "https://login.bloomberg.com/")!
        authenticationController.title = "Sign in"
        
        let authNavigationController = UINavigationController(rootViewController: authenticationController)
        presentViewController(authNavigationController, animated: true, completion: nil)
    }
    
    func presentSectorsController() {
        let sectorsController = SectorsController()
        sectorsController.delegate = self
        sectorsController.webViewConfiguration = webViewConfiguration
        sectorsController.URL = URL.URLByAppendingPathComponent("markets/sectors")
        sectorsController.title = "Sectors"
        
        let sectorNavigationController = UINavigationController(rootViewController: sectorsController)
        presentViewController(sectorNavigationController, animated: true, completion: nil)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let message = message.body as? String {
            navigationBar.barTintColor = hexStringToUIColor(message)
        }
    }
}


func hexStringToUIColor(hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.grayColor()
    }
    
    var rgbValue:UInt32 = 0
    NSScanner(string: cString).scanHexInt(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
