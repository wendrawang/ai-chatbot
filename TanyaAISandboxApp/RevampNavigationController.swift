//
//  RevampNavigationController.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 18/10/26.
//

import UIKit

/// Contoh jalur navigasi bersih milik host untuk halaman revamp (Tanya AI dan seterusnya).
/// Main legacy tetap menjadi root beserta navigasi lamanya; halaman revamp di-push di sini.
/// Nav bar disembunyikan karena tiap halaman menggambar header 1:1 Figma sendiri.
final class RevampNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        // Menyembunyikan nav bar mematikan swipe-back bawaan; delegate ini mengaktifkannya lagi.
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Swipe-back hanya saat ada halaman untuk kembali dan tidak sedang transisi.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        topViewController !== viewControllers.first && transitionCoordinator == nil
    }
}
