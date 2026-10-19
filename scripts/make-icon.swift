#!/usr/bin/env swift
// Draws the 2FA-vlv app icon (1024x1024 PNG). Usage: swift scripts/make-icon.swift <output.png>
import AppKit

let size = 1024
let output = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Assets/AppIcon-1024.png"

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0
), let gfx = NSGraphicsContext(bitmapImageRep: rep) else { fatalError("no context") }

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = gfx
let ctx = gfx.cgContext
let space = CGColorSpaceCreateDeviceRGB()

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}
func gradient(_ hexes: [UInt32]) -> CGGradient {
    CGGradient(colorsSpace: space, colors: hexes.map { color($0) } as CFArray, locations: nil)!
}

// Tile (Apple icon grid: 824pt body inside 1024 canvas).
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = CGPath(roundedRect: tile, cornerWidth: 186, cornerHeight: 186, transform: nil)

// Drop shadow under the tile.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 28, color: color(0x000000, 0.35))
ctx.addPath(tilePath)
ctx.setFillColor(color(0x0F172A))
ctx.fillPath()
ctx.restoreGState()

// Background gradient.
ctx.saveGState()
ctx.addPath(tilePath)
ctx.clip()
ctx.drawLinearGradient(gradient([0x1E293B, 0x0B1220]), start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
// Soft green glow behind the shield.
let glow = CGGradient(colorsSpace: space, colors: [color(0x22C55E, 0.28), color(0x22C55E, 0)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(glow, startCenter: CGPoint(x: 512, y: 512), startRadius: 0, endCenter: CGPoint(x: 512, y: 512), endRadius: 400, options: [])
// Top highlight.
ctx.drawLinearGradient(
    CGGradient(colorsSpace: space, colors: [color(0xFFFFFF, 0.10), color(0xFFFFFF, 0)] as CFArray, locations: [0, 1])!,
    start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 640), options: [])
ctx.restoreGState()

// Countdown ring: faint track + 75% progress arc.
let center = CGPoint(x: 512, y: 512)
let radius: CGFloat = 306
let lineWidth: CGFloat = 58

ctx.saveGState()
ctx.setLineWidth(lineWidth)
ctx.setStrokeColor(color(0xFFFFFF, 0.09))
ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
ctx.strokePath()
ctx.restoreGState()

let arc = CGMutablePath()
arc.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / 2 - .pi * 1.5, clockwise: true)
let stroked = arc.copy(strokingWithWidth: lineWidth, lineCap: .round, lineJoin: .round, miterLimit: 10)
ctx.saveGState()
ctx.addPath(stroked)
ctx.clip()
ctx.drawLinearGradient(gradient([0x86EFAC, 0x22C55E, 0x15803D]), start: CGPoint(x: 300, y: 820), end: CGPoint(x: 700, y: 200), options: [])
ctx.restoreGState()

// Shield.
let shield = CGMutablePath()
shield.move(to: CGPoint(x: 512, y: 676))
shield.addLine(to: CGPoint(x: 388, y: 630))
shield.addLine(to: CGPoint(x: 388, y: 504))
shield.addCurve(to: CGPoint(x: 512, y: 344), control1: CGPoint(x: 388, y: 420), control2: CGPoint(x: 450, y: 372))
shield.addCurve(to: CGPoint(x: 636, y: 504), control1: CGPoint(x: 574, y: 372), control2: CGPoint(x: 636, y: 420))
shield.addLine(to: CGPoint(x: 636, y: 630))
shield.closeSubpath()

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 22, color: color(0x000000, 0.4))
ctx.addPath(shield)
ctx.setFillColor(color(0xF8FAFC))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(shield)
ctx.clip()
ctx.drawLinearGradient(gradient([0xFFFFFF, 0xCBD5E1]), start: CGPoint(x: 512, y: 676), end: CGPoint(x: 512, y: 344), options: [])
ctx.restoreGState()

// Keyhole.
ctx.setFillColor(color(0x0F172A))
ctx.fillEllipse(in: CGRect(x: 512 - 34, y: 520 - 34, width: 68, height: 68))
let slot = CGMutablePath()
slot.move(to: CGPoint(x: 494, y: 522))
slot.addLine(to: CGPoint(x: 530, y: 522))
slot.addLine(to: CGPoint(x: 544, y: 440))
slot.addLine(to: CGPoint(x: 480, y: 440))
slot.closeSubpath()
ctx.addPath(slot)
ctx.fillPath()

NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else { fatalError("png failed") }
try png.write(to: URL(fileURLWithPath: output))
print("Wrote \(output)")
