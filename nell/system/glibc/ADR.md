# ADR: glibc build profile

## Status
Accepted.

## Decision
- Build glibc from the matching upstream release branch.
- Install under `/usr` into the staging root.
- Generate only the required `en_US.UTF-8` and `ru_RU.UTF-8` locales.
- glibc is the runtime libc for the rest of `nell`; the general static-dependency rule does not apply to glibc itself.
- Do not run the test suite during image construction.
