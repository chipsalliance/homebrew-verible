class Verible < Formula
  desc "SystemVerilog developer tools"
  homepage "https://github.com/google/verible"
  url "https://github.com/google/verible.git",
      tag:      "v0.0-1205-gfe310fb",
      revision: "fe310fb15d9dbfc6827d9e10742031d296fcca35"
  version "0.0-1205-gfe310fb"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/google/homebrew-verible/releases/download/verible-0.0-1205-gfe310fb"
    sha256 cellar: :any_skip_relocation, catalina: "d1bcb338203a46ca97288225c87127aa93fb516ffee5757828ffa455f24e56df"
  end

  head do
    url "https://github.com/google/verible.git"
  end

  depends_on "bazel" => :build
  depends_on "coreutils" => :build

  def install
    # prepend GNU coreutils path (with normal names) for GNU install
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    # ignore .brew_home when searching for targets:
    # .brew_home/_bazel is used as bazel output user root,
    # which confuses the hierarchical target search
    (buildpath/".bazelignore").write ".brew_home\n"

    bazel_args = %W[
      --jobs=#{ENV.make_jobs}
      --compilation_mode=opt
      --copt=-march=native
    ]
    system "bazel", "build", *bazel_args, "//..."
    system "bazel", "test", *bazel_args, "//..."
    system "bazel", "run", *bazel_args, "//:install", "--", bin.to_s
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
