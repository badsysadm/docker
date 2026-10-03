# ADR: OpenSSH build profile

## Status
Accepted.

## Decision
- Build OpenSSH Portable from its release tag.
- Enable PAM and Kerberos 5 support.
- Use the OpenSSL bundle's `libcrypto.a` and headers rather than a repository shared libcrypto.
- Link crypto, zlib and zstd dependencies statically while retaining the required dynamic system integration.
- Remove installed man pages and do not run tests.
