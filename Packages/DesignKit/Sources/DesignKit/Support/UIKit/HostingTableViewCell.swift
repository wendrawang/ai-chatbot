import SwiftUI
import UIKit

public final class HostingTableViewCell<Content: View>: UITableViewCell {
    public static var reuseIdentifier: String { String(reflecting: Self.self) }

    private var hostingController: UIHostingController<Content>?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// The hosted content can grow without configure being called again.
    public func invalidateHostedSize() {
        hostingController?.view.invalidateIntrinsicContentSize()
        hostingController?.view.setNeedsLayout()
        contentView.setNeedsLayout()
    }

    public func configure(rootView: Content) {
        if let hostingController = hostingController {
            hostingController.rootView = rootView
            hostingController.view.invalidateIntrinsicContentSize()
            return
        }
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        self.hostingController = hostingController
    }
}
