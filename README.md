## jdvp-codetabs-commonmark 

[![Gem Version](https://badge.fury.io/rb/jdvp-codetabs-commonmark.svg)](https://badge.fury.io/rb/jdvp-codetabs-commonmark)

This Jekyll plugin is an extension of [jekyll-commonmark-ghpages] that adds one extra feature: the ability to use tabbed code blocks. The tabbed code blocks also have theme support and support copying code blocks. See [Testing Code Tabs] for a demo!

> Please note that this plugin will not work out of the box with GitHub Pages which only officially supports [these plugins]. I made a guide last year about getting around this [using GitHub Actions], but it may be a bit dated even if the idea is still the same. [My site] itself is generated using GitHub Actions so it can be done for sure with the right configuration.

## Installation

Add the jdvp-codetabs-commonmark gem inside of your `Gemfile`:

```ruby
group :jekyll_plugins do
  gem 'jdvp-codetabs-commonmark'
end
```

Update `_config.yml` to use this plugin as the markdown converter:

```yaml
markdown: JdvpCodeTabsCommonMark
``` 

Since this project extends the existing [jekyll-commonmark-ghpages], you can specify
extensions and options for the markdown conversion as seen in that project's README.

If necessary, run bundle install to install the missing gem:

```sh
bundle install
```

## Demo

Please see the following article that demos the features of this plugin: [Testing Code Tabs]. I will keep it as up-to-date as I can.

[jekyll-commonmark-ghpages]: https://github.com/github/jekyll-commonmark-ghpages
[these plugins]: https://pages.github.com/versions/
[Testing Code Tabs]: https://jdvp.me/articles/Testing-Code-Tabs
[using GitHub Actions]: https://jdvp.me/articles/Jekyll-with-GitHub-Actions
[My site]: https://jdvp.me/articles/
