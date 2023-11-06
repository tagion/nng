.SUFFIXES:
.ONESHELL:
.NOTPARALLEL:

MMODULES=libnng

all: $(MMODULES)

clean: clean-$(MMODULES)

proper: proper-$(MMODULES)

$(MMODULES): 
	@echo "Making "$@ &&\
	$(MAKE) $(MAKEOVERRIDES) -C $@/ 

clean-%:
	$(MAKE) $(MAKEOVERRIDES) -C $*/ clean

proper-%:
	$(MAKE) $(MAKEOVERRIDES) -C $*/ clean
	$(MAKE) $(MAKEOVERRIDES) -C $*/ proper

.PHONY: all clean $(MMODULES)
