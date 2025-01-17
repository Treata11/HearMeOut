//
//  ScoreView.swift
//  ReaderMusic
//
//  Created by Marta Michelle Caliendo on 23/02/23.
//

import SwiftUI

enum FocusModel: Hashable {
    case clef(id: Int)
    case beat(id: Int)
    case note(id: Int)
}

struct ScoreView: View {
    @State private var isNavigated: Bool = false
    @State private var isActive: Bool = false
    
    @StateObject private var vm: ScoreViewModel = ScoreViewModel.shared
    
    @State private var clef: [ClefScore] = []
    @State private var beatType: BeatType = .none
    @State private var focusArray: [FocusModel] = [FocusModel.note(id: 0), FocusModel.note(id: 1)]
    @State private var array: [String] = ["uno", "due"]
    
    @AccessibilityFocusState var focus: FocusModel?
    
    @State private var indexStaff: Int = 0
    @State private var showRecording: Bool = false
    
    let fileName: String?
    
//    let scoreData : Score
    private let columns: [GridItem] = [
        GridItem(.fixed(45)),
        GridItem(.fixed(45)),
        GridItem(.fixed(45)),
        GridItem(.fixed(45)),
        GridItem(.fixed(45)),
//        GridItem(.fixed(50)),
    ]
    let url: URL
    
    init(url: URL, fileName: String? = nil) {
//        self._vm = StateObject(wrappedValue: ScoreViewModel(url: url))
//        self.scoreData = ScoreStore().retrieveScore(path: url)
        self.url = url
        self.fileName = fileName
    }
    
    
    var body: some View {
        VStack{
            contentLayer
                .padding(.bottom, 40)
                .padding(.top, 40)
            Spacer()
            Button {
                showRecording.toggle()
            } label: {
                Capsule()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.blue)
                    .frame(width: 200, height: 30)
                    .overlay {
                        Text("Your recordings")
                    }
                    .background(
                        Color(uiColor: .systemGray5)
                            .clipShape(Capsule())
                    )
                
            }
            .padding(.bottom, 60)
            .sheet(isPresented: $showRecording) {
                RecordingView(fileName: fileName ?? "")
            }

            PreviewsNextButton(vm: vm)
        }
        .navigationTitle("Musical score")//scoreData.movementTitle ?? "Musical Score")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isNavigated.toggle()
            } label: {
                Text("Settings")
            }

        }
        .sheet(isPresented: $isNavigated) {
            SettingsView(scoreViewModel: vm)
        }
        .onChange(of: vm.measureIndex) { measure in
            if let score = vm.musicScore {
                for _ in  score.part.measure[vm.measureIndex].staffGroup {
                    if !score.part.measure[vm.measureIndex].attributes.clef.isEmpty {
                        clef = score.part.measure[vm.measureIndex].attributes.clef
                    }
                    if score.part.measure[vm.measureIndex].attributes.time.beatType != .none {
                        beatType = score.part.measure[vm.measureIndex].attributes.time.beatType
                    }
                }
            }
        }
        .onAppear {
            vm.decodeScoreFrom(url)
            if let score = vm.musicScore {
                for _ in  score.part.measure[vm.measureIndex].staffGroup {
                    if !score.part.measure[vm.measureIndex].attributes.clef.isEmpty {
                        clef = score.part.measure[vm.measureIndex].attributes.clef
                    }
                    if score.part.measure[vm.measureIndex].attributes.time.beatType != .none {
                        beatType = score.part.measure[vm.measureIndex].attributes.time.beatType
                    }
                }
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                focus = focusArray[0]
//            }
        }
    }
    
    @ViewBuilder
    var contentLayer: some View {
        if let score = vm.musicScore {
            
            //qui prende ogni pentagramma per la battuta nell'indice
            ForEach(Array(score.part.measure[vm.measureIndex].staffGroup.enumerated()), id: \.offset) { index, staff in
                HStack {
                    
                    if !clef.isEmpty {
                        if vm.checkStafSelection {
                            Image(clef[index].sign.rawValue)
                                .resizable()
                                .frame(width: 50, height: 80)
    //                            .accessibilityFocused($focus, equals: focusArray[0])
                                .accessibility(sortPriority: 2)
                        } else {
                            if let index = vm.indexCheckStaffActive {
                                Image(clef[index].sign.rawValue)
                                    .resizable()
                                    .frame(width: 50, height: 80)
        //                            .accessibilityFocused($focus, equals: focusArray[0])
                                    .accessibility(sortPriority: 2)
                            }
                            
                        }
                        
                    }
                    
                    if beatType != .none {
                        beatTypeView(beatType)
                            .accessibility(sortPriority: 1)
                    }
   
                    //di ogni pentagramma
                    VStack(alignment: .leading, spacing: 10) {
                        //cicla per tutte le voci (gruppi) e crea le note/accordi
                        ForEach(staff.group) { group in
//                            HStack(spacing: 20) {
                            LazyVGrid(columns: columns, alignment: .center, spacing: nil) {
                                ForEach(group.note, id: \.self) { notes in
                                    PitchView(notes: notes)
                                        .accessibility(sortPriority: 0)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.vertical, .trailing])
                                
//                            }
                            //                        .accessibilityElement(children: .combine)
                        }
                    }
                }
//                .accessibility(addTraits: .notEnabled)
                .accessibilityChildren {
                    Text(vm.accessibilityString[index])
                        .accessibility(hidden: vm.isPlaying ? true : false)
                        
                }
                
//                .accessibilityElement(children: .contain)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .frame(width: 800, height: 150)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(5)
//                .shadow(color: Color(UIColor.systemGray5) , radius: 10)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func beatTypeView(_ beatType: BeatType) -> some View {
        let fullString = beatType.rawValue.components(separatedBy: "/")
        let numerator = fullString[0]
        let denominator = fullString[1]
        VStack(spacing: 1.5) {
            Text(numerator)
                .font(.title2)
            Rectangle()
                .frame(width: 20, height: 1.5)
            Text(denominator)
                .font(.title2)
        }
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(beatType.description))
        .padding(.trailing)
    }
    
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
//            ScoreView(url: Bundle.main.url(forResource: "MozartPianoSonata" , withExtension: "musicxml")!)
            ScoreView(url: Bundle.main.url(forResource: "Schubert" , withExtension: "musicxml")!)
        }
    }
}

struct MyContent: View {
    let title: String
    let image: String
    let notes: String
    
    var body: some View {
        VStack{
            Text(title)
                .font(.title2)
                .padding(.trailing, 300)
            HStack {
                Image(image)
                    .accessibilityRemoveTraits(.isImage)
                    .padding(.trailing, 5)
                Text(notes)
                    .font(.title)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("Backgroundcolor"))
                    .frame(width: 380, height: 100))
                    .padding(.bottom, 20)
        }
    }
}
