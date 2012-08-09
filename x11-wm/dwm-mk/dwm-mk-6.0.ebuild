# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/dwm/dwm-6.0.ebuild,v 1.11 2012/05/03 14:40:04 jer Exp $

EAPI="4"

inherit eutils git toolchain-funcs

DESCRIPTION="a dynamic window manager for X11"
HOMEPAGE="http://dwm.suckless.org/"
SRC_URI=""

EGIT_REPO_URI="git://github.com/mugenken/dwm-6.0.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86 ~x86-fbsd"
IUSE="xinerama"

DEPEND="x11-libs/libX11
        x11-misc/dmenu
    xinerama? (
        x11-proto/xineramaproto
        x11-libs/libXinerama
        x11-misc/dmenu[xinerama]
        )"
RDEPEND="${DEPEND}"

src_prepare() {
    sed -i \
        -e "s/CFLAGS = -std=c99 -pedantic -Wall -Os/CFLAGS += -std=c99 -pedantic -Wall/" \
        -e "/^LDFLAGS/{s|=|+=|g;s|-s ||g}" \
        -e "s/#XINERAMALIBS =/XINERAMALIBS ?=/" \
        -e "s/#XINERAMAFLAGS =/XINERAMAFLAGS ?=/" \
        -e "s@/usr/X11R6/include@${EPREFIX}/usr/include/X11@" \
        -e "s@/usr/X11R6/lib@${EPREFIX}/usr/lib@" \
        -e "s@-I/usr/include@@" -e "s@-L/usr/lib@@" \
        config.mk || die "sed failed"

    epatch_user
}

src_compile() {
    if use xinerama; then
        emake CC=$(tc-getCC)
    else
        emake CC=$(tc-getCC) XINERAMAFLAGS="" XINERAMALIBS=""
    fi
}

src_install() {
    emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install

    exeinto /etc/X11/Sessions
    newexe "${FILESDIR}"/dwm-mk-session dwm-mk

    insinto /usr/share/xsessions
    doins "${FILESDIR}"/dwm-mk.desktop

    dodoc README
}
