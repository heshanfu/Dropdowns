import UIKit

public typealias AnimationBlock = (Bool) -> Void

public class DropdownController: UIViewController {

  public var animationBlock: AnimationBlock?
  public private(set) var contentController: UIViewController?

  weak var containerView: UIView?
  lazy var backgroundView: UIView = self.makeBackgroundView()
  lazy var topLine: CALayer = self.makeTopLine()

  var offsetY: CGFloat = 0
  var showing: Bool = false
  var animating: Bool = false
  let padding: CGFloat = 20

  // MARK: - Initialization

  public convenience init?(contentController: UIViewController, navigationController: UINavigationController) {
    guard let containerView = navigationController.tabBarController?.view ?? navigationController.view
      else { return nil }

    let offsetY = navigationController.navigationBar.frame.maxY

    self.init(contentController: contentController, containerView: containerView, offsetY: offsetY)
  }

  public required init(contentController: UIViewController, containerView: UIView, offsetY: CGFloat) {
    self.containerView = containerView
    self.offsetY = offsetY

    super.init(nibName: nil, bundle: nil)

    view.addSubview(backgroundView)
    view.layer.addSublayer(topLine)
    view.clipsToBounds = true

    self.contentController = contentController
    addChildViewController(contentController)
    view.addSubview(contentController.view)
    contentController.didMoveToParentViewController(self)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    topLine.frame = CGRect(x: 0, y: 0,
                           width: view.bounds.size.width, height: 1)
    backgroundView.frame = view.bounds
  }

  // MARK: - View

  func makeBackgroundView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    view.alpha = 0

    let gr = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:)))
    view.addGestureRecognizer(gr)

    return view
  }

  func makeTopLine() -> CALayer {
    let layer = CALayer()
    layer.backgroundColor = Config.topLineColor.CGColor

    return layer
  }

  // MARK: - Action

  func backgroundViewTapped(gesture: UITapGestureRecognizer) {
    hide()
  }

  // MARK: - Showing

  public func toggle() {
    toggle(!showing)
  }

  public func show() {
    toggle(true)
  }

  public func hide() {
    toggle(false)
  }

  func toggle(showing: Bool) {
    guard let containerView = containerView,
      contentController = contentController
      else { return }

    guard !animating else { return }

    animating = true
    self.showing = showing

    view.frame = CGRect(x: 0,
                        y: offsetY,
                        width: containerView.frame.size.width,
                        height: containerView.frame.size.height - offsetY)
    contentController.view.frame = view.bounds

    if showing {
      containerView.addSubview(view)
      backgroundView.alpha = 0
      contentController.view.frame.origin.y -= contentController.view.frame.height + padding
    } else {
      backgroundView.alpha = 0.5
    }

    UIView.animateWithDuration(0.5, delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0.5,
                               options: [],
                               animations:
      {
        self.animationBlock?(showing)

        if showing {
          self.backgroundView.alpha = 0.5
          self.topLine.opacity = 1
          contentController.view.frame.origin.y = 1
        } else {
          contentController.view.frame.origin.y -= contentController.view.frame.height + self.padding
          self.backgroundView.alpha = 0
          self.topLine.opacity = 0
        }

      }, completion: { (finished) in
        if !showing {
          self.view.removeFromSuperview()
        }

        self.animating = false
    })
  }
}
