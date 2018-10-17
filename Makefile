build: libsigrok

all: dirs libserialport libftdi libsigrok

CWD = $(CURDIR)
TMP = /tmp
SRC = $(TMP)/src
GZ  = $(HOME)/gz

NUM_CPUS = $(shell grep processor /proc/cpuinfo|wc -l)

MAKE_J	= $(MAKE) -j$(NUM_CPUS)

WGET	= wget -c

CFG_ALL = --disable-nls

CFG_LIBS_ALL = --disable-shared 

dirs:
	mkdir -p $(GZ) $(TMP) $(SRC)

######## libserial

CFG_SERIAL = $(CFG_ALL) $(CFG_LIBS_ALL)

libserialport: $(SRC)/libserialport/configure
	rm -rf $(TMP)/$@ ; mkdir $(TMP)/$@ ; cd $(TMP)/$@ ;\
		$< $(CFG_SERIAL) && $(MAKE_J) && sudo $(MAKE) install-strip
$(SRC)/libserialport/configure:
	-git clone --depth=1 git://sigrok.org/libserialport $(SRC)/libserialport
	cd $(SRC)/libserialport ; ./autogen.sh

######### libftdi

LIBFTDI_VER	= 1.4
LIBFTDI		= libftdi1-$(LIBFTDI_VER)
LIBFTDI_GZ	= $(LIBFTDI).tar.bz2

libftdi: $(SRC)/$(LIBFTDI)/CMakeLists.txt
	rm -rf $(TMP)/$@ ; mkdir $(TMP)/$@ ; cd $(TMP)/$@ ;\
		cmake $(SRC)/$(LIBFTDI) && $(MAKE_J) && sudo $(MAKE) install
$(SRC)/$(LIBFTDI)/CMakeLists.txt: $(GZ)/$(LIBFTDI_GZ)
	cd $(SRC) ; bzcat $< | tar x && touch $@
$(GZ)/$(LIBFTDI_GZ):
	$(WGET) -O $@ https://www.intra2net.com/en/developer/libftdi/download/$(LIBFTDI_GZ)

######### libsigrok

CFG_SIGROK = $(CFG_ALL) $(CFG_LIBS_ALL) --disable-ruby --disable-python --disable-java

libsigrok: $(SRC)/libsigrok/configure
	rm -rf $(TMP)/$@ ; mkdir $(TMP)/$@ ; cd $(TMP)/$@ ;\
		$< $(CFG_SIGROK) && $(MAKE_J) && sudo $(MAKE) install-strip
$(SRC)/libsigrok/configure: \
	/usr/include/zip.h /usr/include/libftdi1/ftdi.h /usr/include/glibmm-2.4/glibmm.h
	-git clone --depth=1 git://sigrok.org/libsigrok $(SRC)/libsigrok
	cd $(SRC)/libsigrok ; ./autogen.sh

/usr/include/libftdi1/ftdi.h:
	sudo apt install libftdi1-dev
/usr/include/zip.h:
	sudo apt install libzip-dev
/usr/include/glibmm-2.4/glibmm.h:
	sudo apt install libglibmm-2.4-dev
