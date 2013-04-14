include config.mk

SRC = aq-ipcrun.c util.c
OBJ = $(SRC:.c=.o)
BIN = aq-ipcrun readopt
MAN = aq-ipcrun.1 readopt.8
DOC = LICENSE README
HDR = util.h
GZIP = gzip

all: options $(BIN)

options:
	@echo Build options:
	@echo "	CFLAGS    = $(CFLAGS)"
	@echo "	LDFLAGS   = $(LDFLAGS)"
	@echo "	CC        = $(CC)"
	@echo "	PREFIX    = $(PREFIX)"
	@echo "	MANPREFIX = $(MANPREFIX)"

aq-ipcrun: aq-ipcrun.o util.o
	@echo LD $@
	@$(LD) -o $@ $^ $(LDFLAGS)

.c.o:
	@echo CC $<
	@$(CC) -c $(CFLAGS) $<

readopt: readopt.sh
	@echo MK $@
	@cp $< $@

$(OBJ): util.h

dist: clean
	@echo creating tarball
	@mkdir -p aq-util-$(VERSION)
	@cp -R $(DOC) $(HDR) $(SRC) $(MAN) \
		Makefile config.mk aq-util-$(VERSION)
	@tar -cf aq-util-$(VERSION).tar aq-util-$(VERSION)
	@gzip aq-util-$(VERSION).tar
	@rm -rf aq-util-$(VERSION)

install: $(BIN) installman
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@for i in $(BIN); do \
		install -m755 $$i $(DESTDIR)$(PREFIX)/bin; \
		echo INSTALL $$i; \
	done

installman: $(MAN)
	@for i in $(MAN); do \
		dir=$(DESTDIR)$(MANPREFIX)/man$${i##*.}; \
		mkdir -p $$dir; \
		cp $$i $$dir/$$i; \
		chmod 0644 $$dir/$$i; \
		$(GZIP) $$dir/$$i; \
		echo INSTALL $$i; \
	done

clean:
	rm -f $(OBJ) $(BIN) aq-util-$(VERSION).tar.gz

release:
	@echo git checkout master
	@echo git tag -a $(VERSION)
	@echo git push origin master
	@echo git push origin --tags

.phony: all options clean install dist release installman
