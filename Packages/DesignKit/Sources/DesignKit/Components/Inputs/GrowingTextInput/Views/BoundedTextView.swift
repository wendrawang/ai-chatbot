//
//  BoundedTextView.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import UIKit

/// Editor satu sampai empat baris; isi yang lebih panjang di-scroll di dalam field. Saat kosong setinggi placeholder
/// (paling banyak dua baris), jadi seluruh area placeholder bisa diketuk. Perubahan lebar diukur otomatis. Pemilik
/// memanggil `remeasure()` setelah mengubah teks, style atau placeholder (`GrowingTextInput` sudah melakukannya),
/// tanpa override `text: String!`.
@MainActor
public final class BoundedTextView: UITextView {
    var lineSpacing: CGFloat = .zero
    /// Hanya untuk mengukur tinggi saat kosong; teks placeholder digambar pemilik.
    var placeholder = String()
    private var measuredHeight: CGFloat = .zero
    private var measuredWidth: CGFloat = .zero

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(measuredHeight, lineHeight))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Scroll internal juga memicu layoutSubviews; ukur ulang hanya ketika lebar berubah.
        guard bounds.width != measuredWidth else { return }
        measuredWidth = bounds.width
        remeasure()
    }

    /// Ukur seluruh teks sekali per perubahan teks, style atau lebar, bukan per frame scroll.
    func remeasure() {
        guard bounds.width > .zero else { return }
        let fitted = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
        let maximumHeight = height(lines: CustomTextLines.composerInput.upperBound)
        let nextHeight = min(max(ceil(fitted), ceil(lineHeight), placeholderHeight), maximumHeight)
        let isScrolling = fitted > maximumHeight + LayoutTolerance.measurement
        if isScrollEnabled != isScrolling { isScrollEnabled = isScrolling }
        if abs(nextHeight - measuredHeight) > LayoutTolerance.measurement {
            measuredHeight = nextHeight
            invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - Helpers

private extension BoundedTextView {
    var lineHeight: CGFloat {
        font?.lineHeight ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
    }

    /// Tinggi placeholder dengan atribut ketikan yang sama; nol bila sudah ada teks.
    var placeholderHeight: CGFloat {
        guard !hasText, !placeholder.isEmpty else { return .zero }
        let bounding = NSAttributedString(string: placeholder, attributes: typingAttributes).boundingRect(
            with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return min(ceil(bounding.height), height(lines: CustomTextLines.composerPlaceholder))
    }

    /// Jarak antarbaris hanya di antara baris, jadi satu lebih sedikit dari jumlah baris.
    func height(lines: Int) -> CGFloat {
        let gaps = lines - CustomTextLines.composerInput.lowerBound
        return ceil(lineHeight * CGFloat(lines) + lineSpacing * CGFloat(gaps))
    }
}
