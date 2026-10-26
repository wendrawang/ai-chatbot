//
//  GrowingTextInputCoordinator.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI
import UIKit

/// Delegate editor `GrowingTextInput`: menulis ketikan ke binding draft lalu mengukur ulang tinggi.
/// Class karena `UITextViewDelegate` mensyaratkan `NSObject`.
public final class GrowingTextInputCoordinator: NSObject, UITextViewDelegate {
    var text: Binding<String>

    init(text: Binding<String>) {
        self.text = text
    }

    public func textViewDidChange(_ editor: UITextView) {
        // UITextView.text bertipe String!; baca sebagai optional agar tidak ada unwrap paksa.
        text.wrappedValue = editor.text ?? String()
        (editor as? BoundedTextView)?.remeasure()
    }
}
