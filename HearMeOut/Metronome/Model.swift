//
//  Model.swift
//  MetronomoForBlind
//
//  Created by Marta Michelle Caliendo on 21/02/23.
//

import AVFoundation

class Metronome: ObservableObject {
    
    var bpm: Float = 60.0 {
        didSet { bpm = min(240.0,max(20.0,bpm)) }
    }
    
    var enabled: Bool = false {
        didSet {
            if enabled { start() } else { stop() }
        }
    }
    
    enum Italians: String, CaseIterable {
///        case nullo = "NULLO"
        case larghissimo = "LARGHISSIMO"
        case lento = "LENTO"
        case larghetto = "LARGHETTO"
        case andante = "ANDANTE"
        case sostenuto = "SOSTENUTO"
        case comodo = "COMODO"
        case maestoso = "MAESTOSO"
        case moderato = "MODERATO"
        case allegretto = "ALLEGRETTO"
        case animato = "ANIMATO"
        case allegro = "ALLEGRO"
        case allegroAssai = "ALLEGRO ASSAI"
        case allegroVivace = "ALLEGRO VIVACE"
        case vivace = "VIVACE"
        case presto = "PRESTO"
        case prestissimo = "PRESTISSIMO"
///        case illimitato = "ILLIMITATO"

        func description(by BPM: Float) -> Self {
            if BPM.isBetween(20, and: 30) { return .larghissimo }
            else if BPM.isBetween(30, and: 53) { return .lento }
            else if BPM.isBetween(53, and: 66) { return .larghetto }
            else if BPM.isBetween(66, and: 76) { return .andante }
            else if BPM.isBetween(76, and: 80) { return .sostenuto }
            else if BPM.isBetween(80, and: 84) { return .comodo }
            else if BPM.isBetween(84, and: 88) { return .maestoso }
            else if BPM.isBetween(88, and: 108) { return .moderato }
/// ----------------------------------------------------------------------------
            else if BPM.isBetween(108, and: 120) { return .allegretto }
            else if BPM.isBetween(120, and: 132) { return .animato }
            else if BPM.isBetween(132, and: 144) { return .allegro }
            else if BPM.isBetween(144, and: 152) { return .allegroAssai }
            else if BPM.isBetween(152, and: 160) { return .allegroVivace }
            else if BPM.isBetween(160, and: 184) { return .vivace }
            else if BPM.isBetween(184, and: 201) { return .presto }
            else { return .prestissimo } /// else if 201 <= BPM && BPM < 240
        }
    }
    
//    enum Italians: CaseIterable {
//        case larghissimo(bpmRange: Range<Double> = 20..<30, id: String = "LARGHISSIMO")
//        case lento(bpmRange: Range<Double> = 30..<53, id: String = "LENTO")
//        case larghetto(bpmRange: Range<Double> = 53..<66, id: String = "LARGHETTO")
//
//        static var allCases: [Metronome.Italians] = [larghissimo()]
//
//        func description(with BPM: Double) -> String? {
//            switch self {
//            case let .larghissimo(bpmRange, id): if bpmRange.contains(BPM) { return id }
//            case let .lento(bpmRange, id): if bpmRange.contains(BPM) { return id }
//            case let .larghetto(bpmRange, id): if bpmRange.contains(BPM) { return id }
//            }
//
//            return nil
//        }
//    }
    
    var onTick: ((_ nextTick: DispatchTime) -> Void)?
    var nextTick: DispatchTime = DispatchTime.distantFuture

    let player: AVAudioPlayer = {
        do {
            let soundURL = Bundle.main.url(forResource: "beatUp", withExtension: "wav")!
            let soundFile = try AVAudioFile(forReading: soundURL)
            let player = try AVAudioPlayer(contentsOf: soundURL)
            return player
        } catch {
            print("Oops, unable to initialize metronome audio buffer: \(error)")
            return AVAudioPlayer()
        }
    }()
    

    private func start() {
        print("Starting metronome, BPM: \(bpm)")
        player.prepareToPlay()
        nextTick = DispatchTime.now()
        tick()
    }

    private func stop() {
        player.stop()
        print("Stoping metronome")
    }

    private func tick() {
        guard
            enabled,
            nextTick <= DispatchTime.now()
            else { return }

        let interval: TimeInterval = 60.0 / TimeInterval(bpm)
        nextTick = nextTick + interval
        DispatchQueue.main.asyncAfter(deadline: nextTick) { [weak self] in // [unowned self] in
            print("reproduce")
            self?.tick()
        }

        player.play(atTime: interval)
        onTick?(nextTick)
    }
}

// TODO: Add to Utility Extensions

extension Float {
    func isBetween(_ lowerBound: Self, and upperBound: Self) -> Bool {
        return lowerBound <= self && self < upperBound
    }
}

