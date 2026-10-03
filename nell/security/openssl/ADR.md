# ADR: OpenSSL build profile

## Status
Accepted.

## Decision
- Build OpenSSL with zlib and zstd support.
- Keep shared OpenSSL libraries in the bundle for consumers that require them.
- Build the `openssl` CLI fully static; this is an intentional exception to the usual dynamic-libc rule.
- Force zlib and zstd used by the CLI to their static archives.
- Disable tests and documentation.
