// LiquidGlassBackground.swift
// Rylai — Liquid Glass Background (macOS 12+ Compatible)

import SwiftUI
import AppKit

// MARK: - Liquid Glass Background (macOS 12+ Compatible)

struct LiquidGlassBackground: View {
    var intensity: Double = 0.85
    var cornerRadius: CGFloat = 20
    var tintColor: Color = .clear

    var body: some View {
        LiquidGlassFallback(intensity: intensity, cornerRadius: cornerRadius)
    }
}

// MARK: - Backward Compatible (NSVisualEffectView Wrapper)

struct LiquidGlassFallback: NSViewRepresentable {
    var intensity: Double
    var cornerRadius: CGFloat

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .contentBackground  // Control Center style
        view.blendingMode = .behindWindow    // Capture behind content
        view.state = .active
        view.wantsLayer = true
        view.alphaValue = intensity

        // Create rounded corner mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: 100, height: 100), cornerWidth: cornerRadius, cornerHeight: cornerRadius), transform: nil)
        view.layer?.mask = maskLayer

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.alphaValue = intensity
    }
}

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    var content: () -> Content
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    var backgroundColor: Color = .white.opacity(0.1)

    init(cornerRadius: CGFloat = 16, padding: CGFloat = 12, backgroundColor: Color = .white.opacity(0.1), @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.content = content
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)

            content()
                .padding(padding)
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(colors: [
                        .white.opacity(0.2),
                        .white.opacity(0.05)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Pointer Cursor Modifier

struct PointerCursorModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

extension View {
    func pointerCursor() -> some View {
        self.modifier(PointerCursorModifier())
    }
}

// MARK: - Liquid Button

struct LiquidButton: View {
    var title: String
    var icon: String?
    var isSelected: Bool
    var color: Color
    var action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(color.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
        }
        .pointerCursor()
    }
}

// MARK: - Ghost Icon Button

struct GhostIconButton: View {
    var icon: String
    var color: Color = .primary
    var action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color.opacity(isHovered ? 0.15 : 0))
                )
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .pointerCursor()
    }
}

// MARK: - Ghost Text Button

struct GhostTextButton: View {
    var text: String
    var icon: String?
    var color: Color = .primary
    var action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                }
                Text(text)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(color.opacity(isHovered ? 0.15 : 0))
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .pointerCursor()
    }
}

// MARK: - Liquid Toggle

struct LiquidToggle: View {
    var label: String
    var icon: String
    @Binding var isOn: Bool
    @State private var isHovered = false
    @State private var isDragging = false

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(isOn ? .cyan : .secondary)
                .frame(width: 24)

            // Label
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isOn ? .cyan.opacity(0.1) : .white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isOn ? .cyan.opacity(0.3) : .white.opacity(0.1), lineWidth: 1)
        )
        .pointerCursor()
    }
}

// MARK: - Glass Divider

struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.2),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    var title: String
    var icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .padding(.leading, 4)
        .padding(.bottom, 6)
    }
}
