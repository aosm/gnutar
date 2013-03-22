##
# gnutar Makefile
##

# Project info
Project               = gnutar
UserType              = Administrator
ToolType              = Commands
Extra_Configure_Flags = --program-prefix=gnu --includedir=/usr/local/include
Extra_CC_Flags        = -mdynamic-no-pic
GnuAfterInstall       = remove-dir install-man install-plist

# It's a GNU Source project
include $(MAKEFILEPATH)/CoreOS/ReleaseControl/GNUSource.make

# Automatic Extract & Patch
AEP            = YES
AEP_Project    = tar
AEP_Version    = 1.17
AEP_ProjVers   = $(AEP_Project)-$(AEP_Version)
AEP_Filename   = $(AEP_ProjVers).tar.bz2
AEP_ExtractDir = $(AEP_ProjVers)
AEP_Patches    = Makefile.in.diff tar-1.17-buildfix.diff \
                 EA.diff preallocate.diff quarantine.diff \
                 PR5405409.diff PR5605786.diff PR6450027.diff

ifeq ($(suffix $(AEP_Filename)),.bz2)
AEP_ExtractOption = j
else
AEP_ExtractOption = z
endif

# Extract the source.
install_source::
ifeq ($(AEP),YES)
	$(TAR) -C $(SRCROOT) -$(AEP_ExtractOption)xf $(SRCROOT)/$(AEP_Filename)
	$(RMDIR) $(SRCROOT)/$(Project)
	$(MV) $(SRCROOT)/$(AEP_ExtractDir) $(SRCROOT)/$(Project)
	@for patchfile in $(AEP_Patches); do \
		(cd $(SRCROOT)/$(Project) && patch -p0 -F0 < $(SRCROOT)/patches/$$patchfile) || exit 1; \
	done
endif

remove-dir:
	$(RM) $(DSTROOT)/usr/share/info/dir
	$(RM) $(DSTROOT)/usr/lib/charset.alias

install-man:
	$(MKDIR) $(DSTROOT)$(MANDIR)/man1/
	$(INSTALL_FILE) $(SRCROOT)/gnutar.1 $(DSTROOT)$(MANDIR)/man1/gnutar.1
	$(MKDIR) $(DSTROOT)$(MANDIR)/man8/
	$(INSTALL_FILE) $(SRCROOT)/gnurmt.8 $(DSTROOT)$(MANDIR)/man8/gnurmt.8

OSV = $(DSTROOT)/usr/local/OpenSourceVersions
OSL = $(DSTROOT)/usr/local/OpenSourceLicenses

install-plist:
	$(MKDIR) $(OSV)
	$(INSTALL_FILE) $(SRCROOT)/$(Project).plist $(OSV)/$(Project).plist
	$(MKDIR) $(OSL)
	$(INSTALL_FILE) $(Sources)/COPYING $(OSL)/$(Project).txt
