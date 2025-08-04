//
//  Product.swift
//  ShopDemo
//
//  Created by 魏偌帆 on 2023/11/27.
//

import Foundation

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var image: String
    var price: Int
}

var productList = [Product(name: "Bird's Eye Sweater", image: "sweater1", price: 100),
                   Product(name: "Cashmere-blend turtleneck jumper", image: "sweater2", price: 200),
                   Product(name: "Wool-blend turtleneck jumper", image: "sweater3", price: 300),
                   Product(name: "Crystal Button Cuff Ribbed Sweater", image: "sweater4", price: 400),
                   Product(name: "Funnel Neck Wedge Sweater", image: "sweater5", price: 500),
                   Product(name: "Shimmer Turtleneck Sweater", image: "sweater6", price: 600),
                   Product(name: "Fair Isle Turtleneck Sweater", image: "sweater7", price: 700),
                   Product(name: "Houndstooth Jacquard Sweater", image: "sweater8", price: 800),
                   Product(name: "Cashmere Ribbed Turtleneck", image: "sweater9", price: 900),
                   Product(name: "Cable Sweater Coatigan", image: "sweater10", price: 1000),
                   Product(name: "Bejeweled Sweater", image: "sweater11", price: 150),
                   Product(name: "Relaxed Cable Sweater Jacket", image: "sweater12", price: 250),
                   Product(name: "Cashmere Turtleneck Wedge Sweater", image: "sweater13", price: 350),
                   Product(name: "Relaxed Mock Neck Cable Sweater", image: "sweater14", price: 450),
                   Product(name: "Texture Shimmer Stitch Mock Neck", image: "sweater15", price: 550),
                   Product(name: "Geo Jacquard Mock Neck Sweater", image: "sweater16", price: 650),
                   Product(name: "Merino Wool Turtleneck Sweater", image: "sweater17", price: 750),
                   Product(name: "Floral Jacquard Puff Sleeve Sweater", image: "sweater18", price: 850),
                   Product(name: "Shimmer Shrug Dress Cardigan", image: "sweater19", price: 950),
                   Product(name: "Boucle Mock Neck Sweater", image: "sweater20", price: 1050),
                   Product(name: "Cozy Turtleneck Sweater", image: "sweater21", price: 990),
                   Product(name: "Cozy Wedge Sweater", image: "sweater22", price: 770),
                   Product(name: "Cable Relaxed Boatneck Tunic", image: "sweater23", price: 880),
                   Product(name: "Ribbed V-Neck Cardigan", image: "sweater24", price: 120),
                   Product(name: "Mixed Cable Relaxed Cardigan", image: "sweater25", price: 230),
                   Product(name: "Boucle Cardigan", image: "sweater26", price: 450),
                   Product(name: "Faux Suede Mixed Media Cardigan", image: "sweater27", price: 560)]
