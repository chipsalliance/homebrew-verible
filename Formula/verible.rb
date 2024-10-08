class Verible < Formula
  desc "SystemVerilog developer tools"
  homepage "https://github.com/chipsalliance/verible"
  url "https://github.com/chipsalliance/verible.git",
      branch:   "master",
      tag:      "v0.0-3665-ga9394662",
      revision: "a939466243915e6151d4a3675c3e9689e94e8f8a"
  version "0.0-3665-ga9394662"
  license "Apache-2.0"
  head "https://github.com/chipsalliance/verible.git", branch: "master"

  depends_on "bazel" => :build
  depends_on macos: :catalina # C++ features

  def install
    bazel_args = []
    bazel_args << "--jobs=#{ENV.make_jobs}"
    bazel_args << "--compilation_mode=opt"
    bazel_args << "--linkopt=-Wl,-rpath,#{rpath}"
    bazel_args << "--verbose_failures"
    bazel_args << "--sandbox_debug"
    # Bazel defaults to a macOS SDK version of 10.11
    # (see https://github.com/bazelbuild/bazel/blob/master/src/main/starlark/builtins_bzl/common/xcode/providers.bzl)
    # The macOS SDK 10.11 does not support all needed C++ standard library
    # features. Therefore, use the current platform's version, since Homebrew
    # builds and bottles are specific to the OS version.
    bazel_args << "--macos_sdk_version=#{MacOS.version}"

    with_env(
      # Bazel's environment and path resolution break Homebrew's shim scripts
      CC:  "/usr/bin/cc",
      CXX: "/usr/bin/c++",
    ) do
      system "bazel", "build", *bazel_args, "//verilog/tools/..."
    end

    bin.install %w[
      bazel-bin/verilog/tools/diff/verible-verilog-diff
      bazel-bin/verilog/tools/formatter/verible-verilog-format
      bazel-bin/verilog/tools/kythe/verible-verilog-kythe-extractor
      bazel-bin/verilog/tools/lint/verible-verilog-lint
      bazel-bin/verilog/tools/ls/verible-verilog-ls
      bazel-bin/verilog/tools/obfuscator/verible-verilog-obfuscate
      bazel-bin/verilog/tools/preprocessor/verible-verilog-preprocessor
      bazel-bin/verilog/tools/project/verible-verilog-project
      bazel-bin/verilog/tools/syntax/verible-verilog-syntax
    ]
  end

  test do
    (testpath/"test.sv").write <<~EOS
      module    m   ;endmodule
    EOS
    (testpath/"test_formatted.sv").write <<~EOS
      module m;
      endmodule
    EOS
    output = shell_output("#{bin}/verible-verilog-format test.sv")
    assert_equal File.read(testpath/"test_formatted.sv"), output
  end
end
