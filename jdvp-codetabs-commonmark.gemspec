Gem::Specification.new do |spec|
  spec.name          = "jdvp-codetabs-commonmark"
  spec.summary       = "CommonMark generator for Jekyll that adds tabbed code functionality"
  spec.version       = "1.0.0"
  spec.authors       = ["JD Porterfield"]
  spec.email         = "jd.porterfield@alumni.rice.edu"
  spec.homepage      = "https://github.com/jdvp/jdvp-codetabs-commonmark"
  spec.licenses      = ["MIT"]

  spec.files         = [
    "lib/jdvp-codetabs-commonmark.rb", 
    "assets/codeblock.css",
    "assets/codeblock.js",
    "assets/icon_copy.svg",
    "assets/icon_theme.svg"
  ]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_runtime_dependency "securerandom", "~> 0.2"
  spec.add_runtime_dependency "jekyll-commonmark-ghpages", "~> 0.1"
  spec.add_runtime_dependency "rouge", ">= 3", "< 4"

  spec.add_development_dependency "jekyll", ">= 4.2", "< 5.0"
end
