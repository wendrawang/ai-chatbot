import DesignKit

// DesignKit knows nothing about Tanya AI - its types are named for what they
// are, not for the feature that happens to use them. These aliases are what
// keeps that invisible to a host: the integration surface still speaks one
// consistent prefix, and moving a type between packages cannot reach into
// application code.
public typealias TanyaAITheme = DesignKit.Theme
public typealias TanyaAIColors = DesignKit.Colors
public typealias TanyaAIFonts = DesignKit.Fonts
