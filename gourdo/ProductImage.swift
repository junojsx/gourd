//
//  ProductImage.swift
//  gourdo
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
            let url = URL(string: urlString)
            if url == nil {
                // No image URL — show GourdLogo immediately without a loading spinner
                gourdPlaceholder(size: geo.size)
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    case .failure:
                        gourdPlaceholder(size: geo.size)
                    case .empty:
                        ZStack {
                            fallbackBg
                            ProgressView()
                                .tint(Color.ftDeepForest.opacity(0.4))
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    @unknown default:
                        gourdPlaceholder(size: geo.size)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func gourdPlaceholder(size: CGSize) -> some View {
        ZStack {
            fallbackBg
            Image("GourdLogo")
                .resizable()
                .scaledToFit()
                .frame(width: min(size.width, size.height) * 0.55)
                .opacity(0.35)
        }
        .frame(width: size.width, height: size.height)
    }
}
