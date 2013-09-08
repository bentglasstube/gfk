all:
	@echo 'There is nothing to build, try `make install`'

install:
	install -Dm 755 gfk ${DESTDIR}/usr/bin/gfk
	install -Dm 644 gfk.conf ${DESTDIR}/etc/gfk.conf.example
