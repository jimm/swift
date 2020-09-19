#!/usr/bin/env swift

import Foundation
import CoreMIDI

class Synth {
    let inPort: MIDIEndpointRef
    let outPort: MIDIEndpointRef

    init(inputPort: MIDIEndpointRef, outputPort: MIDIEndpointRef) {
        inPort = inputPort
        outPort = outputPort
    }
}

func unbridgeMutable<T : AnyObject>(ptr: UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func MyMIDIReadProc(packetList: UnsafePointer<MIDIPacketList>,
                    refCon:UnsafeMutableRawPointer) {
    var synth: Synth = unbridgeMutable(ptr: refCon)
    var packet: UnsafeMutablePointer<MIDIPacket> = packetList.pointee.packet
    for i in 0..<packetList.pointee.numPackets {
        let bytes = [UInt8](UnsafeBufferPointer(start: &packet.data.0, count: MemoryLayout.size(ofValue: packet.data)))
        for byte in bytes {
            // TODO
        }
        packet = MIDIPacketNext(packet)
    }
    synth.receiveMIDI(packetList)
}

class Main {
    var list = false
    var channel: Int = 0
    var inPort: Int?
    var outPort: Int?
    var myClientRef: MIDIClientRef
    var myInRef: MIDIPortRef
    var myOutRef: MIDIEndpointRef

    init() {
    }


    func run(channel: Int) {
        let editor = Editor(kronos: self.kronos)

        print("Type 'q' quit.")
        while true {
            print("midi_through> ", terminator: "")
            fflush(stdout)
            if readLine() == "q" {
                return
            }
        }
    }

    func initMidi() {
        var s: CFString

        s = "MIDI Through"
        var err = MIDIClientCreate(s, 0, 0, &self.myClientRef)
        if err != 0 {
            print("MIDIClientCreate error: \(err)", err)
        }

        myInEndRef = MIDIGetDestination(0)
        myOutEndRef = MIDIGetSource(0)
        if myInEndRef == 0 {
            print("error getting input destination 0")
        }
        if myOutEndRef == 0 {
            print("error getting output destination 0")
        }

        s = "MIDI Through Input"
        err = MIDIInputPortCreate(
          myClientRef, s, MIDIReadProc(COpaquePointer([MyMIDIReadProc])), &self.synth, &self.myInPort
        )
        if err != 0 {
            print("MIDIInputPortCreate error: \(err)")
        }

        // Connect Kronos output to my input
        // 0 is conn ref_con
        err = MIDIPortConnectSource(myInPort, myOutEndRef, 0)
        if err != 0 {
            print("MIDIPortConnectSource error: \(err)")
        }
    }

    func cleanup() {
        var err = MIDIPortDisconnectSource(myInPort, myOutEndRef)
        if err != 0 {
            print("MIDIPortDisconnectSource error: \(err)")
        }

        err = MIDIPortDispose(myInPort)
        if err != 0 {
            print("MIDIPortDispose error: \(err)")
        }
    }

    func main() {
        do {
            try {
                self.initMIDI()
                self.run()
            }
        } catch {
            self.cleanup()
        }
    }
}

Main().main()
