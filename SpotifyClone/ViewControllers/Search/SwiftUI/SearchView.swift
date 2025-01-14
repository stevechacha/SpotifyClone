//
//  SearchView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var isSearchPageOpen = false
    let categories = ["Podcast":"Listeler","Yeni Çıkanlar":"Radyo","Keşfet":"Hip Hop","Evde":"Chill","Fitness":"Romantik","Uyku":"Klasik" ]
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text("Search").font(.largeTitle).foregroundColor(.white).bold()
                    Spacer()
                }.padding()
                Button(action: {}, label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: 382, height: 43.5)
                                .cornerRadius(7)
                                .onTapGesture( perform: {
                                self.isSearchPageOpen.toggle()
                                }).fullScreenCover(isPresented: $isSearchPageOpen, content: {
                                    Search()
                                })
                            HStack{
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .font(.system(size: 25))
                                Text("Artist, songs, or podcast").foregroundColor(.black).padding(.leading, 5)
                                Spacer()
                            }.offset(x: 25)
                    }
                })
                ScrollView(.vertical, showsIndicators: false){
                VStack{
                    HStack{
                        Text("Your top genres")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding([.top , .trailing , .leading])
                    Category(color1: .blue,text1: "Pop" ,color2: .secondary, text2: "Rock")
                    Category(color1: .red,text1: "Caz" ,color2: .green, text2: "Folk ve Akustik")
                }
                    HStack{
                        Text("Browse all")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding()
                    ForEach(categories.keys.sorted(), id: \.self) { cat in
                        Category(color1: .red, text1: cat, color2: .blue, text2: categories[cat]!)
                    }
                    
                }
            }
            
            
        }
    }
}
struct Search: View {
    @Environment(\.presentationMode) var presentationMode

    init() {
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9249785959)
        UITextField.appearance().backgroundColor = #colorLiteral(red: 0.1411563158, green: 0.1411880553, blue: 0.1411542892, alpha: 1)
        UITextField.appearance().textColor = .white
    }
    
    @State private var src = ""
    var body: some View{
        NavigationView{
            ZStack{
                Color.init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9545430223)).edgesIgnoringSafeArea(.all)
                
                    .navigationBarItems(trailing: HStack{
                                            TextField("Ara", text: $src)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .frame(width: UIScreen.main.bounds.width - 150).accentColor(.green)
                                            Button(action: {
                                                presentationMode.wrappedValue.dismiss()
                                            }, label: {
                                                Text("İptal Et")
                                                    .foregroundColor(.white)
                                                    .fontWeight(.medium)
                                            }).padding(.trailing)
                                            Button(action: {}, label: {
                                                Image(systemName: "camera")
                                                    .foregroundColor(.white)
                                            })})

                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}




struct Category: View {
    var color1: Color
    var text1: String
    var color2: Color
    var text2: String

    var body: some View{
        ZStack{
            HStack{
                ZStack{
                    Rectangle()
                        .foregroundColor(color1)
                        .frame(height:103)
                        .cornerRadius(5)
                        .padding()
                        
                   VStack{
                    HStack{
                        Text(text1).foregroundColor(.white)
                            .fontWeight(.bold).font(.title3)
                        Spacer()
                    }.padding(.leading, 27.0).padding(.top, 12.0)
                    
                    Spacer()

                   }.frame(height:103)

                }
                
                ZStack{
                    Rectangle()
                        .foregroundColor(color2)
                        .frame(height:103)
                        .cornerRadius(5)
                        .padding()
                   VStack{
                    HStack{
                        Text(text2).foregroundColor(.white)
                            .fontWeight(.bold).font(.title3)
                        Spacer()
                    }.padding(.leading, 27.0).padding(.top, 12.0)
                    
                    Spacer()

                   }.frame(height:103)

                }
                
            }
        }
    }
}

