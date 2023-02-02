
.PHONY: all clean

VERSION ?= 2.2.0-$(shell git rev-parse HEAD | cut -c1-8)

all:
	-$(RM) -r build/
	mkdir build/
	cd PongoOS && make
	cd ramdisk && make 'VERSIONFLAGS=-DVERSION=\"$(VERSION)\"'
	cd overlay && make
	cp -a PongoOS/build/checkra1n-kpf-pongo build/kpf
	cp -a ramdisk/ramdisk.dmg build/ramdisk.dmg
	cp -a overlay/binpack.dmg build/overlay.dmg
	cd build && ../bin/lzfse -encode -v -i kpf -o kpf.lzfse
	cd build && ../bin/lzfse -encode -v -i ramdisk.dmg -o ramdisk.dmg.lzfse
	cd build && ../bin/lzfse -encode -v -i overlay.dmg -o overlay.dmg.lzfse
	cd build && xxd -i kpf.lzfse > kpf.h
	cd build && xxd -i ramdisk.dmg.lzfse > ramdisk.h
	cd build && xxd -i overlay.dmg.lzfse > overlay.h
	-$(RM) -r term/bakera1n_loader
	cd term && make
	cd build && rm -f kpf.h
	cd build && rm -f ramdisk.h
	cd build && rm -f overlay.h
	
	-$(RM) -r builtin/
	-$(RM) -r bakera1n_v*.tar.xz
	-$(RM) -r bakera1n_v*.tar
	mkdir builtin/
	cp -a PongoOS/build/Pongo.bin term/Pongo.bin
	cp -a PongoOS/build/Pongo.bin builtin/Pongo.bin
	cp -a term/bakera1n_loader builtin/bakera1n_loader
	cp -a term/README.md builtin/README_loader.md
	cp -a README.md builtin/README.md
	tar -cvf bakera1n_v$(VERSION).tar builtin/bakera1n_loader builtin/README.md builtin/README_loader.md
	xz -z9k bakera1n_v$(VERSION).tar
	-$(RM) -r builtin/
	openssl sha256 bakera1n_v$(VERSION).tar.xz

clean:
	-$(RM) -r build/
	cd ramdisk && make clean
	cd overlay && make clean
	cd term && make clean
