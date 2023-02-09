# CodeQL Coding Standards

This repository contains CodeQL queries and libraries which support various Coding Standards.

## Supported standards

_Carnegie Mellon and CERT are registered trademarks of Carnegie Mellon University._

This repository contains CodeQL queries and libraries which support various Coding Standards for the [C++14](https://www.iso.org/standard/64029.html) programming language.

The following coding standards are supported:
- [AUTOSAR - Guidelines for the use of C++14 language in critical and safety-related systems Release 20-11](https://www.autosar.org/fileadmin/standards/adaptive/20-11/AUTOSAR_RS_CPP14Guidelines.pdf)
- [MISRA C++:2008](https://www.misra.org.uk) (support limited to the rules specified in AUTOSAR 20-11).
- [SEI CERT C++ Coding Standard: Rules for Developing Safe, Reliable, and Secure Systems (2016 Edition)](https://resources.sei.cmu.edu/library/asset-view.cfm?assetID=494932)

In addition, the following Coding Standards for the C programming language are under development:

- [SEI CERT C Coding Standard: Rules for Developing Safe, Reliable, and Secure Systems (2016 Edition)](https://resources.sei.cmu.edu/downloads/secure-coding/assets/sei-cert-c-coding-standard-2016-v01.pdf)
- [MISRA C 2012](https://www.misra.org.uk/product/misra-c2012-third-edition-first-revision/).

## How do I use the CodeQL Coding Standards Queries?

The use of the CodeQL Coding Standards is extensively documented in the [user manual](docs/user_manual.md).

### Use in a functional safety environment

The CodeQL Coding Standards is qualified as a "software tool" under "Part 8: Supporting processes" of ISO 26262 ("Road vehicles - Functional Safety") as described in our [tool qualification documents](docs/iso_26262_tool_qualification.md).
Use of the CodeQL Coding Standards is only compliant with the qualification if it is used as distributed by GitHub and according to the requirements described in the [user manual](docs/user_manual.md).

Any changes to the CodeQL Coding Standards distribution and/or deviations from the requirements and steps described in the [user manual](docs/user_manual.md) runs the risk of non compliance.


## Contributing

We welcome contributions to our standard library and standard checks. Do you have an idea for a new check, or how to improve an existing query? Then please go ahead and open a pull request! Before you do, though, please take the time to read our [contributing guidelines](CONTRIBUTING.md). You can also consult our [development handbook](docs/development_handbook.md) to learn about the requirements for a contribution.

## License

Unless otherwise noted below, the code in this repository is licensed under the [MIT License](LICENSE.md) by [GitHub](https://github.com).

Parts of certain query help files (`.md` extension) are reproduced under the following licenses:
 - [SEI CERT® Coding Standards](thirdparty/cert/LICENSE) (_reproduced as of 15th March 2021_).

These licenses are directly referenced where applicable.

All code in the [thirdparty](./thirdparty) directory is licensed according to the files present in those sub directories.

All header files in [c/common/test/includes/standard-library](./c/common/test/includes/standard-library) are licensed according to [LICENSE](c/common/test/includes/standard-library/LICENSE)

---

<sup>1</sup>This repository incorporates portions of the SEI CERT® Coding Standards available at https://wiki.sei.cmu.edu/confluence/display/seccode/SEI+CERT+Coding+Standards; however, such use does not necessarily constitute or imply an endorsement, recommendation, or favoring by Carnegie Mellon University or its Software Engineering Institute.
