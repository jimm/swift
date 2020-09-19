#!/usr/bin/env swift

import CoreMIDI

func getStringProperty(propertyName: CFString, midiObject: MIDIObjectRef) -> String {
    var property: Unmanaged<CFString>?
    let status = MIDIObjectGetStringProperty(midiObject, propertyName, &property)
    defer { property?.release() }
    if status != noErr {
        return ""
    }
    let cfstring = Unmanaged.fromOpaque(
      property!.toOpaque()).takeUnretainedValue() as CFString
    if CFGetTypeID(cfstring) == CFStringGetTypeID() {
        return cfstring as String
    }

    return ""
}

func printEndpoint(deviceNumber: Int, endpointRef: MIDIEndpointRef) {
    print(NSString(format:"%3ld: ", deviceNumber), terminator: "")
    let name = getStringProperty(propertyName: kMIDIPropertyName, midiObject: endpointRef)
    let displayName = getStringProperty(propertyName: kMIDIPropertyDisplayName, midiObject: endpointRef)
    print("\(name), \(displayName)")
}

func printEndpoints(title: String, counter: ()->Int, getter: (Int)->MIDIEndpointRef) {
    print("\(title):")
    for i in 0..<counter() {
        printEndpoint(deviceNumber: i, endpointRef: getter(i))
    }
}

func printSourcesAndDestinations() {
    printEndpoints(
      title: "Sources",
      counter: MIDIGetNumberOfSources,
      getter: MIDIGetSource
    )
    printEndpoints(
      title: "Destinations",
      counter: MIDIGetNumberOfDestinations,
      getter: MIDIGetDestination
    )
}

printSourcesAndDestinations()
