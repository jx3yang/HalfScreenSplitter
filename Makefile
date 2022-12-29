EXE = halfscreensplitter
SWIFT = swiftc

$(EXE):
	$(SWIFT) $(EXE).swift

clean:
	rm $(EXE)
