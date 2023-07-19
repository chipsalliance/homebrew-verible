class Verible < Formula
  desc "SystemVerilog developer tools"
  homepage "https://github.com/chipsalliance/verible"
  url "https://github.com/chipsalliance/verible.git",
      branch:   "master",
      tag:      "v0.0-3381-gf5d08d3a",
      revision: "f5d08d3a1c28055b301ecda499d2b031a4e6b68f"
  version "0.0-3381-gf5d08d3a"
  license "Apache-2.0"
  env :std
  head do
    url "https://github.com/chipsalliance/verible.git"
  end

  depends_on "bazel" => :build

  def install
    optflag = if Hardware::CPU.arm? && OS.mac?
      "-mcpu=apple-m1"
    elsif build.bottle?
      "-march=#{Hardware.oldest_cpu}"
    else
      "-march=native"
    end
    bazel_args = %W[
      --jobs=#{ENV.make_jobs}
      --compilation_mode=opt
      --copt=#{optflag}
      --linkopt=-Wl,-rpath,#{rpath}
      --verbose_failures
    ]
    system "bazel", "build", *bazel_args, "//verilog/tools/..."

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
