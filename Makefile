%:	%.swift
	swiftc $<

midi_test:	midi_test.swift

midi_through:	midi_through.swift

clean:
	rm -f midi_test midi_through
