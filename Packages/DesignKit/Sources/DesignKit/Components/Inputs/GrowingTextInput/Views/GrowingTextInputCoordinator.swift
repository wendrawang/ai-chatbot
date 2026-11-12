//
//  GrowingTextInputCoordinator.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import UIKit

/// Delegate editor milik `GrowingTextInput`: meneruskan ketikan ke draft pemakai dan mengukur ulang tinggi.
/// Class karena `UITextViewDelegate` mewajibkannya.
@MainActor
public final class GrowingTextInputCoordinator: NSObject, UITextViewDelegate {
    var parent: GrowingTextInput

    init(parent: GrowingTextInput) { self.parent = parent }

    public func textViewDidChange(_ editor: UITextView) {
        // UITextView.text bertipe String!; baca sebagai optional agar tidak ada unwrap paksa.
        parent.updateDraft(editor.text ?? String())
        (editor as? BoundedTextView)?.remeasure()
    }
}
