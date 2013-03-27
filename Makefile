include config.mk

SRC = aq-ipcrun.c util.c
OBJ = $(SRC:.c=.o)
BIN = aq-ipcrun
MAN = aq-ipcrun.1
DOC = LICENSE README
HDR = util.h

all: options $(BIN)

options:
	@echo Build options:
	@echo "	CFLAGS   = $(CFLAGS)"
	@echo "	LDFLAGS  = $(LDFLAGS)"
	@echo "	CC       = $(CC)"
	@echo "	PREFIX   = $(PREFIX)"

aq-ipcrun: aq-ipcrun.o util.o
	@echo LD $@
	@$(LD) -o $@ $^ $(LDFLAGS)

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

$(OBJ): util.h

dist: clean
	@echo creating tarball
	@mkdir -p aq-util-${VERSION}
	@cp -R $(DOC) $(HDR) $(SRC) $(MAN) \
		Makefile config.mk aq-util-${VERSION}
	@tar -cf aq-util-${VERSION}.tar aq-util-${VERSION}
	@gzip aq-util-${VERSION}.tar
	@rm -rf aq-util-${VERSION}

install: $(BIN) $(MAN)
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@for i in $(BIN); do \
		install -m755 $$i $(DESTDIR)$(PREFIX)/bin; \
		echo INSTALL $$i; \
	done
	@mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	@for i in $(MAN); do \
		gzip -c < $$i > $(DESTDIR)$(MANPREFIX)/man1/$$i.gz; \
		echo INSTALL $$i; \
	done

clean:
	rm -f $(OBJ) $(BIN) aq-util-${VERSION}.tar.gz

.phony: all options clean install dist