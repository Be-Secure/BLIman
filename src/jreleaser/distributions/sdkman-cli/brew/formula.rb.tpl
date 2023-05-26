class {{brewFormulaName}} < Formula
  desc "{{projectDescription}}"
  homepage "{{projectWebsite}}"
  url "{{distributionUrl}}"
  version "{{projectVersion}}"
  sha256 "{{distributionChecksumSha256}}"
  license "{{projectLicense}}"

  def install
    libexec.install Dir["*"]

    %w[tmp ext etc var candidates].each { |dir| mkdir libexec/dir }

    system "curl", "-s", "https://api.bliman.io/2/candidates/all", "-o", libexec/"var/candidates"

    (libexec/"etc/config").write <<~EOS
      bliman_auto_answer=false
      bliman_auto_complete=true
      bliman_auto_env=false
      bliman_beta_channel=false
      bliman_colour_enable=true
      bliman_curl_connect_timeout=7
      bliman_curl_max_time=10
      bliman_debug_mode=false
      bliman_insecure_ssl=false
      bliman_rosetta2_compatible=false
      bliman_selfupdate_feature=false
    EOS
  end

  test do
    assert_match version, shell_output("export BLIMAN_DIR=#{libexec} && source #{libexec}/bin/bliman-init.sh && bli version")
  end
end
