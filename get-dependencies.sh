#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

rolesdir=$(dirname $0)/..

## galaxy naming: kitchen fails to transfer symlink folder
#[ ! -e $rolesdir/juju4.harden ] && ln -s ansible-harden $rolesdir/juju4.harden
[ ! -e $rolesdir/freedomofpress.jitsi-meet ] && cp -R $rolesdir/ansible-role-jitsi-meet $rolesdir/freedomofpress.jitsi-meet

## don't stop build on this script return code
true

