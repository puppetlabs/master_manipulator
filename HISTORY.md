# default - History
## Tags
* [LATEST - 06 Jan, 2016 (36910dd)](#LATEST)
* [1.2.4 - 27 Sep, 2016 (036a99e6)](#1.2.4)
* [1.2.3 - 20 Nov, 2015 (f31e884e)](#1.2.3)
* [1.2.2 - 30 Oct, 2015 (31450d3c)](#1.2.2)
* [1.2.1 - 30 Oct, 2015 (b59fd2cf)](#1.2.1)
* [1.2.0 - 29 Oct, 2015 (6d0873f7)](#1.2.0)
* [1.1.2 - 14 Jul, 2015 (13e5bb62)](#1.1.2)
* [1.1.1 - 1 Jul, 2015 (42e15400)](#1.1.1)
* [1.1.0 - 30 Jun, 2015 (c33bac06)](#1.1.0)
* [1.0.1 - 17 Jun, 2015 (33c2182d)](#1.0.1)
* [1.0.0 - 6 May, 2015 (8ae50d90)](#1.0.0)

## Details
### <a name = "LATEST">LATEST - 06 Jan, 2016 (36910dd)
* Fix spec failures (36910dd)

* Various cleanups ahead of a 1.2.5 release (fdf54a2)

* Merge pull request #22 from kurtwall/seed-the-yard (49f6ca5)

* Merge https://github.com/puppetlabs/master_manipulator into seed-the-yard (38cb146)

* Merge pull request #21 from kurtwall/update-readme (1d75e90)

* Start the initial conversion to YARD (169b575)

* Update README.md (2159ad7)

* (QA-2789) Revise Master Manipulator docs (fc5cae8)

* Merge pull request #20 from kurtwall/fix-typo (eff5cdf)

* (MAINT) Fix typo (d3a6306)

### <a name = "1.2.4">1.2.4 - 27 Sep, 2016 (036a99e6)

* (GEM) update master_manipulator version to 1.2.4 (036a99e6)

* Merge pull request #19 from tvpartytonight/maint_relax_beaker_dep (ecf8be2e)


```
Merge pull request #19 from tvpartytonight/maint_relax_beaker_dep

(maint) Relax beaker dependency version
```
* (maint) Relax beaker dependency version (1f3bf5ad)

* Merge pull request #17 from kurtwall/fix-perms (ac25ff24)


```
Merge pull request #17 from kurtwall/fix-perms

(MAINT) Remove execute bit from all files
```
* (MAINT) Remove execute bit from all files (e8839cbf)

### <a name = "1.2.3">1.2.3 - 20 Nov, 2015 (f31e884e)

* (HISTORY) update master_manipulator history for gem release 1.2.3 (f31e884e)

* (GEM) update master_manipulator version to 1.2.3 (b37806b8)

* Merge pull request #16 from zreichert/make_master_manipulator_3.8_compatible (9d2073ff)


```
Merge pull request #16 from zreichert/make_master_manipulator_3.8_compatible

(QA-2182) make restart_puppet_server 3.8 compatible
```
* Address comments and fix spec tests (96d82bd4)

* add method for determining pe_version (c2b9a957)

* (QA-2182) make restart_puppet_server 3.8 compatible (9444b681)

### <a name = "1.2.2">1.2.2 - 30 Oct, 2015 (31450d3c)

* (HISTORY) update master_manipulator history for gem release 1.2.2 (31450d3c)

* (GEM) update master_manipulator version to 1.2.2 (58720b61)

* Merge pull request #15 from zreichert/update_json_require (b01919b7)


```
Merge pull request #15 from zreichert/update_json_require

update json require
```
* update json require (8519e1ca)

### <a name = "1.2.1">1.2.1 - 30 Oct, 2015 (b59fd2cf)

* (HISTORY) update master_manipulator history for gem release 1.2.1 (b59fd2cf)

* (GEM) update master_manipulator version to 1.2.1 (a97f5458)

* Merge pull request #14 from zreichert/add_json_runtime_dependancy (9ff2c98f)


```
Merge pull request #14 from zreichert/add_json_runtime_dependancy

(MAINT) add json runtime dependency
```
* (MAINT) add json runtime dependency (e07f7d39)

### <a name = "1.2.0">1.2.0 - 29 Oct, 2015 (6d0873f7)

* (HISTORY) update master_manipulator history for gem release 1.2.0 (6d0873f7)

* (GEM) update master_manipulator version to 1.2.0 (4be0bec7)

* Merge pull request #13 from zreichert/improvement/master/QA-2115-use_status_enpoint (8ef7e82b)


```
Merge pull request #13 from zreichert/improvement/master/QA-2115-use_status_enpoint

(QA-2115) use services endpoint for puppetserver
```
* (QA-2115) use services endpoint for puppetserver (ef2ebfc7)

### <a name = "1.1.2">1.1.2 - 14 Jul, 2015 (13e5bb62)

* Merge pull request #12 from mckern/master (13e5bb62)


```
Merge pull request #12 from mckern/master

(MAINT) Bump version to 1.1.2 for first public release
```
* (MAINT) Bump version to 1.1.2 for first public release (8bd83fe9)

* Merge pull request #11 from mckern/master (be4bf542)


```
Merge pull request #11 from mckern/master

(MAINT) Prepare Gemspec for initial public release
```
* (MAINT) Prepare Gemspec for initial public release (0016defd)


```
(MAINT) Prepare Gemspec for initial public release

Updated Gemspec to newer general Ruby and Rubygem standards
(http://guides.rubygems.org/specification-reference/), which includes:

Use single-quoted strings instead of double-string when interpolation
isn't needed.

Provide a slightly better description.

Update the Gem author with the same 'author' as our other public gems.

Correct OSI license name
  (http://opensource.org/licenses/alphabetical).

Use Ruby to generate the files to package, instead of shelling out to
git on the command line.

Removing attributes that are unused, like spec.executables and
spec.require_paths (since it defaults to 'lib/').
```
### <a name = "1.1.1">1.1.1 - 1 Jul, 2015 (42e15400)

* (HISTORY) update master_manipulator history for gem release 1.1.1 (42e15400)

* (GEM) update master_manipulator version to 1.1.1 (14ceb0e8)

* Merge pull request #10 from cowofevil/bug/master/QA-1935/fix_perms_on_site_pp (ebb0e478)


```
Merge pull request #10 from cowofevil/bug/master/QA-1935/fix_perms_on_site_pp

(QA-1935) Fix "inject_site_pp" Issue
```
* (QA-1935) Fix "inject_site_pp" Issue (338a6d40)


```
(QA-1935) Fix "inject_site_pp" Issue

The wrong mode was being set on the "site.pp" which made Puppet unable
to read the file.
```
### <a name = "1.1.0">1.1.0 - 30 Jun, 2015 (c33bac06)

* (HISTORY) update master_manipulator history for gem release 1.1.0 (c33bac06)

* (GEM) update master_manipulator version to 1.1.0 (53e5d02b)

* Merge pull request #9 from cowofevil/feature/master/QA-1934/get_manifests_path (0f86d431)


```
Merge pull request #9 from cowofevil/feature/master/QA-1934/get_manifests_path

(QA-1934) Add New Methods
```
* (QA-1934) Add New Methods (27c1d815)


```
(QA-1934) Add New Methods

Add methods for retrieving the location of environment manifests.
Update the README to include actual documentation.
```
* Merge pull request #8 from zreichert/improve_restart-puppet-server (f245c951)


```
Merge pull request #8 from zreichert/improve_restart-puppet-server

Improve restart puppet server
```
* (QA-1930) add option is_pe? (14184e40)

* (QA-1930) simplify curl call (5d0b0362)

* (QA-1930) update restart_puppet_server timeout default to 60 (f9435b7c)

* (QA-1930) improve error msg  & new spec test (6eec120d)

* (QA-1930) refactor to use case statement (d9d5f428)

### <a name = "1.0.1">1.0.1 - 17 Jun, 2015 (33c2182d)

* (HISTORY) update master_manipulator history for gem release 1.0.1 (33c2182d)

* (GEM) update master_manipulator version to 1.0.1 (a2140d3d)

* Merge pull request #7 from cowofevil/bug/master/QA-1928_fix_bug (51950027)


```
Merge pull request #7 from cowofevil/bug/master/QA-1928_fix_bug

(QA-1928) Fix Bug
```
* (QA-1928) Fix for the fix (e6c4bb69)

* (QA-1928) Fix Bug (d2f56fdd)


```
(QA-1928) Fix Bug

The "set_perms_on_remote" method fails to set ownership on a file and is
now fixed!
```
### <a name = "1.0.0">1.0.0 - 6 May, 2015 (8ae50d90)

* Initial release.
