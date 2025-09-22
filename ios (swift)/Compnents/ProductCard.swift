//
//  ProductCard.swift
//  ShopDemo
//
//  Created by 魏偌帆 on 2023/11/27.
//

import OmniSegmentKit  // BeBit Tech analytics SDK for cart and wishlist event tracking
import SwiftUI

struct ProductCard: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                Image(product.image)
                    .resizable()
                    .cornerRadius(20)
                    .frame(width: 180)
                    .scaledToFit()

                VStack(alignment: .leading) {
                    Text(product.name)
                        .bold()
                    Text("\(product.price)$")
                        .font(.caption)
                }
                .padding()
                .frame(width: 180, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .frame(width: 180, height: 250)
            .shadow(radius: 3)

            VStack(spacing: 0) {
                Button {
                    cartManager.addToCart(product: product)

                    // Convert product to OmniSegment format and track add to cart event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                    let productIdString = product.id.uuidString
                    let osgProduct = OSGProduct(id: productIdString, name: product.name)
                    osgProduct.price = NSNumber(value: product.price)

                    // Track add to cart event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                    var event = OSGEvent.addToCart([osgProduct])
                    event.location = "ProductList"
                    event.locationTitle = "SweaterApp"
                    OmniSegment.trackEvent(event)
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .foregroundColor(.white)
                        .background(.black)
                        .cornerRadius(50)
                        .padding()
                }

                Button {
                    // Convert product to OmniSegment format and track add to wishlist event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                    let productIdString = product.id.uuidString
                    let osgProduct = OSGProduct(id: productIdString, name: product.name)
                    osgProduct.price = NSNumber(value: product.price)

                    // Track add to wishlist event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                    var event = OSGEvent.addToWishlist([osgProduct])
                    event.location = "ProductList"
                    event.locationTitle = "SweaterApp"
                    OmniSegment.trackEvent(event)

                } label: {
                    Image(systemName: "heart.fill")
                        .padding(8)
                        .foregroundColor(.white)
                        .background(.black)
                        .cornerRadius(50)
                        .padding()
                }
            }
        }
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductCard(product: productList[0])
            .environmentObject(CartManager())
    }
}
