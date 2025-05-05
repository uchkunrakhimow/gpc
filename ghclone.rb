class Ghclone < Formula
  desc "Simple script for quickly cloning GitHub repositories"
  homepage "https://github.com/uchkunrakhimow/homebrew-ghclone"
  url "https://github.com/uchkunrakhimow/homebrew-ghclone/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6f5fe6852cedaf32652922061c823ea12d9e4039025cec7ad835adb0ad67312a"
  license "MIT"

  def install
    bin.install "bin/ghclone" => "ghclone"
  end

  test do
    # Check if the script runs and outputs usage/help information
    output = shell_output("#{bin}/ghclone --help", 0)
    assert_match "Usage", output
  end
end
