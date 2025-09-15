//
//  AboutView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("📱 О приложении InGermany")
                    .font(.title)
                    .bold()

                Text("InGermany — это офлайн-справочник для мигрантов, студентов и семей в Германии. Приложение поддерживает три языка (русский, английский, таджикский) и включает статьи о жизни, бюрократии, финансах и интеграции в Германии.")

                Text("🌟 Основные функции:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• Мультиязычность")
                    Text("• Поиск по статьям")
                    Text("• Избранные статьи")
                    Text("• Категории и теги")
                    Text("• Светлая и тёмная тема")
                }

                Text("👨‍💻 Автор: Умед Сабзаев")
                Text("🇩🇪 Разработка: SwiftUI, iOS 17+")
                Text("📂 Код проекта:").bold()
                Link("GitHub Repository", destination: URL(string: "https://github.com/UmedTJK/InGermany")!)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("О проекте")
    }
}
