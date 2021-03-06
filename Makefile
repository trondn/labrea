LINUX_LDFLAGS=-shared -Wl,-soname,labrea.so -ldl -lpthread
MAC_LDFLAGS=-MD -MP -Wl,-undefined -Wl,dynamic_lookup -dynamiclib

PLATS=linux mac
.PHONY: lua $(PLATS)

LUA=lua-5.1.4
LUATARGET=posix
LUACFLAGS=-fPIC

CXXFLAGS=-fPIC -Wall -g -I$(LUA)/src

default:
	$(MAKE) `uname -s`

labrea.so: lua labrea.o scripting.o gen_invoker.o
	$(CXX) $(LDFLAGS) -o labrea.so labrea.o scripting.o gen_invoker.o $(LUA)/src/*.o

lua:
	cd $(LUA)/src && $(MAKE) CC="$(CXX)" MORECFLAGS="$(LUACFLAGS)" $(LUATARGET)
	rm $(LUA)/src/lua.o $(LUA)/src/luac.o

clean:
	rm -f labrea.so labrea.o scripting.o gen_invoker.cc gen_invoker.o \
          gen_scripting.hh gen_wrapperfuns.hh
	cd $(LUA) && $(MAKE) clean

linux:
	$(MAKE) LDFLAGS="$(LINUX_LDFLAGS)" labrea.so

mac:
	$(MAKE) LDFLAGS="$(MAC_LDFLAGS)" labrea.so

# Uname -> target mappings.
Linux: linux
Darwin: mac

gen_invoker.cc: mkgeninvoker.py
	./mkgeninvoker.py

gen_scripting.hh: mkcallfuns.py
	./mkcallfuns.py

gen_wrapperfuns.hh: mkwrapfuns.py
	./mkwrapfuns.py

scripting.hh: locks.hh gen_scripting.hh labreatypes.h script_state.hh
labrea.h: gen_wrapperfuns.hh labreatypes.h

gen_invoker.o: gen_invoker.cc gen_invoker.hh labrea.h scripting.hh labreatypes.h
labrea.o: labrea.cc labrea.h locks.hh scripting.hh labreatypes.h \
          calls.defs definecalls.h buildfunctions.h gen_invoker.hh
scripting.o: scripting.cc labrea.h locks.hh scripting.hh labreatypes.h
