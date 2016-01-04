//
//  AKBandPassFilter.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's BandPassFilter Audio Unit
///
/// - parameter input: Input node to process
/// - parameter centerFrequency: Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
/// - parameter bandwidth: Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
///
public class AKBandPassFilter: AKNode {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_BandPassFilter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU = AudioUnit()

    /// Required property for AKNode containing the output node
    public var avAudioNode: AVAudioNode

    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()

    private var input: AKNode?
    private var mixer: AKMixer
    
    /// Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
    public var centerFrequency: Double = 5000 {
        didSet {
            if centerFrequency < 20 {
                centerFrequency = 20
            }            
            if centerFrequency > 22050 {
                centerFrequency = 22050
            }
            AudioUnitSetParameter(
                internalAU,
                kBandpassParam_CenterFrequency,
                kAudioUnitScope_Global, 0,
                Float(centerFrequency), 0)
        }
    }

    /// Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    public var bandwidth: Double = 600 {
        didSet {
            if bandwidth < 100 {
                bandwidth = 100
            }            
            if bandwidth > 12000 {
                bandwidth = 12000
            }
            AudioUnitSetParameter(
                internalAU,
                kBandpassParam_Bandwidth,
                kAudioUnitScope_Global, 0,
                Float(bandwidth), 0)
        }
    }
    
    /// Dry/Wet Mix (Default 50)
    public var dryWetMix: Double = 50.0 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            inputGain?.gain = 1 - dryWetMix / 100.0
            effectGain?.gain = dryWetMix / 100.0
        }
    }
    
    private var inputGain: AKGain?
    private var effectGain: AKGain?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isPlaying: Bool {
        return isStarted
    }

    /// Tells whether the node is not processing (ie. stopped or bypassed)
    public var isStopped: Bool {
        return !isStarted
    }

    /// Tells whether the node is not processing (ie. stopped or bypassed)
    public var isBypassed: Bool {
        return !isStarted
    }

    /// Initialize the band pass filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter centerFrequency: Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
    /// - parameter bandwidth: Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    ///
    public init(
        var _ input: AKNode,
        centerFrequency: Double = 5000,
        bandwidth: Double = 600) {
            self.input = input
            self.centerFrequency = centerFrequency
            self.bandwidth = bandwidth
            
            inputGain = AKGain(input, gain: 0)
            mixer = AKMixer(inputGain!)

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            self.avAudioNode = internalEffect
            AKManager.sharedInstance.engine.attachNode(internalEffect)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit

            effectGain = AKGain(self, gain: 1)
            mixer.connect(effectGain!)
            self.avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU, kBandpassParam_CenterFrequency, kAudioUnitScope_Global, 0, Float(centerFrequency), 0)
            AudioUnitSetParameter(internalAU, kBandpassParam_Bandwidth, kAudioUnitScope_Global, 0, Float(bandwidth), 0)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            inputGain?.gain = 0
            effectGain?.gain = 1
            isStarted = true
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func play() {
        start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            inputGain?.gain = 1
            effectGain?.gain = 0
            isStarted = false
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func bypass() {
        stop()
    }
}
