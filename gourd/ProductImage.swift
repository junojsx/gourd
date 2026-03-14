//
//  ProductImage.swift
//  gourd
//
//  Shared AsyncImage wrapper used in pantry rows and product detail.
//

import SwiftUI

struct ProductImage: View {
    let urlString: String
    let fallbackIcon: String
    let fallbackBg: Color
    var cornerRadius: CGFloat = 10

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            case .failure:
                fallbackView
            case .empty:
                ZStack {
                    fallbackBg
                    ProgressView()
                        .tint(Color.ftDeepForest.opacity(0.4))
                }
            @unknown default:
                fallbackView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var fallbackView: some View {
        ZStack {
            fallbackBg
            Image(systemName: fallbackIcon)
                .font(.system(size: 24))
                .foregroundStyle(Color.ftDeepForest.opacity(0.35))
        }
    }
}
