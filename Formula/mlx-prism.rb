class MlxPrism < Formula
  desc "PrismML fork of Apple MLX with 1-bit quantization + mlx-lm for Bonsai 1-bit inference"
  homepage "https://github.com/PrismML-Eng/mlx"
  url "https://github.com/PrismML-Eng/mlx/archive/88c9c205a50fbaaf432a50338570d85273925601.tar.gz"
  version "0.0.2-prism-20260618"
  sha256 "70982e49af2284a7bb592707a3e4699b0c351b6b8035c7de5cc2f8719843ecd8"
  license "MIT"

  depends_on "python@3.14"
  depends_on "mlx-lm"

  def install
    venv = libexec/"venv"
    python = Formula["python@3.14"].opt_bin/"python3.14"

    # Patch setup.py: replace git rev-parse call with hardcoded hash so tarball builds work
    inreplace "setup.py",
      /git_hash = \(\n.*subprocess\.run\(.*?\)\n.*\.stdout\.strip\(\)\n.*\.decode\(\)\n.*\)\n.*version = f"\{version\}\+\{git_hash\}"/m,
      'git_hash = "prism"\n        version = f"{version}+{git_hash}"'

    system python, "-m", "venv", venv
    pip = venv/"bin/pip"

    system pip, "install", "--quiet", "setuptools", "wheel", "cmake"
    system pip, "install", "--quiet", "mlx-lm"

    # Install PrismML fork from local patched source
    system pip, "install", "--quiet", "--no-build-isolation", "."

    %w[chat generate server].each do |cmd|
      (bin/"bonsai-#{cmd}").write <<~SH
        #!/bin/bash
        exec "#{venv}/bin/mlx_lm.#{cmd}" "$@"
      SH
      chmod 0755, bin/"bonsai-#{cmd}"
    end
  end

  test do
    system bin/"bonsai-generate", "--help"
  end
end
