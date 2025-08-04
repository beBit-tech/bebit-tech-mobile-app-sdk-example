//
//  ProductRow.swift
//  ShopDemo
//
//  Created by 魏偌帆 on 2023/11/27.
//

import OmniSegmentKit  // BeBit Tech analytics SDK for cart removal event tracking
import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    var body: some View {
        HStack(spacing: 20) {
            Image(product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 10) {
                Text(product.name)
                    .bold()

                Text("$\(product.price)")
            }

            Spacer()

            Image(systemName: "trash")
                .foregroundColor(Color(hue: 1.0, saturation: 0.89, brightness: 0.835))
                .onTapGesture {
                    cartManager.removeFromCart(product: product)

                    // Convert product to OmniSegment format and track remove from cart event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                    let productIdString = product.id.uuidString
                    let osgProduct = OSGProduct(id: productIdString, name: product.name)

                    // Track remove from cart event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                    let event = OSGEvent.removeFromCart([osgProduct])
                    event.location = "Cart"
                    event.locationTitle = "SweaterApp"
                    OmniSegment.trackEvent(event)
                }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProductRow_Previews: PreviewProvider {
    static var previews: some View {
        ProductRow(product: productList[3])
            .environmentObject(CartManager())
    }
}
