import SwiftUI
import UIKit

/// Reuses a hosting controller while keeping UIKit containment explicit.
public final class HostingTableViewCell<Content: View>: UITableViewCell {
    public static var reuseIdentifier: String { String(reflecting: Self.self) }
    private var hostingController: UIHostingController<Content?>?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public func invalidateHostedSize() {
        hostingController?.view.invalidateIntrinsicContentSize()
        hostingController?.view.setNeedsLayout()
        contentView.setNeedsLayout()
    }

    public func configure(rootView: Content, parent: UIViewController) {
        if #available(iOS 16, *) {
            contentConfiguration = UIHostingConfiguration { rootView }.margins(.all, 0)
        } else {
            configureLegacy(rootView: rootView, parent: parent)
        }
    }

    func configureLegacy(rootView: Content, parent: UIViewController) {
        if let hostingController {
            hostingController.rootView = rootView
            hostingController.view.invalidateIntrinsicContentSize()
        } else {
            hostingController = UIHostingController(rootView: Optional(rootView))
            hostingController?.view.backgroundColor = .clear
        }
        attachHostedController(to: parent)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        clearHostedContent()
    }

    public func clearHostedContent() {
        if #available(iOS 16, *) { contentConfiguration = nil }
        hostingController?.rootView = nil
        detachHostedController()
    }

    public func attachHostedController(to parent: UIViewController) {
        guard let hostingController, hostingController.parent !== parent,
            let hostedView = hostingController.view
        else { return }
        detachHostedController()
        parent.addChild(hostingController)
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostedView)
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        hostingController.didMove(toParent: parent)
    }

    /// Detach offscreen or on teardown; the controller can be reused by configure.
    public func detachHostedController() {
        guard let hostingController, hostingController.parent != nil else { return }
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
    }
}
