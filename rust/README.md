# Setup Rust development in Visual Studio Code (vscode)...

1: Install rust toolchain via [rustup](https://www.rust-lang.org/tools/install).

1b: You might have to also install Visual Studio build tools (2013 or later) with workload "C++ build tools", individual components "Windows 10 SDK [some version]" and language pack "English".  Here is [VS2019 build tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019) or you can probably select latest community edition of Visual Studio from [this downloads page](https://visualstudio.microsoft.com/downloads/).

2: Install [vscode](https://code.visualstudio.com/download), preferably system installer.

3: If you like vim, install [vim extension](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim).

4: Install [Rust (rls) extension](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust).

5: Install [C/C++ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools).

6: Install [CodeLLDB extension](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb).

7: Checkmark "allow setting breakpoints in any file" setting.  Can search for "break" in settings.

Note: I originally followed the instructions at [this blog post](https://www.forrestthewoods.com/blog/how-to-debug-rust-with-visual-studio-code/).

# Development Actions

* To force build, use Ctrl+Shift+B shortcut to do a "cargo build"

* In terminal, run "cargo fmt" to run rustfmt autoformatter over code.

* Reminder: Racer [issue #1033](https://github.com/racer-rust/racer/issues/1033) means standard prelude stuff is not auto-completed.
