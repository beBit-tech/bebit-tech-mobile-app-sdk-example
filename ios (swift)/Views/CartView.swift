//
//  CartView.swift
//  ShopDemo
//
//  Created by 魏偌帆 on 2023/11/27.
//

import OmniSegmentKit  // BeBit Tech analytics SDK for e-commerce event tracking
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    static var hasSentCheckoutEvent = false

    var body: some View {
        NavigationView {
            ScrollView {
                if cartManager.products.count > 0 {
                    ForEach(cartManager.products, id: \.id) { product in
                        ProductRow(product: product)
                    }

                    HStack {
                        Text("Your cart total is")
                        Spacer()
                        Text("$\(cartManager.total).00")
                            .bold()
                    }
                    .padding()

                    HStack(spacing: 20) {
                        Button(action: {
                            // Convert cart products to OmniSegment format for purchase tracking
                            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                            let osgProducts = cartManager.products.map { product in
                                let osgProduct = OSGProduct(id: product.id.uuidString, name: product.name)
                                osgProduct.price = NSNumber(value: product.price)
                                return osgProduct
                            }

                            let transactionId = UUID().uuidString
                            let revenue = cartManager.total
                            // OmniSegment SDK
                            // Track purchase event with transaction details
                            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                            let purchaseEvent = OSGEvent.purchase(transactionId, revenue: NSNumber(value: revenue), products: osgProducts)
                            purchaseEvent.location = "CartView"
                            purchaseEvent.locationTitle = "SweaterApp Cart"
                            purchaseEvent.transactionShipping = "10"
                            purchaseEvent.transactionTax = "10"

                            OmniSegment.trackEvent(purchaseEvent)
                        }) {
                            Text("Purchase")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }

                        Button(action: {
                            // Convert cart products to OmniSegment format for refund tracking
                            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                            let osgProducts = cartManager.products.map { product in
                                let osgProduct = OSGProduct(id: product.id.uuidString, name: product.name)
                                osgProduct.price = NSNumber(value: product.price)
                                return osgProduct
                            }

                            let transactionId = UUID().uuidString
                            let revenue = cartManager.total
                            // OmniSegment SDK
                            // Track refund event with transaction details
                            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                            let refundEvent = OSGEvent.refund(transactionId, revenue: NSNumber(value: revenue), products: osgProducts)
                            refundEvent.location = "CartView"
                            refundEvent.locationTitle = "SweaterApp Cart"

                            OmniSegment.trackEvent(refundEvent)
                        }) {
                            Text("Refund")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Your cart is empty")
                }
            }
            .navigationTitle("My Cart")
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // OmniSegment SDK
                        // Track custom subscription email event
                        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                        let cutomEvent = OSGEvent.custom(action: "SubscriptionEmail", value: "renee.wei@bebit-tech.com")
                        cutomEvent.location = "CartView"
                        cutomEvent.locationTitle = "SweaterApp Cart"

                        OmniSegment.trackEvent(cutomEvent)
                    }) {
                        Image(systemName: "bell")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                // Set current page for analytics tracking
                OmniSegment.setCurrentPage("Cart")

                // Track checkout event only once per session to avoid duplicate events
                if !Self.hasSentCheckoutEvent {
                    // Convert cart products to OmniSegment format for checkout tracking
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties
                    let osgProducts = cartManager.products.map { product in
                        let osgProduct = OSGProduct(id: product.id.uuidString, name: product.name)
                        osgProduct.price = NSNumber(value: product.price)
                        return osgProduct
                    }
                    // OmniSegment SDK
                    // Track checkout initiation event
                    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                    let event = OSGEvent.checkout(osgProducts)
                    event.location = "CartView"
                    event.locationTitle = "SweaterApp Cart"
                    OmniSegment.trackEvent(event)

                    Self.hasSentCheckoutEvent = true
                }
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartManager())
    }
}
