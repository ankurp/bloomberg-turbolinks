import Turbolinks
import UIKit

class ViewController: Turbolinks.VisitableViewController {
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
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign In", style: .Plain, target: self, action: #selector(didSelectSignInButtonItem(_:)))
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sectors", style: .Plain, target: self, action: #selector(didSelectSectorsButtonItem(_:)))
                title = "Bloomberg"
            default:
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: #selector(didSelectBookmarkButtonItem(_:)))
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
    
    func didSelectBookmarkButtonItem(sender: AnyObject) {
        let alertController = UIAlertController(title: "Bookmarked", message: "This article is saved for future reading", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didSelectSignInButtonItem(sender: AnyObject) {
        guard let appController = self.navigationController as? ApplicationController else { return }

        appController.presentAuthenticationController()
    }
    
    func didSelectSectorsButtonItem(sender: AnyObject) {
        guard let appController = self.navigationController as? ApplicationController else { return }

        appController.presentSectorsController()
    }
}
