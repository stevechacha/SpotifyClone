//
//  Library.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


import SwiftUI


struct Library: View {

    var subCategorys : [String]
    @State var currentSubCategoryIndex : Int = 0
    @State var indicatorOffset : CGFloat = 0
    var body: some View {
        HStack{
            subCategory(index: 0, parent: self)
            subCategory(index: 1, parent: self)
            subCategory(index: 2, parent: self)
            Spacer()
        }
        
    }
    
    struct subCategory: View{
        var index: Int
        var parent: Library
        var body: some View{
            VStack{
                Text(parent.subCategorys[index])
                    .font(.headline)
                    .foregroundColor(parent.currentSubCategoryIndex == index ? .white : .secondary)
                    .onTapGesture {
                        withAnimation(.easeIn,{
                            self.parent.currentSubCategoryIndex = self.index
                        })
                    }
                Rectangle()
                    .frame(height: 2)
                    .offset(x: parent.indicatorOffset)
                    .foregroundColor(parent.currentSubCategoryIndex == index ? .green : .clear)
                    .animation(.none)
            }.fixedSize().padding(.leading)
        }
    }
}


struct PlayListView: View {
    var image: String
    var songName : String
    @Binding var presentPage : String
    var body: some View{

            if presentPage == "music"{
            HStack{
            Image(image).resizable()
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading){
                    Text(songName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("by Spotify")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding([.leading])
            }
            if presentPage == "podcast"{
                ZStack{
                    Rectangle()
                        .foregroundColor(.init(Color.init(#colorLiteral(red: 0.1568410099, green: 0.1568752527, blue: 0.1568388343, alpha: 1))))
                        .opacity(0.8)
                        .cornerRadius(8.0)
                    VStack{
                            HStack{
                        Image(image)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .cornerRadius(5)
                        VStack(alignment: .leading){
                                Text(songName)
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("by Spotify")
                            .foregroundColor(.white)
                            .opacity(0.7)
                            .font(.subheadline)
                        }
                        Spacer()
                                Image(systemName: "ellipsis").foregroundColor(.white)
                    }.padding()
                        HStack{
                            Image(systemName: "play.circle.fill").font(.system(size: 25))
                                .foregroundColor(.white)
                            Text("7 ARA 1SA. 19DK." ).font(.system(size: 10)).foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .font(.system(size: 25, weight: Font.Weight.thin))
                                .foregroundColor(.white)
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 25, weight: Font.Weight.thin))
                                .foregroundColor(.white)
                            Image(systemName: "checkmark")
                                .font(.system(size: 25, weight: Font.Weight.thin))
                                .foregroundColor(.white)
                        }.padding()
                        
                        }
                }
                .frame(width: UIScreen.main.bounds.width - 30, height: 150, alignment: .center).padding([.top,.bottom])
            }
    }
}


struct LibraryPage : View {
    
    var songs: [String:String] = ["penthouse":"Penthouse" , "Anadolu_Rock":"Anadolu Rock","cemKaraca":"Cem Karaca","Türkce_90lar":"Türkçe 90'lar"]
    @State var CategoryIndex : Int
    @State var subCategorys = ["Playlists", "Albums", "Artists"]
    @State var page = "music"

    var body: some View{
        ZStack{
            Color.init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).edgesIgnoringSafeArea(.all)

            VStack{
                HStack(spacing: 20){
            Text("Music")
                .font(.largeTitle).bold()
                .foregroundColor(self.CategoryIndex == 0 ? .white : .secondary)
                .onTapGesture {
                    page = "music"
                    withAnimation(.easeIn,{
                        subCategorys = ["Playlists", "Albums", "Artists"]
                        self.CategoryIndex = 0
                    })
                }
            Text("Podcasts")
                .font(.largeTitle).bold()
                .foregroundColor(self.CategoryIndex == 1 ? .white : .secondary)
                .onTapGesture {
                    page = "podcast"
                    withAnimation(.easeIn,{
                        self.CategoryIndex = 1
                        subCategorys = ["Episodes", "Downloads", "Shows"]
                    })
                }
            Spacer()
        }.padding([.leading, .top])
                Library(subCategorys: subCategorys).padding(.top)
                ScrollView(.vertical, showsIndicators: true, content: {
                            ForEach(songs.keys.sorted() , id: \.self) { song in
                                PlayListView(image: song, songName: songs[song]!, presentPage: $page)
                            }
                    ForEach(songs.keys.sorted() , id: \.self) { song in
                        PlayListView(image: song, songName: songs[song]!, presentPage: $page)
                    }
                })
            }
            
        }
    }
    
}
struct Library_Previews: PreviewProvider {

    static var previews: some View {
        LibraryPage(CategoryIndex: 0)
        //Playlist(image: "cemKaraca", songName: "sdsad", presentPage: "podcast")
    }
}
