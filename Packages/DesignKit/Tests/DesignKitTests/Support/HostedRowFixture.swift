//
//  HostedRowFixture.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI
import UIKit

@testable import DesignKit

/// Table sungguhan pada window, karena tinggi baris baru diputuskan saat table mengukur selnya.
@MainActor
final class HostedRowFixture: NSObject, UITableViewDataSource {
    private typealias Cell = HostingTableViewCell<AnyView>
    private let contentHeight: CGFloat
    private let isLegacy: Bool
    private let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    private let parent = UIViewController()
    private let table = UITableView(frame: .zero, style: .plain)

    init(contentHeight: CGFloat, isLegacy: Bool) {
        self.contentHeight = contentHeight
        self.isLegacy = isLegacy
        super.init()
        table.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        table.dataSource = self
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        parent.view = table
        window.rootViewController = parent
        window.isHidden = false
        window.layoutIfNeeded()
    }

    var rowHeight: CGFloat {
        table.layoutIfNeeded()
        return table.rectForRow(at: IndexPath(row: .zero, section: .zero)).height
    }

    func close() {
        window.isHidden = true
        window.rootViewController = nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath)
        let rootView = AnyView(Color.clear.frame(height: contentHeight))
        guard let hostedCell = cell as? Cell else { return cell }
        guard isLegacy else {
            hostedCell.configure(rootView: rootView, parent: parent)
            return cell
        }
        hostedCell.configureLegacy(rootView: rootView, parent: parent)
        return cell
    }
}
