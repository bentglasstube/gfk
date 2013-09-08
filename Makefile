all:
	@echo 'There is nothing to build, try `make install`'

install:
	install -Dm 755 gfk ${DESTDIR}/usr/bin/gfk
	install -Dm 644 gfk.conf ${DESTDIR}/etc/gfk.conf.example
	install -Dm 644 gfk.1 ${DESTDIR}/usr/share/man/man1/gfk.1
	install -Dm 644 gfk.conf.5 ${DESTDIR}/usr/share/man/man5/gfk.conf.5
