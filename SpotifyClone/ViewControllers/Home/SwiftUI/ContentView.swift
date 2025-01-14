//
//  ContentView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


import SwiftUI



struct ContentView: View {
    
        init() {
            let navBarAppearance = UINavigationBar.appearance()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.barTintColor = .clear
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    
    
    var songs: [String:String] = ["penthouse":"Penthouse" , "Anadolu_Rock":"Anadolu Rock","cemKaraca":"Cem Karaca","Türkce_90lar":"Türkçe 90'lar"]
    var topSongs: [String:String] = ["penthouse":"Penthouse" , "Anadolu_Rock":"Anadolu Rock" , "Türkce_90lar":"Türkçe 90'lar"]
    
    
    
    var body: some View {
        ZStack{
            LinearGradient.init(gradient: Gradient(colors: [.init(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.7745838351, alpha: 0.5)), .black , .black, .black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: false){
                    ZStack{
                        LinearGradient.init(gradient: Gradient(colors: [.init(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.7745838351, alpha: 1)) , .black, .black, .black, .black, .black, .black]), startPoint: .topLeading, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                VStack{
                    
                    HStack{
                        Spacer()
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 20 , height: 20)
                            .foregroundColor(.white)
                            .padding(.trailing , 25).padding(.top , 20)
                    }
                    HStack{
                        Text("Good Morning").font(.title).foregroundColor(.white).bold()
                        Spacer()
                    }.padding(.leading).frame(width: UIScreen.main.bounds.width)

                    HStack{
                        VStack{
                            ForEach(topSongs.keys.sorted() , id: \.self){ song in
                                TopAlbum(image: song, songName: songs[song]!)
                                    .padding(.trailing, 7)
                            }
                        }
                        VStack{
                            ForEach(topSongs.keys.sorted() , id: \.self) { song in
                                TopAlbum(image: song, songName: songs[song]!)
                                    .padding(.trailing, 7)
                            }
                        }
                    }.padding().frame(width: UIScreen.main.bounds.width)
                    VStack(alignment: .leading){
                        HStack{
                            Text("Recently played").font(.title2).foregroundColor(.white).bold()
                            Spacer()
                    }.padding()
                        ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                ForEach(songs.keys.sorted() , id: \.self) { song in
                                    Song(image: song, songName: songs[song]!)
                                        .padding(.trailing, 7)
                                }
                                    ForEach(songs.keys.sorted() , id: \.self) { song in
                                        Song(image: song, songName: songs[song]!)
                                            .padding(.trailing, 7)
                                    }
                            }
                            .padding(.leading)
                                
                            }
                    }.frame(width: UIScreen.main.bounds.width)
                    
                    VStack{
                        HStack {
                            Image("cemKaraca")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            VStack(alignment:.leading) {
                                Text("FOR FANS OF")
                                    .fontWeight(.ultraLight)
                                    .font(.system(size: 15))
                                    .foregroundColor(.init(.white))
                                    .opacity(0.8).offset(x: 1, y: 3)
                                Text("Cem Karaca")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                ForEach(songs.keys.sorted() , id: \.self) { song in
                                    Song(image: song, songName: songs[song]!)
                                        .padding(.trailing, 7)
                            }
                        }
                        }
                    }.padding(.top, 20).padding()
                    }
                    
                    }.frame( height: UIScreen.main.bounds.height )
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        
        }
    }


struct Song: View {
    @State private var isPlayerOpen = false
    var image: String
    var songName: String
    var body: some View{
        VStack(alignment: .leading){
            Image(image)
        .resizable()
        .frame(width: 124, height: 124)
        Text(songName)
            .foregroundColor(.white).fontWeight(.medium).font(.system(size: 15))
            }.onTapGesture {
                isPlayerOpen.toggle()
        }
        .fullScreenCover(isPresented: $isPlayerOpen, content: {
            Player(songName: songName, albumImage: image)
        })
    }
}

struct TopAlbum: View {
    @State private var isPlayerOpen = false
    var image: String
    var songName: String
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.init(#colorLiteral(red: 0.1686044633, green: 0.1686406434, blue: 0.1686021686, alpha: 1)))
                .opacity(0.8)
                .frame(width: 187, height: 56)
                .cornerRadius(5)
            
            HStack{
                Image(image).resizable()
                    .frame(width: 56, height: 56)
                    .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                    //.offset(x: -66, y: 0)
                Spacer()
                Text(songName)
                    .foregroundColor(.white).fontWeight(.semibold).font(.system(size: 15))
                Spacer()
                Spacer()
                Spacer()
            }.frame(maxWidth:187 ,  maxHeight: 56)
                .onTapGesture {
                    isPlayerOpen.toggle()
                }
                .fullScreenCover(isPresented: $isPlayerOpen, content: {
                    Player(songName: songName, albumImage: image)
                })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
