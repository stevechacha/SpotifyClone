//
//  Player.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


//
//  Player.swift
//  SpotifyClone
//
//  Created by AlkanBurak on 18.11.2020.
//

import SwiftUI

struct Player: View {
    @Environment(\.presentationMode) var presentationMode
    @State var shuffle = false
    @State var repeatButton = true
    @State var play = true
    @State var time: Double = 50
    @State var like = false
    @State var devices = true
    @State var blur = false


    var albumImage : String
    var songName : String
    var colors : [Color : Color] = [Color.init(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)):Color.gray , Color.init(#colorLiteral(red: 0.5325785279, green: 0.3929539323, blue: 0.2947138846, alpha: 1)):Color.init(#colorLiteral(red: 0.2959476709, green: 0.2161997557, blue: 0.1564876735, alpha: 1)),Color.init(#colorLiteral(red: 0.6307879686, green: 0.04571723193, blue: 0.1284509301, alpha: 1)):Color.init(#colorLiteral(red: 0.3453397155, green: 0.03347708657, blue: 0.07076438516, alpha: 1)),Color.init(#colorLiteral(red: 0.1489986479, green: 0.1490316391, blue: 0.1489965916, alpha: 1)):Color.init(#colorLiteral(red: 0.08233881742, green: 0.08236103505, blue: 0.08233740181, alpha: 1))]
    var backgroundColor : Color
    var backgroundColor2 : Color
    
    init(songName : String, albumImage : String){
        self.songName = songName
        self.albumImage = albumImage
        backgroundColor = colors.randomElement()!.key
        backgroundColor2 = colors[backgroundColor]!
    }
    
    var body: some View {
        ZStack{
            LinearGradient.init(gradient: Gradient(colors: [backgroundColor , backgroundColor2]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack{
                HStack{
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down").font(.body)
                            .foregroundColor(.white)
                    }).frame(width: 60, height: 60)
                    Spacer()
                    Text("\(songName)")
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 30)
                        .onTapGesture {
                            withAnimation {
                                blur.toggle()
                            }
                        }
                }
                Spacer()
                Image("\(albumImage)").resizable()
                    
                    .padding(.all, 10)
                VStack{
                HStack{
                    VStack(alignment: .leading){
                        Text("Ceviz Ağacı")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold().padding(.leading , 3)
                        Text("Cem Karaca")
                            .padding([.leading , .top] , 3)
                            .foregroundColor(.white).opacity(0.8)
                            .font(.callout)
                    }
                    Spacer()
                    Button(action: {
                        like.toggle()
                    }, label: {
                        Image(systemName: like ? "heart.fill" : "heart").foregroundColor(like ? .green :.white )
                            .font(.system(size: 20)).animation(.default)
                    })
                }.padding([.leading,.trailing,.top],20)
                    Slider(value: $time, in: 0...70 )
                        .accentColor(.white)
                        .padding([.trailing,.leading , .bottom] , 20)
                    HStack{
                        Text("0:00").foregroundColor(.white).offset(x: 20, y: -30)
                        Spacer()
                        Text("-3:41").foregroundColor(.white).offset(x: -20, y: -30)

                    }
                    
                           HStack{
                    Button(action: {
                        shuffle.toggle()
                    }, label: {
                        Image(systemName: "shuffle").foregroundColor(shuffle ? .green : .white)
                    })
                    Spacer()
                    Button(action: {
                    }, label: {
                        Image(systemName: "backward.end.fill").resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.white)
                            
                    })
                    
                    Button(action: {
                        play.toggle()
                    }, label: {
                        Image(systemName: play ? "play.circle.fill" : "pause.circle.fill").resizable()
                            .frame(width: 60, height: 60, alignment: .center)
                            .foregroundColor(.white)
                    }).padding([.trailing,.leading], 50)
                    
                    Button(action: {
                    }, label: {
                        Image(systemName: "forward.end.fill").resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.white)
                            
                    })
                    Spacer()
                    Button(action: {
                        repeatButton.toggle()
                    }, label: {
                        Image(systemName: "repeat")
                            .foregroundColor(repeatButton ? .green : .white)
                    })
                }.padding([.trailing,.leading , .bottom] , 20)
                }
                HStack{
                    Image(systemName: "hifispeaker").foregroundColor(devices ? .green : .white).onTapGesture {
                        devices.toggle()
                    }
                    Spacer()
                    Image(systemName: "text.badge.plus").foregroundColor(.white)
                }.padding()
            }.blur(radius: blur ? 40.0 : 0)
            if blur {
                blurPage
            }
        }
    }
    var blurPage: some View{
        ZStack{
            Color.clear
            VStack{
                ScrollView(.vertical){
                VStack{
                Image(albumImage)
                    .resizable()
                    .frame(width: 160, height: 160)
                    .padding()
                Text("Ceviz Ağacı")
                    .foregroundColor(.white)
                    .bold()
                Text(songName).padding([.top, .bottom] , 3)
                    .foregroundColor(.white)
                    .opacity(0.6)
                    .font(.headline)
                HStack{
                    VStack{
                        Button(action: {
                        shuffle.toggle()
                    }, label: {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20, weight: Font.Weight.thin))
                            .foregroundColor(shuffle ? .green : .white)
                    })
                        Text("Shuffle").foregroundColor(.white).padding(.top , 2 )
                    }.frame(width: 100, height: 100, alignment: .center)
                    VStack{
                    Button(action: {
                        repeatButton.toggle()
                    }, label: {
                        Image(systemName: "repeat")
                            .font(.system(size: 20, weight: Font.Weight.thin))
                            .foregroundColor(repeatButton ? .green : .white)
                    })
                        Text("Repeat").foregroundColor(.white).padding(.top , 2 )
                    }.frame(width: 100, height: 100, alignment: .center)
                    VStack{
                        Image(systemName: "text.badge.plus")
                            .font(.system(size: 20, weight: Font.Weight.thin))
                            .foregroundColor(.white)
                        Text("Go to queue").padding(.top , 2 )
                            .foregroundColor(.white)
                    }.frame(width: 100, height: 100, alignment: .center)
                }.padding()
                }.padding(.top , 200)
                    
                    BlurPageButton(image: "heart", text: "Like")
                    BlurPageButton(image: "minus.circle", text: "Hide song")

                    BlurPageButton(image: "square.and.arrow.up", text: "Share")
                    BlurPageButton(image: "smallcircle.circle", text: "View album")
                    BlurPageButton(image: "flag", text: "Report explicit content")
                    BlurPageButton(image: "person.2", text: "Song Credit")
                    BlurPageButton(image: "moon", text: "Sleep timer")




            }
                Button(action: {
                    withAnimation {
                        blur.toggle()
                    }
                }, label: {
                    ZStack{
                        Rectangle().frame(width: UIScreen.main.bounds.width, height: 40)
                            .foregroundColor(.clear)
                            .blur(radius: 5.0)
                        Text("Close").foregroundColor(.white)
                    }
                })
            }
        }
    }
}
struct BlurPageButton : View {
        var image : String
        var text : String
    var body: some View{
            HStack{
                Image(systemName: image)
                    .font(.system(size: 25, weight: Font.Weight.thin))
                    .foregroundColor(.white)
                Text(text).font(.title3).bold()
                    .foregroundColor(.white)
                Spacer()
                
            }.padding()
        
    }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
        Player(songName: "Anadolu Rock", albumImage: "cemKaraca")
    }
}
