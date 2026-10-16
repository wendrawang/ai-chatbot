//
//  RichTextParser.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation

struct RichTextStyle: Equatable
{
    var isBold = false
    var isStruckThrough = false
    var color: String?
    var link: URL?
}

struct RichTextRun: Equatable
{
    var text: String
    var style: RichTextStyle
}

/// The existing bracket grammar remains native text; HTML is never interpreted.
enum RichTextParser
{
    static let maximumDepth = 32
    static func parse(_ source: String, isFinal: Bool) -> [RichTextRun]
    {
        var frames = [RichTextFrame(name: "", parameter: nil)]
        var cursor = source.startIndex
        while cursor < source.endIndex
        {
            guard source[cursor] == "["
            else
            {
                appendLiteral(source, cursor: &cursor, frames: &frames)
                continue
            }

            guard let token = RichTextToken(source: source, start: cursor)
            else
            {
                guard isFinal || !isPartial(source[cursor...])
                else
                {
                    break
                }

                frames[frames.count - 1].append(String(source[cursor]))
                cursor = source.index(after: cursor)
                continue
            }

            cursor = token.end
            guard !token.isClosing
            else
            {
                close(token.name, frames: &frames)
                continue
            }

            guard frames.count <= maximumDepth
            else
            {
                return [RichTextRun(text: source, style: RichTextStyle())]
            }

            frames.append(RichTextFrame(name: token.name, parameter: token.parameter))
        }

        return finish(frames)
    }

    private static func finish(_ values: [RichTextFrame]) -> [RichTextRun]
    {
        var frames = values
        while frames.count > 1
        {
            let frame = frames.removeLast()
            frames[frames.count - 1].runs += frame.styledRuns(isClosed: false)
        }

        return frames[0].runs.filter
        {
            !$0.text.isEmpty
        }
    }

    private static func appendLiteral(
        _ source: String, cursor: inout String.Index, frames: inout [RichTextFrame])
    {
        let next = source.index(after: cursor)
        guard source[cursor] == "\\", next < source.endIndex, "[]\\".contains(source[next])
        else
        {
            frames[frames.count - 1].append(String(source[cursor]))
            cursor = next
            return
        }

        frames[frames.count - 1].append(String(source[next]))
        cursor = source.index(after: next)
    }

    private static func close(_ name: String, frames: inout [RichTextFrame])
    {
        guard let matching = frames.indices.dropFirst().last(where:
            {
                frames[$0].name == name
            })
        else
        {
            return
        }

        while frames.count - 1 >= matching
        {
            let frame = frames.removeLast()
            frames[frames.count - 1].runs += frame.styledRuns(isClosed: frame.name == name)
        }
    }

    private static func isPartial(_ text: Substring) -> Bool
    {
        let prefix = text.dropFirst().drop(while:
            {
                $0 == "/"
            })
        return ["bold", "strike", "color", "link"].contains
        {
            $0.hasPrefix(prefix) || prefix.hasPrefix($0 + "=")
        }
    }
}
