from distutils.core import setup
import os
from psshlib import version

long_description = """PSSH (Parallel SSH) provides parallel versions of OpenSSH and related tools, including pssh, pscp, prsync, pnuke, and pslurp.  The project includes psshlib which can be used within custom applications."""

setup(
    name = "pssh",
    version = version.VERSION,
    author = "Andrew McNabb",
    author_email = "amcnabb@mcnabbs.org",
    url = "http://code.google.com/p/parallel-ssh/",
    description = "Parallel version of OpenSSH and related tools",
    long_description = long_description,
    license = "BSD",
    platforms = ['linux'],

    classifiers = [
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: BSD License",
        "Operating System :: POSIX",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.4",
        "Programming Language :: Python :: 2.5",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.0",
        "Programming Language :: Python :: 3.1",
        "Programming Language :: Python :: 3.2",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: System :: Clustering",
        "Topic :: System :: Networking",
        "Topic :: System :: Systems Administration",
        ],

    packages=['psshlib'],
    scripts = [os.path.join("bin", p) for p in ["pssh", "pnuke", "prsync", "pslurp", "pscp", "pssh-askpass"]],
    data_files=[('man/man1', ['man/man1/pssh.1', 'man/man1/pscp.1',
        'man/man1/prsync.1', 'man/man1/pslurp.1', 'man/man1/pnuke.1'])],
    )
