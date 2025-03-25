//
//  CustomTextLabel.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import SwiftUI

struct CustomTextLabel: UIViewRepresentable {
    private var text: String
    private var font: UIFont
    private var color: UIColor
    private var lineHeightMultiple: CGFloat
    private var alignment: NSTextAlignment

    init(text: String = "") {
        self.text = text
        self.font = UIFont.systemFont(ofSize: 14)
        self.color = .label
        self.lineHeightMultiple = 1.0
        self.alignment = .left
    }

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = alignment

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]

        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}

extension CustomTextLabel {
    func text(_ text: String) -> CustomTextLabel {
        var view = self
        view.text = text
        return view
    }

    func font(_ font: UIFont) -> CustomTextLabel {
        var view = self
        view.font = font
        return view
    }

    func font(name: String, size: CGFloat) -> CustomTextLabel {
        var view = self
        if let customFont = UIFont(name: name, size: size) {
            view.font = customFont
        } else {
            view.font = UIFont.systemFont(ofSize: size)
        }
        return view
    }

    func foregroundColor(_ color: UIColor) -> CustomTextLabel {
        var view = self
        view.color = color
        return view
    }

    func foregroundColor(_ color: Color) -> CustomTextLabel {
        foregroundColor(UIColor(color))
    }

    func lineHeightMultiple(_ value: CGFloat) -> CustomTextLabel {
        var view = self
        view.lineHeightMultiple = value
        return view
    }

    func textAlignment(_ alignment: NSTextAlignment) -> CustomTextLabel {
        var view = self
        view.alignment = alignment
        return view
    }
}
