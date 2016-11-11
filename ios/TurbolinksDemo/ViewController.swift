import Turbolinks
import UIKit

class DemoViewController: Turbolinks.VisitableViewController {
    lazy var errorView: ErrorView = {
        let view = NSBundle.mainBundle().loadNibNamed("ErrorView", owner: self, options: nil)!.first as! ErrorView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), forControlEvents: .TouchUpInside)
        return view
    }()
    
    override func visitableDidRender() {
        super.visitableDidRender()

        if let path = visitableURL.path {
            switch path {
            case "/":
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign In", style: .Plain, target: self, action: #selector(didSelectRightBarButtonItem(_:)))
            default:
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: #selector(didSelectRightBarButtonItem(_:)))
            }
        }
    }

    func presentError(error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        installErrorViewConstraints()
    }

    func installErrorViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
    }

    func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
    
    func didSelectRightBarButtonItem(sender: AnyObject) {
        
    }
}
