all:
	@echo 'There is nothing to build, try `make install`'

install:
	install -Dm 755 gfk /usr/local/bin/gfk
	install -Dm 644 gfk.conf /etc/gfk.conf.example
