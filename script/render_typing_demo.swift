#!/usr/bin/env swift

import AppKit
import Foundation

struct DemoToken {
    let roman: String
    let telugu: String
    let delimiter: String
}

struct FrameState {
    let committed: String
    let composing: String
    let candidate: String
    let romanProgress: String
    let showCandidates: Bool
}

let tokens = [
    DemoToken(roman: "ela", telugu: "ఎలా", delimiter: " "),
    DemoToken(roman: "unnav", telugu: "ఉన్నావ్", delimiter: "? "),
    DemoToken(roman: "em", telugu: "ఏం", delimiter: " "),
    DemoToken(roman: "chestunnav", telugu: "చేస్తున్నావ్", delimiter: "? "),
    DemoToken(roman: "bagundi", telugu: "బాగుంది", delimiter: " "),
    DemoToken(roman: "kani", telugu: "కానీ", delimiter: " "),
    DemoToken(roman: "ilaa", telugu: "ఇలా", delimiter: " "),
    DemoToken(roman: "kaadu", telugu: "కాదు", delimiter: "."),
]

let romanSentence = tokens.map(\.roman).enumerated().map { index, token in
    switch index {
    case 1, 3:
        return token + "?"
    case 7:
        return token + "."
    default:
        return token
    }
}.joined(separator: " ")

let teluguSentence = tokens.map { $0.telugu + $0.delimiter }.joined()
let width = 1280
let height = 720
let fps = 24
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let frameDirectory = root.appendingPathComponent(".build/typing-demo-frames", isDirectory: true)
let gifWorkDirectory = root.appendingPathComponent(".build/typing-demo-gif", isDirectory: true)
let outputURL = root.appendingPathComponent("docs/assets/typing-demo.mp4")
let gifURL = root.appendingPathComponent("docs/assets/typing-demo.gif")
let fileManager = FileManager.default

try? fileManager.removeItem(at: frameDirectory)
try fileManager.createDirectory(at: frameDirectory, withIntermediateDirectories: true)
try? fileManager.removeItem(at: gifWorkDirectory)
try fileManager.createDirectory(at: gifWorkDirectory, withIntermediateDirectories: true)

func color(_ hex: UInt32) -> NSColor {
    let red = CGFloat((hex >> 16) & 0xff) / 255
    let green = CGFloat((hex >> 8) & 0xff) / 255
    let blue = CGFloat(hex & 0xff) / 255
    return NSColor(red: red, green: green, blue: blue, alpha: 1)
}

func drawRoundedRect(_ rect: NSRect, radius: CGFloat, fill: NSColor) {
    fill.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func drawText(_ text: String, at point: NSPoint, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    (text as NSString).draw(
        at: point,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
        ]
    )
}

func drawText(_ text: String, in rect: NSRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    paragraphStyle.lineBreakMode = .byTruncatingTail
    (text as NSString).draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
        ]
    )
}

func textWidth(_ text: String, font: NSFont) -> CGFloat {
    (text as NSString).size(withAttributes: [.font: font]).width
}

let titleFont = NSFont.systemFont(ofSize: 34, weight: .bold)
let bodyFont = NSFont.systemFont(ofSize: 22, weight: .regular)
let teluguFont = NSFont(name: "Kohinoor Telugu", size: 44) ?? NSFont.systemFont(ofSize: 44, weight: .semibold)
let teluguCandidateFont = NSFont(name: "Kohinoor Telugu", size: 30) ?? NSFont.systemFont(ofSize: 30, weight: .semibold)
let romanFont = NSFont.monospacedSystemFont(ofSize: 34, weight: .regular)
let romanSmallFont = NSFont.monospacedSystemFont(ofSize: 21, weight: .regular)
let labelFont = NSFont.systemFont(ofSize: 18, weight: .medium)

var states: [FrameState] = []
var committed = ""
var romanProgress = ""

for token in tokens {
    var composing = ""
    for character in token.roman {
        composing.append(character)
        romanProgress.append(character)
        for _ in 0..<2 {
            states.append(
                FrameState(
                    committed: committed,
                    composing: composing,
                    candidate: token.telugu,
                    romanProgress: romanProgress,
                    showCandidates: false
                )
            )
        }
    }

    for _ in 0..<10 {
        states.append(
            FrameState(
                committed: committed,
                composing: composing,
                candidate: token.telugu,
                romanProgress: romanProgress,
                showCandidates: true
            )
        )
    }

    committed += token.telugu + token.delimiter
    romanProgress += token.delimiter

    for _ in 0..<6 {
        states.append(
            FrameState(
                committed: committed,
                composing: "",
                candidate: token.telugu,
                romanProgress: romanProgress,
                showCandidates: false
            )
        )
    }
}

for _ in 0..<48 {
    states.append(
        FrameState(
            committed: teluguSentence,
            composing: "",
            candidate: "",
            romanProgress: romanSentence,
            showCandidates: false
        )
    )
}

func renderFrame(_ state: FrameState, index: Int) throws {
    let image = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()

    color(0x0F172A).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()

    drawRoundedRect(NSRect(x: 82, y: 86, width: 1116, height: 548), radius: 26, fill: color(0xF8FAFC))
    drawRoundedRect(NSRect(x: 82, y: 586, width: 1116, height: 48), radius: 26, fill: color(0xE2E8F0))
    drawRoundedRect(NSRect(x: 112, y: 606, width: 14, height: 14), radius: 7, fill: color(0xEF4444))
    drawRoundedRect(NSRect(x: 136, y: 606, width: 14, height: 14), radius: 7, fill: color(0xF59E0B))
    drawRoundedRect(NSRect(x: 160, y: 606, width: 14, height: 14), radius: 7, fill: color(0x10B981))

    drawText("Telugu Keyboard", at: NSPoint(x: 140, y: 528), font: titleFont, color: color(0x111827))
    drawText("Type Roman Telugu. Write Telugu script. Stay offline.", at: NSPoint(x: 140, y: 492), font: bodyFont, color: color(0x475569))

    drawRoundedRect(NSRect(x: 140, y: 250, width: 1000, height: 190), radius: 18, fill: color(0xFFFFFF))
    drawRoundedRect(NSRect(x: 140, y: 250, width: 1000, height: 190), radius: 18, fill: NSColor(white: 1, alpha: 0.001))

    let textX: CGFloat = 178
    let textY: CGFloat = 338
    drawText(state.committed, at: NSPoint(x: textX, y: textY), font: teluguFont, color: color(0x0F172A))

    let committedWidth = textWidth(state.committed, font: teluguFont)
    let composingX = textX + committedWidth
    if !state.composing.isEmpty {
        drawText(state.composing, at: NSPoint(x: composingX, y: textY + 6), font: romanFont, color: color(0x2563EB))
        color(0x2563EB).setStroke()
        let underline = NSBezierPath()
        underline.lineWidth = 3
        underline.move(to: NSPoint(x: composingX, y: textY - 2))
        underline.line(to: NSPoint(x: composingX + textWidth(state.composing, font: romanFont), y: textY - 2))
        underline.stroke()
    }

    let caretX = composingX + (state.composing.isEmpty ? 0 : textWidth(state.composing, font: romanFont)) + 3
    if (index / 12) % 2 == 0 {
        color(0x0F172A).setFill()
        NSRect(x: caretX, y: textY + 3, width: 3, height: 48).fill()
    }

    if state.showCandidates {
        let popupX = min(max(composingX - 16, 172), 910)
        drawRoundedRect(NSRect(x: popupX, y: 144, width: 250, height: 170), radius: 18, fill: color(0x111827))
        drawRoundedRect(NSRect(x: popupX + 12, y: 250, width: 226, height: 48), radius: 10, fill: color(0x2563EB))
        drawText("1", at: NSPoint(x: popupX + 28, y: 262), font: labelFont, color: color(0xFFFFFF))
        drawText(state.candidate, in: NSRect(x: popupX + 58, y: 254, width: 170, height: 42), font: teluguCandidateFont, color: color(0xFFFFFF))
        drawText(state.composing, in: NSRect(x: popupX + 28, y: 212, width: 196, height: 28), font: romanSmallFont, color: color(0xCBD5E1))
        drawText("Space commits", at: NSPoint(x: popupX + 28, y: 174), font: labelFont, color: color(0x94A3B8))
    }

    drawText("Roman input", at: NSPoint(x: 180, y: 198), font: labelFont, color: color(0x64748B))
    drawText(state.romanProgress, in: NSRect(x: 180, y: 158, width: 900, height: 34), font: romanSmallFont, color: color(0x0F172A))

    drawText("Final", at: NSPoint(x: 180, y: 118), font: labelFont, color: color(0x64748B))
    drawText(teluguSentence, in: NSRect(x: 236, y: 107, width: 860, height: 42), font: NSFont(name: "Kohinoor Telugu", size: 26) ?? NSFont.systemFont(ofSize: 26), color: color(0x0F766E))

    image.unlockFocus()

    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "TypingDemo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not render frame \(index)"])
    }

    let frameURL = frameDirectory.appendingPathComponent(String(format: "frame_%04d.png", index))
    try pngData.write(to: frameURL)
}

func runFFmpeg(_ arguments: [String], label: String) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
    process.arguments = ["-y", "-hide_banner", "-loglevel", "error"] + arguments
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw NSError(domain: "TypingDemo", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "\(label) failed"])
    }
}

for (index, state) in states.enumerated() {
    try renderFrame(state, index: index)
}

try? fileManager.removeItem(at: outputURL)
try? fileManager.removeItem(at: gifURL)

try runFFmpeg([
    "-framerate", "\(fps)",
    "-i", frameDirectory.appendingPathComponent("frame_%04d.png").path,
    "-vf", "format=yuv420p",
    "-movflags", "+faststart",
    "-c:v", "libx264",
    "-preset", "slow",
    "-crf", "28",
    outputURL.path,
], label: "MP4 render")

let paletteURL = gifWorkDirectory.appendingPathComponent("palette.png")

try runFFmpeg([
    "-i", outputURL.path,
    "-vf", "fps=12,scale=960:-1:flags=lanczos,palettegen=stats_mode=diff",
    paletteURL.path,
], label: "GIF palette render")

try runFFmpeg([
    "-i", outputURL.path,
    "-i", paletteURL.path,
    "-lavfi", "fps=12,scale=960:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle",
    gifURL.path,
], label: "GIF render")

print("Rendered \(outputURL.path)")
print("Rendered \(gifURL.path)")
