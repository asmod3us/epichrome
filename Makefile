#
#  Makefile: Build rules for the project.
#
#  Copyright (C) 2015  David Marmor
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

VERSION:=$(shell source src/version.sh ; echo "$$mcssbVersion")

APP:=makechromessb.app
HOSTID:=com.dmarmor.ssb.redirect
HELPERID:=dolajcekhnohkpncmhgledbmndjpblei
#extension directory: jmpkbbcbedkidaopngjndaekagddcmfm
#src directory: aojbdgfcchdbogifikogaimkhbeemmaa

APP_CTNT:=${APP}/Contents
APP_RSRC:=${APP_CTNT}/Resources
APP_SCPT:=${APP_RSRC}/Scripts
APP_RNTM:=${APP_RSRC}/Runtime
APP_RNTM_RSRC:=${APP_RNTM}/Resources
APP_RNTM_SCPT:=${APP_RNTM_RSRC}/Scripts
APP_RNTM_NMHT:=${APP_RNTM_RSRC}/NativeMessagingHosts
APP_RNTM_NMEX:=${APP_RNTM_RSRC}/External\ Extensions
APP_RNTM_MCOS:=${APP_RNTM}/MacOS

INSTALL_PATH:=/Applications/Make Chrome SSB.app

.PHONY: install clean clean-all

.PRECIOUS: icons/app.icns icons/doc.icns

${APP}: ${APP_SCPT}/main.scpt \
	${APP_CTNT}/Info.plist \
	${APP_RSRC}/applet.icns \
	${APP_SCPT}/version.sh \
	${APP_SCPT}/make-chrome-ssb.sh \
	${APP_SCPT}/ssb-path-info.sh \
	${APP_SCPT}/makeicon.sh \
	${APP_RNTM_MCOS}/ChromeSSB \
	${APP_RNTM_SCPT}/runtime.sh \
	${APP_RNTM_SCPT}/infoplist.py \
	${APP_RNTM_SCPT}/strings.py \
	${APP_RNTM_NMHT}/${HOSTID}.json \
	${APP_RNTM_NMHT}/${HOSTID}-host.py \
	${APP_RNTM_NMEX}/${HELPERID}.json \
	${APP_RNTM_RSRC}/app.icns \
	${APP_RNTM_RSRC}/doc.icns

clean:
	rm -rf makechromessb.app

clean-all: clean
	find . \( -name '*~' -or -name '.DS_Store' \) -exec rm {} \;
	rm icons/*.icns

install: ${APP}
	if [ -e "${INSTALL_PATH}" ] ; then osascript -e 'tell application "Finder" to move ((POSIX file "${INSTALL_PATH}") as alias) to trash' ; fi
	cp -a ${APP} "${INSTALL_PATH}"

${APP_SCPT}/main.scpt: src/main.applescript
	@rm -rf ${APP}
	osacompile -x -o ${APP} src/main.applescript
	@rm -f ${APP_CTNT}/Info.plist ${APP_RSRC}/applet.icns
	mkdir -p ${APP_RNTM_SCPT}
	mkdir -p ${APP_RNTM_MCOS}
	mkdir -p ${APP_RNTM_NMHT}
	mkdir -p ${APP_RNTM_NMEX}
	touch ${APP}

${APP_CTNT}/Info.plist: src/Info.plist src/version.sh
	sed "s/SSBVERSION/${VERSION}/" $< > $@
	@touch ${APP} ${APP_CTNT}

${APP_RSRC}/applet.icns: icons/makechromessb.icns
	cp -p $< $@
	@touch ${APP} ${APP_CTNT} ${APP_RSRC}

${APP_SCPT}/%: src/%
	cp -p $< ${APP_SCPT}/
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_SCPT}

${APP_RNTM_MCOS}/ChromeSSB: src/chromessb
	sed "s/SSBHOSTID/${HOSTID}/" $< > $@
	chmod 755 $@
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_MCOS}

${APP_RNTM_SCPT}/%: src/%
	cp -p $< ${APP_RNTM_SCPT}/
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_RSRC} ${APP_RNTM_SCPT}

${APP_RNTM_NMHT}/${HOSTID}.json: src/host-manifest.json src/version.sh
	sed "s/SSBHOSTID/${HOSTID}/; s/SSBVERSION/${VERSION}/; s/SSBHELPERID/${HELPERID}/" $< > $@
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_RSRC} ${APP_RNTM_NMHT}

${APP_RNTM_NMHT}/${HOSTID}-host.py: src/host-script.py src/version.sh
	sed "s/SSBVERSION/${VERSION}/" $< > $@
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_RSRC} ${APP_RNTM_NMHT}

${APP_RNTM_NMEX}/${HELPERID}.json: src/install-extension.json
	cp -p $< ${APP_RNTM_NMEX}/${HELPERID}.json
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_RSRC} ${APP_RNTM_NMEX}

${APP_RNTM_RSRC}/%.icns: icons/%.icns
	cp -p $< ${APP_RNTM_RSRC}/
	@touch ${APP} ${APP_CTNT} ${APP_RSRC} ${APP_RNTM} ${APP_RNTM_RSRC}

%.icns: %.psd
	src/makeicon.sh -f $< $@
