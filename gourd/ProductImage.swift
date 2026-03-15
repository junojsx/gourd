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
        GeometryReader { geo in
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                case .failure:
                    fallbackView(size: geo.size)
                case .empty:
                    ZStack {
                        fallbackBg
                        ProgressView()
                            .tint(Color.ftDeepForest.opacity(0.4))
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                @unknown default:
                    fallbackView(size: geo.size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func fallbackView(size: CGSize) -> some View {
        ZStack {
            fallbackBg
            Image(systemName: fallbackIcon)
                .font(.system(size: min(size.width, size.height) * 0.3))
                .foregroundStyle(Color.ftDeepForest.opacity(0.35))
        }
        .frame(width: size.width, height: size.height)
    }
}
