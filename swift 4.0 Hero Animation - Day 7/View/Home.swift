//
//  Home.swift
//  swift 4.0 Hero Animation - Day 7
//
//  Created by Apple  on 20/12/22.
//

import SwiftUI

struct Home: View {
    //MARK: Animation properties
    @State var currentTime:ColorValue?
    @State var expandCard:Bool = false
    @State var moveCardDown:Bool = false // this variable is helpful for moving the card down since when the card is touched, it moves a tiny bit downward before the Hero Animation begins.
    @State var animateContent:Bool = false
    
    
    ///-  Matched geomety namespace
    @Namespace var animation
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            /// - Extracting safeArea (window on macOs) from proxy
            let safeArea = proxy.safeAreaInsets
            ScrollView(.vertical,showsIndicators: false){
                VStack(spacing:8){
                    ForEach(colors){ color in
                        
                        CardView(item: color, rectSize: size)
                        
                    }
                }//vstack
                .padding(.horizontal,10)
                .padding(.vertical,15)
                
                ///- Material Blur Top Bar
                .safeAreaInset(edge: .top) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: safeArea.top + 5)
                        .overlay{
                            Text("Color Picker")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .opacity(0.8)
                        }
                        .overlay(alignment:.trailing){
                            Text("V1.0.9")
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(.trailing,10)
                        }
                }
                //the view area must be ignored in order to fetch safe area
                .ignoresSafeArea(.container,edges: .all)
                .overlay{
                    if let currentTime,expandCard{
                        DetailView(item: currentTime, rectSize: size)
                            .transition(.asymmetric(insertion: .identity, removal: .offset(y:10)))
                    }
                }
                
            }//scroll view
        }//geometry reader
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .preferredColorScheme(.light)
    }//body
    
    //MARK: function DetailViewContent
    func DetailViewContent(item:ColorValue)-> some View{
        VStack(spacing:0){
            Rectangle()
                .fill(.white)
                .frame(height: 1)
                //  .scaleEffect(x : expandCard ? 1 : 0.001 , anchor:.leading)//it wont animate because it used for transition , to animate other view contents , we must create a new @State variable.so i created @State var animationContent
                .scaleEffect(x : animateContent ? 1 : 0.001 , anchor:.leading)
                .padding(.top,60)
            
            /// custom progress Bar  Showing RGB Data
            VStack(spacing:30){
                
                CustomProgressView(value: 0.5,label: "Red")
                CustomProgressView(value: 0.5,label: "Blue")
                CustomProgressView(value: 0.5,label: "Green")
                
            }//vstack
            .padding(15)
            .background{
                RoundedRectangle(cornerRadius: 15,style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
            //- Animating Content
            .opacity(animateContent ? 1 : 0)
            /// - slightly delay to finish the top scale animation
            /// we dont need delay while closing
            .animation(.easeInOut(duration: 0.5).delay(animateContent ? 0.2 : 0), value: animateContent)
            .padding(.horizontal,20)
            .padding(.top,30)
            
        }
        .padding(.horizontal,15)
        .frame(maxHeight: .infinity,alignment: .top)
        .onAppear {
            withAnimation(.easeInOut.delay(0.2)){
                animateContent = true
            }
        }
    }
    
    //MARK: function Reusable DetailView
    @ViewBuilder
    func DetailView(item:ColorValue,rectSize:CGSize)-> some View{
        ColorView(item: item, rectSize: rectSize)
            .ignoresSafeArea()
            .overlay(alignment:.top){
                ColorDetails(item: item, rectSize: rectSize)
            }
            .overlay{
                DetailViewContent(item: item)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)){
                    animateContent = false
                }
                ///slight delay for finishing the animate content
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    withAnimation(.easeInOut(duration: 0.4)){
                        expandCard = false
                        moveCardDown = false
                    }
                }
            }
    }//func DetailView
    
    //MARK: function CardView
    @ViewBuilder
    func CardView(item:ColorValue,rectSize:CGSize)->some View{
        let tappedCard = item.id == currentTime?.id && moveCardDown
        if !(item.id == currentTime?.id && expandCard){//multiple view with same id should be avoided
            ColorView(item:item,rectSize:rectSize)
                .frame(height:110)
                .overlay{
                    ColorDetails(item: item , rectSize: rectSize)
                }
                .frame(height: 110)
                .contentShape(Rectangle())
                .offset(y:tappedCard ? 30 : 0)
                .zIndex(tappedCard ? 100 : 0)
                .onTapGesture {
                    currentTime = item
                    withAnimation(.interactiveSpring(response: 0.3,dampingFraction: 0.4,blendDuration: 0.4)){
                        moveCardDown = true
                    }
                    
                    ///- After little delay starting Hero animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22){
                        withAnimation(.interactiveSpring(response: 0.4,dampingFraction: 1,blendDuration: 1)){
                            expandCard = true
                        }
                    }
                }
            
            
        }else{
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 110)
        }
    }/// func CardView
    
    //MARK: function Reusable Color View
    @ViewBuilder
    func ColorView(item:ColorValue , rectSize:CGSize)->some View{
        Rectangle()
            .overlay{
                Rectangle()
                    .fill(item.color.gradient)
            }
            .overlay{
                Rectangle()
                    .fill(item.color.opacity(0).gradient)
                    .rotationEffect(.init(degrees: 180))
            }
            .matchedGeometryEffect(id: item.id.uuidString, in: animation)
    }
    
    //MARK: function ColorDetails
    @ViewBuilder
    func ColorDetails(item:ColorValue,rectSize:CGSize)->some View{
        HStack{
            Text("#\(item.colorCode)")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Spacer(minLength: 0)
            
            VStack(alignment: .leading,spacing: 4) {
                Text(item.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Hexadecimal")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            /// - Aligning All Text at the leading
            .frame(width:rectSize.width * 0.3,alignment: .leading)
            
        }//Hstack
        .padding([.leading,.vertical],15)
        .matchedGeometryEffect(id: item.id.uuidString + "Details", in: animation)
    }//func ColorDetails
    
    //MARK: function Custom Progress View
    @ViewBuilder
    func CustomProgressView(value:CGFloat,label:String) -> some View{
        HStack(spacing:15){
            Text(label)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            GeometryReader {
                let size = $0.size
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.75))
                    Rectangle()
                        .fill(.white)
                        /// - Animate progress
                        .frame(width: animateContent ? size.width * value : 0)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(value * 255.0))")
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
        }//Hstack
    }// custom progress view
    
    
}//Home struct


//MARK: Extracting RGB values from NSColor


//extension UIColor{
//    var rgb:(red:CGFloat,green:CGFloat,blue:CGFloat){
//        let colorSpace = UIColor(red:1,green:1,blue:1,alpha:1)
//        var red:CGFloat = 0,green:CGFloat = 0 ,blue:CGFloat = 0 ,alpha:CGFloat = 0
//        colorSpace.get(red:&red,green:&green,blue:&blue,alpha:&alpha)
//        return (red,blue,green)
//    }
//}

//extension NSColor{
//    var rgb:(red:CGFloat,green:CGFloat,blue:CGFloat){
//        let colorSpace = usingColorSpace(.extendedSRGB) ?? .init(red:1,green:1,blue:1,alpha:1)
//        var red:CGFloat,green:CGFloat = 0 ,blue:CGFloat = 0 ,alpha:CGFloat = 0
//        colorSpace.get(red:&red,green:&green,blue:&blue,alpha:&alpha)
//        return (red,blue,green)
//    }
//}
