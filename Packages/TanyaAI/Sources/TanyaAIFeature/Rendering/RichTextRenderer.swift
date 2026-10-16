//
//  RichTextRenderer.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import UIKit

struct RichTextRenderer
{
    let font: UIFont
    let locale: Locale
    func render(_ runs: [RichTextRun]) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        for run in runs
        {
            result.append(fragment(run))
        }

        applyListIndent(to: result)
        return result
    }

    private func fragment(_ run: RichTextRun) -> NSAttributedString
    {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: run.style.isBold ? boldFont : font, .foregroundColor: UIColor(CustomColors.text),
        ]
        if run.style.isStruckThrough
        {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }

        if let color = run.style.color
        {
            attributes[.foregroundColor] = resolvedColor(color)
        }

        if let link = run.style.link
        {
            attributes[.link] = link
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return NSAttributedString(string: run.text, attributes: attributes)
    }

    private var boldFont: UIFont
    {
        guard let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        else
        {
            return font
        }

        return UIFont(descriptor: descriptor, size: font.pointSize)
    }

    private func resolvedColor(_ value: String) -> UIColor
    {
        switch value
        {
        case "success":
            return UIColor(CustomColors.success)
        case "accent", "error":
            return UIColor(CustomColors.accent)
        default:
            guard value.count == 6, let hex = UInt32(value, radix: 16)
            else
            {
                return UIColor(CustomColors.text)
            }

            return UIColor(
                red: CGFloat((hex >> 16) & 255) / 255,
                green: CGFloat((hex >> 8) & 255) / 255,
                blue: CGFloat(hex & 255) / 255,
                alpha: 1)
        }
    }

    private func applyListIndent(to value: NSMutableAttributedString)
    {
        let source = value.string as NSString
        source.enumerateSubstrings(in: NSRange(location: 0, length: source.length), options: .byParagraphs)
        {
            paragraph, range, _, _ in
            guard let paragraph, let marker = paragraph.range(
                of: #"^\s*(?:[•\-]|[0-9]{1,3}[.)])\s+"#,
                options: .regularExpression)
            else
            {
                return
            }

            let style = NSMutableParagraphStyle()
            let prefix = String(paragraph[marker])
            style.headIndent = (prefix as NSString).size(withAttributes: [.font: font]).width
            value.addAttribute(.paragraphStyle, value: style, range: range)
        }
    }
}
