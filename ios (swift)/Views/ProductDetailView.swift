//
//  ProductDetailView.swift
//  ShopDemo
//
//  Created by 魏偌帆 on 2023/12/27.
//

import OmniSegmentKit  // BeBit Tech analytics SDK for product interaction tracking
import SwiftUI

struct ProductDetailView: View {
    var product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(product.image)
                    .resizable()
                    .scaledToFit()

                VStack(alignment: .leading, spacing: 10) {
                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Price: \(product.price)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding()
            }
        }
        .onAppear {
            // Convert product to OmniSegment format for product click and impression tracking
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
            let productIdString = product.id.uuidString
            let osgProduct = OSGProduct(id: productIdString, name: product.name)
            osgProduct.price = NSNumber(value: product.price)

            // Track product click event (when user navigates to detail view)
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
            let clickEvent = OSGEvent.productClicked([osgProduct])
            clickEvent.location = "Home"
            clickEvent.locationTitle = "SewaterApp"
            OmniSegment.trackEvent(clickEvent)

            // Track product detail view impression
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
            let viewDetailEvent = OSGEvent.productImpression([osgProduct])
            viewDetailEvent.location = "Detail"
            viewDetailEvent.locationTitle = "SewaterApp"
            OmniSegment.trackEvent(viewDetailEvent)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
