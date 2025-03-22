//
//  ReaderView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ReaderView: View {
    @ObservedObject var router: Router
    @Binding var isChaptersPresented: Bool
    
    @State private var isPlaying = false
    @State private var isSettingsPresented = false
    
    @State private var fontSize: CGFloat = 16
    @State private var lineSpacing: CGFloat = 8
    
    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: .background))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 16)
                
                ScrollView {
                    Text(MockBookText.text)
                        .font(.system(size: fontSize))
                        .lineSpacing(lineSpacing)
                        .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 16 + Constants.toolbarHeight)
                }
                
                toolbar
                    .frame(height: Constants.toolbarHeight)
                    .background(UIKitAssets.setColor(for: .accentLight))
            }
            
            if isSettingsPresented {
                settingsPopup
            }
        }
        .sheet(isPresented: $isChaptersPresented) {
            ChaptersView(isPresented: $isChaptersPresented)
        }
    }
}

private extension ReaderView {
    
    var header: some View {
        HStack {
            BackButtonView(action: { router.navigateTo(.mainTab) }, title: "", color: .dark)
                .padding(.leading, 16)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Код Да Винчи")
                    .applyFontH2AccentDarkStyle()
                Text("Глава 5")
                    .applyFontBodySmallAccentDarkStyle()
            }
            
            Spacer()
            
            Spacer().frame(width: 50) // симметрия с кнопкой назад
        }
    }
    
    var toolbar: some View {
        HStack {
            HStack(spacing: 8) {
                ReaderIconButton(imageName: "prev") { print("Prev") }
                ReaderIconButton(imageName: "chapters") { isChaptersPresented = true }
                ReaderIconButton(imageName: "next") { print("Next") }
                ReaderIconButton(imageName: "settings") { isSettingsPresented = true }
            }
            .frame(width: 200, height: 44)
            .padding(.leading, 16)
            .padding(.top, 16)
            
            Spacer()
            
            Button(action: {
                isPlaying.toggle()
            }) {
                Text(isPlaying ? "Stop" : "Play")
                    .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    .padding(.trailing, 16)
                    .padding(.top, 16)
            }
        }
    }
    
    var settingsPopup: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Настройки")
                    .applyFontH2AccentDarkStyle()
                Spacer()
                Button("Close") {
                    isSettingsPresented = false
                }
            }

            settingRow(title: "Размер шрифта", value: "\(Int(fontSize)) pt", increment: { fontSize += 1 }, decrement: { fontSize = max(10, fontSize - 1) })

            settingRow(title: "Межстрочный интервал", value: "\(Int(lineSpacing)) pt", increment: { lineSpacing += 1 }, decrement: { lineSpacing = max(0, lineSpacing - 1) })
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(UIKitAssets.setColor(for:.white))
        .cornerRadius(12)
        .padding()
    }
    
    func settingRow(title: String, value: String, increment: @escaping () -> Void, decrement: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyFontBodyAccentDarkStyle()
            HStack {
                Text(value)
                    .applyFontBodySmallAccentDarkStyle()
                Spacer()
                Button("+", action: increment)
                Button("-", action: decrement)
            }
        }
    }
}

struct ReaderIconButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName) 
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}


struct MockBookText {
    static let text = """
    Факты

    Приорат Сиона — реальное тайное общество, основанное в 1099 году.

    В 1975 году в Национальной библиотеке Франции были обнаружены свитки, известные как Les Dossiers Secrets, содержащие доказательства существования Приората и перечень его Великих магистров. Среди них — Исаак Ньютон, Боттичелли, Виктор Гюго и Леонардо да Винчи.

    Ватиканская прелатура Opus Dei — католическая организация, получившая противоречивую известность из-за преданности и практик.

    Все описанные произведения искусства, здания, документы и тайные ритуалы существуют на самом деле.
    """
}

// MARK: - Constants
private extension ReaderView {
    enum Constants {
        static let toolbarHeight: CGFloat = 74
        
        static let sidePadding: CGFloat = 16
        static let topPadding: CGFloat = 16
        
        static let headerSpacing: CGFloat = 8
        
        static let controlButtonSize: CGFloat = 44
        static let controlButtonSpacing: CGFloat = 8
        static let controlGroupWidth: CGFloat = 200
        
        static let settingsPopupCornerRadius: CGFloat = 12
        static let settingsPopupPadding: CGFloat = 16
    }
}

#Preview {
    ReaderView(router: Router(), isChaptersPresented: .constant(false))
        
}
