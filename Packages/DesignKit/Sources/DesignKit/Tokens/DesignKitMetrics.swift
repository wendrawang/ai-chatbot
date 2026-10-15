import CoreGraphics

/// Measurements absent from the generated Figma scale, named by visual role.
/// Existing padding and spacing always use FigmaSize directly.
public enum DesignKitMetrics {
    public enum Spacing {
        public static let snug: CGFloat = 6
        public static let regular: CGFloat = 12
    }

    public enum Radius {
        public static let composer: CGFloat = 8
        public static let bubble: CGFloat = 12
        public static let quickAction: CGFloat = 8
        public static let summary: CGFloat = 8
        public static let media: CGFloat = 8
        public static let action: CGFloat = 24
    }

    public enum Stroke {
        public static let divider: CGFloat = 0.5
        public static let hairline: CGFloat = FigmaSize.weightOutline
    }

    public enum Size {
        public static let composerAction: CGFloat = 24
        public static let estimatedRowHeight: CGFloat = 96
        public static let icon: CGFloat = 24
        public static let minimumTapTarget: CGFloat = 44
        public static let indicator: CGFloat = 20
        public static let bubbleMaximumWidth: CGFloat = 310
        public static let emblem: CGFloat = 64
        public static let itemIcon: CGFloat = 36
        public static let actionChevron: CGFloat = 20
    }

    public enum Table {
        public static let maximumColumns = 3
    }

    public enum Media {
        public static let aspectRatio: CGFloat = 1.5
    }

    public enum Text {
        public static let maximumInputLines = 4
    }
}
