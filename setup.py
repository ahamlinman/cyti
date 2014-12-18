from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import subprocess

### Initial settings ###

module_name = "cyti"
module_version = "0.1"
module_files = ["*.pyx"]
module_include_dirs = []
module_libraries = []
module_library_dirs = []

### Get extra package configuration options ###

## {{{ Based on http://code.activestate.com/recipes/502261/ (r1)
def pkgconfig(*packages, **kw):
    flag_map = {'-I': 'include_dirs', '-L': 'library_dirs', '-l': 'libraries'}
    pkg_config_process = subprocess.Popen("pkg-config --libs --cflags %s" % " ".join(packages),shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    pkg_config_output = pkg_config_process.communicate()[0].split()
    for token in pkg_config_output:
        kw.setdefault(flag_map.get(token[:2].decode('utf-8')), []).append(token[2:].decode('utf-8'))
    return kw
## end of http://code.activestate.com/recipes/502261/ }}}

pkg_config_opts = pkgconfig('ticables2', 'ticalcs2', 'tifiles2')

if 'include_dirs' in pkg_config_opts:
    module_include_dirs += pkg_config_opts['include_dirs']

if 'libraries' in pkg_config_opts:
    module_libraries += pkg_config_opts['libraries']

if 'library_dirs' in pkg_config_opts:
    module_library_dirs += pkg_config_opts['library_dirs']

### Set up module ###

setup(name=module_name,
      version=module_version,
      ext_modules=cythonize([Extension(module_name, module_files,
                             include_dirs=module_include_dirs,
                             libraries=module_libraries,
                             library_dirs=module_library_dirs)])
)

