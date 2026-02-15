CXX=clang++
CXXFLAGS=-std=c++17 -O3 -DNDEBUG -fPIC
LDFLAGS=-shared
PKG_CONFIG=pkg-config
LIBS=lz4 libzstd lzo2 zlib
CFLAGS=$(shell $(PKG_CONFIG) --cflags $(LIBS) 2>/dev/null)
LDLIBS=$(shell $(PKG_CONFIG) --libs $(LIBS) 2>/dev/null)
ifeq ($(LDLIBS),)
    LDLIBS=-llz4 -lzstd -llzo2 -lz
endif
TARGET_LIB=libnextram-zramlib.so
TARGET_BIN=nextram-zram-ctl
TARGET_AICF=./tools/nextramaicf

all: $(TARGET_LIB) $(TARGET_BIN) $(TARGET_AICF)

$(TARGET_LIB): src/nextram-zramlib.o
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(TARGET_BIN): src/nextram-zram-ctl.o $(TARGET_LIB)
	$(CXX) -o $@ $< $(LDLIBS) -L. -lnextram-zramlib

src/nextram-zramlib.o: src/nextram-zramlib.cpp src/nextram-zramlib.h
	$(CXX) $(CXXFLAGS) $(CFLAGS) -c $< -o $@

src/nextram-zram-ctl.o: src/nextram-zram-ctl.cpp src/nextram-zramlib.h
	$(CXX) $(CXXFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET_AICF): source/nextramaicf.cpp
	mkdir -p tools
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -f src/*.o $(TARGET_LIB) $(TARGET_BIN) $(TARGET_AICF)

install: all
	mkdir -p $(DESTDIR)/lib $(DESTDIR)/bin $(DESTDIR)/tools
	cp $(TARGET_LIB) $(DESTDIR)/lib/
	cp $(TARGET_BIN) $(DESTDIR)/bin/
	cp $(TARGET_AICF) $(DESTDIR)/tools/

.PHONY: all clean install
