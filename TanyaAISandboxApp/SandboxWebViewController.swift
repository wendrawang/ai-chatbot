//
//  SandboxWebViewController.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 19/10/26.
//

import UIKit
import WebKit

/// Contoh webview host untuk link web dari jawaban (bukan Safari).
/// Nav bar bawaan menampilkan judul domain; disembunyikan lagi saat halaman ditutup.
final class SandboxWebViewController: UIViewController {
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        title = url.host
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        view = webView
    }

    // Nama parameter `animated` wajib dari UIKit.
    // swiftlint:disable:next boolean_prefix
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // swiftlint:disable:next boolean_prefix
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
