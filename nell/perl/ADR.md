# ADR: Perl build profile

## Status
Accepted.

## Decision
- Build Perl 5.44.0 from the upstream `v5.44.0` tag.
- Keep the existing Perl filesystem layout and optional-library profile.
- Disable libcrypt support and restrict `libswanted` to `m c`.
- Do not run tests.
- Remove POD, man, HTML and other documentation from the final bundle.
- Keep this project in its existing legacy `nell/perl` location; moving it into a section is outside this cleanup.
