//
//  ColorValue.swift
//  swift 4.0 Hero Animation - Day 7
//
//  Created by Apple  on 20/12/22.
//

import Foundation
import SwiftUI

//MARK: Color Model and sample colors
struct ColorValue:Identifiable,Hashable,Equatable{
    var id:UUID = .init()
    var colorCode:String
    var title:String
    var color:Color
}

var colors:[ColorValue] = [
    .init(colorCode: "5F27CD", title: "Warm Purple", color: Color("Color 1")),
    .init(colorCode: "222F3E", title: "Imperial Black", color: Color("Color 2")),
    .init(colorCode: "E15F41", title: "Old Rose", color: Color("Color 3")),
    .init(colorCode: "786FA6", title: "Mountain View", color: Color("Color 4")),
    .init(colorCode: "EE5253", title: "Armour Red", color: Color("Color 5")),
    .init(colorCode: "05C46B", title: "Orc skin", color: Color("Color 6")),
]
