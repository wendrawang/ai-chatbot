//
//  RichTextView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import UIKit

/// Self-sizes without a second vertical scroller. Link routing stays with the host.
final class RichTextView: UITextView
{
    var onLink: ((URL) -> Void)?
    override init(frame: CGRect, textContainer: NSTextContainer?)
    {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
        backgroundColor = .clear
        textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) is unavailable")
    }
}

extension RichTextView: UITextViewDelegate
{
    func textView(
        _: UITextView,
        shouldInteractWith URL: URL,
        in _: NSRange,
        interaction _: UITextItemInteraction) -> Bool
    {
        onLink?(URL)
        return false
    }
}

struct RenderCacheKey: Hashable
{
    let messageID: String
    let revision: Int
    let locale: String
    let font: String
    let size: CGFloat
}

final class RichTextCache
{
    private var entries: [RenderCacheKey: NSAttributedString] = [:]
    func value(
        messageID: String,
        revision: Int,
        source: String,
        isFinal: Bool,
        locale: Locale,
        font: UIFont) -> NSAttributedString
    {
        let key = RenderCacheKey(
            messageID: messageID,
            revision: revision,
            locale: locale.identifier,
            font: font.fontName,
            size: font.pointSize)
        guard let cached = entries[key]
        else
        {
            let runs = RichTextParser.parse(source, isFinal: isFinal)
            let result = RichTextRenderer(font: font, locale: locale).render(runs)
            entries = entries.filter
            {
                $0.key.messageID != messageID
            }

            entries[key] = result
            return result
        }

        return cached
    }
}
