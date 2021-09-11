require "commonmarker"
require "jekyll-commonmark-ghpages"
require "jekyll"
require "securerandom"

class CodeTabsCustomerRenderer < JekyllCommonMarkCustomRenderer
  @added_code_block = false
  @added_tabbed_code_block = false

  def render(node)
    if node.type == :document
      if (!@added_code_block)
        out("<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Roboto+Mono\"/>")
        out("<link rel=\"stylesheet\" href=\"assets/codeblock.css\"/>")
        @added_code_block = true
      end
    end
    super(node)
  end

  def code_block(node)
    previous_node_type = node&.previous&.type&.to_s
    next_node_type = node&.next&.type&.to_s

    using_custom_label = (split_lanugage_fence_info(node)&.size || 0) > 1

    is_header_item = previous_node_type != "code_block" && (next_node_type == "code_block" || using_custom_label)
    is_alone = previous_node_type != "code_block" && next_node_type != "code_block" && !using_custom_label

    if (is_header_item)
      create_tabbed_code_header(node)
      out("<li class=\"active-tab #{get_code_language_switcher_class(node)}\">")
    elsif (!is_alone) 
      out("<li class=\"#{get_code_language_switcher_class(node)}\">")
    end

    super(node)

    if (!is_alone) 
      out("</li>")
    end

    if (next_node_type != "code_block" && !is_alone)
      out("</ul>")
    end
  end

  def split_lanugage_fence_info(node)
    node&.fence_info&.split(/[\s,]/, 2)
  end

  def get_code_language(node)
    split_lanugage_fence_info(node)&.first || "unknown"
  end

  def get_code_language_label(node)
    split_lanugage_fence_info(node)&.last || "Code"
  end

  def get_code_language_switcher_class(node)
    lang = get_code_language(node)
    lang == "unknown" ? "" : "code_switcher_#{lang&.downcase}"
   end

  def create_tabbed_code_header(node)
    uuid = SecureRandom.uuid

    if (!@added_tabbed_code_block)
      out("<script src=\"assets/codeblock.js\"></script>")
      @added_tabbed_code_block = true
    end

    out("<ul class=\"code-tab-container #{uuid}\">")
    
    tab_number = 0
    tab_node = node
    while tab_node&.type&.to_s == 'code_block'
      label = get_code_language_label(tab_node)

      active_tab_class = (tab_number == 0) ? "active-tab" : ""
      code_lang_class = get_code_language_switcher_class(tab_node)
      out("<li class=\"#{active_tab_class} #{code_lang_class}\"><a onclick=\"selectTab('#{code_lang_class}', '#{uuid}', #{tab_number})\">#{label}</a></li>")

      tab_node = tab_node&.next
      tab_number = tab_number + 1
    end

    out("</ul>")

    out("<ul class=\"code-tab-switcher #{uuid}\">")
  end
end

class Jekyll::Converters::Markdown
  # A Markdown renderer which uses JekyllCommonMarkCustomRenderer to output the
  # final document.
  class JdvpCodeTabsCommonMark < CommonMarkGhPages
    def convert(content)
      doc = CommonMarker.render_doc(content, @parse_options, @extensions)
      html = CodeTabsCustomerRenderer.new(
        :options => @render_options,
        :extensions => @extensions
      ).render(doc)
      html.gsub(/<br data-jekyll-commonmark-ghpages>/, "\n")
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  #Copy CSS required for code tabs
  css = File.expand_path("../../assets/codeblock.css", __FILE__)
  FileUtils.cp(css, "#{site.in_dest_dir("assets/codeblock.css")}")

  #Copy required javascript
  css = File.expand_path("../../assets/codeblock.js", __FILE__)
  FileUtils.cp(css, "#{site.in_dest_dir("assets/codeblock.js")}")
end