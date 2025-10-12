//
//  DemoArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

struct DemoArticleView: View {
    let sections = loadArticle(named: "burgeramt_registration")

    var body: some View {
        ArticleRenderer(sections: sections)
    }
}

#Preview {
    DemoArticleView()
}

