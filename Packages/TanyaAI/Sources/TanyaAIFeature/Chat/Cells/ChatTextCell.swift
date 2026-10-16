//
//  ChatTextCell.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import UIKit

final class ChatTextCell: UITableViewCell
{
    static let reuseIdentifier = "ChatTextCell"
    let textView: RichTextView
    private var leading: NSLayoutConstraint?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        textView = RichTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let inset = textView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: FigmaSize.spacingLarge)
        leading = inset
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([inset,
                                     textView.trailingAnchor.constraint(
                                         equalTo: contentView.trailingAnchor,
                                         constant: -FigmaSize.spacingLarge),
                                     textView.topAnchor.constraint(
                                         equalTo: contentView.topAnchor,
                                         constant: FigmaSize.spacingMedium),
                                     textView.bottomAnchor.constraint(
                                         equalTo: contentView.bottomAnchor,
                                         constant: -FigmaSize.spacingMedium)])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) is unavailable")
    }

    func configure(_ value: NSAttributedString, isUser: Bool, onLink: @escaping (URL) -> Void)
    {
        textView.attributedText = value
        textView.onLink = onLink
        textView.backgroundColor = isUser ? UIColor(CustomColors.accent) : .clear
        textView.layer.cornerRadius = CustomSizes.radius
        textView.textContainerInset = isUser ? UIEdgeInsets(
            top: FigmaSize.spacingMedium,
            left: FigmaSize.spacingLarge,
            bottom: FigmaSize.spacingMedium,
            right: FigmaSize.spacingLarge) : .zero
        leading?.constant = isUser ? CustomSizes.promptPreview : FigmaSize.spacingLarge
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        textView.attributedText = nil
        textView.onLink = nil
    }
}
