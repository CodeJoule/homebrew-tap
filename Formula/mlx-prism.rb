class MlxPrism < Formula
  desc "PrismML fork of Apple MLX with 1-bit quantization + mlx-lm for Bonsai 1-bit inference"
  homepage "https://github.com/PrismML-Eng/mlx"
  url "https://github.com/PrismML-Eng/mlx/archive/88c9c205a50fbaaf432a50338570d85273925601.tar.gz"
  version "0.0.6-prism-20260619"
  sha256 "70982e49af2284a7bb592707a3e4699b0c351b6b8035c7de5cc2f8719843ecd8"
  license "MIT"

  depends_on "python@3.14"
  depends_on "mlx-lm"
  depends_on "cmake"

  def install
    venv = libexec/"venv"
    python = Formula["python@3.14"].opt_bin/"python3.14"

    # Patch setup.py to skip git rev-parse (fails in tarball builds with no .git dir)
    # Replace the entire get_version function body's git section with a static value
    inreplace "setup.py",
      "git_hash = (\n" \
      "            subprocess.run(\n" \
      "                \"git rev-parse --short HEAD\".split(),\n" \
      "                capture_output=True,\n" \
      "                check=True,\n" \
      "            )\n" \
      "            .stdout.strip()\n" \
      "            .decode()\n" \
      "        )\n" \
      "        version = f\"{version}+{git_hash}\"",
      "git_hash = \"prism\"\n        version = f\"{version}+{git_hash}\""

    system python, "-m", "venv", venv
    pip = venv/"bin/pip"

    system pip, "install", "--quiet", "setuptools", "wheel"
    # Symlink brew cmake into venv so the C extension build finds it
    (venv/"bin").install_symlink Formula["cmake"].opt_bin/"cmake"
    system pip, "install", "--quiet", "mlx-lm"

    # Disable Metal — Xcode beta lacks the Metal Toolchain component (separate download).
    # CMAKE_ARGS is read by MLX's setup.py and passed through to cmake configure.
    # CPU-only still supports 1-bit ops via the fallback path.
    ENV["CMAKE_ARGS"] = "-DMLX_BUILD_METAL=OFF"
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
