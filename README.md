swift ring management via git
=============================

This repository allows the management of swift rings via git. The main
reason to do this is peer reviews before pushing and better tracking and
auditing of changes.

Swift ring files are composed by a `.builder` file that describes the ring and
a `.ring.gz` file which is the actual ring generated from the `.builder` file
by `swift-ring-builder` however both files come in binary form, making code
review tools useless and git unhappy. Thus, the solution is to dump a text
version of the ring (the `.dump` files) upon changing and review that alongside
the binary files.


Usage
-----

* Make sure you have `swift-ring-builder` tool (`swift` debian package >= 2.2.2)
* Also install `rsync` (needed for deployment)
* Make the appropriate changes to the relevant swift cluster and ring (most
  likely `object.builder`)
* Rebuild the rings that have been changed:

        make

* Commit the result (`.ring.gz` `.builder` `.dump` and `.dispersion` files) and
  optionally send it for review
* Once merged, deploy the rings to the puppet master:

        make deploy DESTHOST=puppet.eqiad.wmnet

* To deploy a single 'target' (i.e. subdirectory in this repository)

        make deploy DESTHOST=puppet.eqiad.wmnet TARGETS=<subdir>


Testing
-------
To test a deploy the DESTHOST make variable can be overridden from the command
line, e.g:

    make deploy DESTHOST=testhost.eqiad.wmflabs
