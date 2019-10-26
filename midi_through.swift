import Foundation
import CoreMIDI

func unbridgeMutable<T : AnyObject>(ptr : UnsafeMutablePointer<Void>) -> T {
    return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
}

func MyMIDIReadProc(packetList: UnsafePointer<MIDIPacketList>,
                    refCon:UnsafeMutablePointer<Void>) {
    var packetList = np.memory
    let outRef: MIDIEndpointRef = unbridgeMutable(refCon)
    for packet in packetList.packets:
          for b in packet.data:
    kronos.receiveMIDI(packetList)
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
          myClientRef, s, MIDIReadProc(COpaquePointer([MyMIDIReadProc])), self.kronos, &self.myInPort
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
