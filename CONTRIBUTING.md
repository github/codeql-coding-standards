## Contributing

[fork]: https://github.com/github/REPO/fork
[pr]: https://github.com/github/REPO/compare
[style]: https://github.com/styleguide/ruby
[code-of-conduct]: CODE_OF_CONDUCT.md

Hi there! We're thrilled that you'd like to contribute to this project. Your help is essential for keeping it great.

Contributions to this project are [released](https://help.github.com/articles/github-terms-of-service/#6-contributions-under-repository-license) to the public under the [project's open source license](LICENSE.md).

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Scope

The CodeQL Coding Standards project **only** considers external contributions that improve an existing query.
Proposals for additional standards or guidelines are out of scope for this project.

If you are interested in adding a query that is outside the scope of this project then consider contributing to the [CodeQL standard library and queries](https://github.com/github/codeql).

## First step in contributing

The CodeQL Coding Standards is subject to strict software development processes in accordance with the ISO 26262 standard.
For more information on the tool qualification process refer to our [tool qualification document](docs/iso_26262_tool_qualification.md).

To ensure the that we adhere to the requirements we must first start with an [issue](https://github.com/github/codeql-coding-standards/issues/new/choose) to register and discuss the proposed improvement.

## Submitting a pull request

The next step, after registering and discussing your improvement, is proposing the improvement in a pull request.

1. [Fork](fork) and clone the repository
2. Configure and install the [CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases) specified in the `supported_codeql_configs.json` and [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html)
3. Create a new branch: `git checkout -b my-branch-name`
4. Make your change according to process described in the [development handbook](docs/development_handbook.md)
5. Ensure the files are appropriately formatted.
   - QL files should be formatted with `codeql query format`
   - C/C++ files should be formatted with `clang-format` using the format specification [.clang-format](.clang-format)
6. Push to your fork and [submit a draft pull request](https://github.com/github/codeql-coding-standards/compare). Make sure to select **Create Draft Pull Request**.
7. Address failed checks, if any.
8. Mark the [pull request ready for review](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/changing-the-stage-of-a-pull-request#marking-a-pull-request-as-ready-for-review).
9. Pat your self on the back and wait for your pull request to be reviewed and merged.

Here are a few things you can do that will increase the likelihood of your pull request being accepted:

- Follow the [development handbook](docs/development_handbook.md).
- Ensure all PR checks succeed.
- Keep your change as focused as possible. If there are multiple changes you would like to make that are not dependent upon each other, consider submitting them as separate pull requests.
- Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

## Resources

- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Using Pull Requests](https://help.github.com/articles/about-pull-requests/)
- [GitHub Help](https://help.github.com)
