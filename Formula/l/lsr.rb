class Lsr < Formula
  desc "Ls but with io_uring"
  homepage "https://tangled.sh/@rockorager.dev/lsr"
  url "https://tangled.sh/@rockorager.dev/lsr",
      tag:      "v1.0.0",
      revision: "9bfcae0be1d3ee2db176bb8001c0f46650484249"
  license "MIT"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "687a37a2078c93c0ab63671290f760d81b802b6f45b93537e2d1d9e9e0b30c15"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9c6c3b3168fc24f4b9b0d3534da7bcdbf63b260fc893c8ed4f1ee0ea65d67f17"
    sha256 cellar: :any_skip_relocation, sonoma:        "53dc42884592df8d0df131a545b6fab5e01df4e35cd71bf5b5ffd1e21ff8dbe5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5195ad04f4d71a0bb6867155e2eac5e14f56d8b9bd0a50852cfaf0998cc2f366"
  end

  # Aligned to `zig@0.14` formula. Can be removed if upstream updates to newer Zig.
  deprecate! date: "2026-02-19", because: "does not build with Zig >= 0.15"

  depends_on "zig@0.14" => :build # https://tangled.sh/@rockorager.dev/lsr/issues/13

  def install
    # Fix illegal instruction errors when using bottles on older CPUs.
    # https://github.com/Homebrew/homebrew-core/issues/92282
    cpu = case Hardware.oldest_cpu
    when :arm_vortex_tempest then "apple_m1" # See `zig targets`.
    when :armv8 then "xgene1" # Closest to `-march=armv8-a`
    else Hardware.oldest_cpu
    end

    args = []
    args << "-Dcpu=#{cpu}" if build.bottle?

    system "zig", "build", *args, *std_zig_args(release_mode: :small)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lsr --version")

    touch "test.txt"
    if OS.linux?
      # sudo required
      assert_match "error: PermissionDenied", shell_output("#{bin}/lsr 2>&1", 1)
    else
      assert_match "test.txt", shell_output(bin/"lsr")
    end
  end
end
