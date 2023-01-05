require "commonmarker"
require "jekyll-commonmark-ghpages"
require "jekyll"
require "securerandom"

class CodeTabsCustomerRenderer < JekyllCommonMarkCustomRenderer
  @added_assets_links = false
  @added_copy_snackbar = false

  def render(node)
    if node.type == :document
      if (!@added_assets_links)
        #Add references to the fonts, css, and js required
        out("<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Roboto+Mono\"/>")
        out("<link rel=\"stylesheet\" href=\"JdvpCodeTabs-baseurl/assets/codeblock.css\"/>")
        out("<script src=\"JdvpCodeTabs-baseurl/assets/codeblock.js\"></script>")
        @added_assets_links = true
      end
    end
    super(node)
  end

  def code_block(node)
    #Determine what objects this code block is surrounded by.
    previous_node_type = node&.previous&.type&.to_s
    next_node_type = node&.next&.type&.to_s

    #If this item has neighboring code blocks or a custom tab header, it should show tabs
    using_custom_label = (split_lanugage_fence_info(node)&.size || 0) > 1
    is_header_item = previous_node_type != "code_block" && (next_node_type == "code_block" || using_custom_label)
    is_alone = previous_node_type != "code_block" && next_node_type != "code_block" && !using_custom_label

    #Get a unique ID per code block in order to allow code copying
    individual_code_block_id = SecureRandom.uuid

    #Create a header if necessary and then creates the wrapper for each item
    #This allows tabs to be selected individaully
    if (is_header_item)
      create_tabbed_code_header(node)
      out("<li class=\"code_switcher_container_parent active-tab #{get_code_language_switcher_class(node)} #{individual_code_block_id}\">")
    elsif (!is_alone) 
      out("<li class=\"code_switcher_container_parent #{get_code_language_switcher_class(node)} #{individual_code_block_id}\">")
    else 
      out("<div class=\"code_switcher_container_parent #{individual_code_block_id}\">")
    end

    #Add the action buttons for this code block
    #Changing theme button is added to all code blocks, but the copy button is configurable.
    out("<div class=\"code_switcher_code_action_container\">")
    if (is_copy_action_enabled(node))
      if (!@added_copy_snackbar)
        out("<div id=\"code_copied_snackbar\">Copied!</div>")
        @added_copy_snackbar = true
      end
      out("<button class=\"code_switcher_copy_button\" title=\"Copy\" onclick=\"copyText(\'#{individual_code_block_id}\')\"></button>")
    end
    out("<button class=\"code_switcher_theme_button\" onclick=\"updateTheme(true)\"></button>")
    out("</div>")

    #Generate the actual code block from markdown using the super class
    super(node)

    #Close this code block's container
    if (!is_alone) 
      out("</li>")
    else
      out("</div>")
    end

    #Closee the entire tab container if this is the last code block in a tabbed container
    if (next_node_type != "code_block" && !is_alone)
      out("</ul>")
    end
  end

  #Splits the code fence into the language and extra info
  #Removes the codeCopyEnabled item which is just a flag used to enable showing a copy action button
  def split_lanugage_fence_info(node)
    node&.fence_info&.sub(" codeCopyEnabled", "")&.split(/[\s,]/, 2)
  end

  #Gets the language used in the code fence (the part typically immediately after a triple backtick in markdown)
  def get_code_language(node)
    split_lanugage_fence_info(node)&.first || "unknown"
  end

  #Gets the label shown to the user. This is the rest of code fence after the first space
  def get_code_language_label(node)
    split_lanugage_fence_info(node)&.last || "Code"
  end

  #Gets language class name used for the code switcher. This allows selection of the same language across
  #multiple code tab items.
  def get_code_language_switcher_class(node)
    lang = get_code_language(node)
    lang == "unknown" ? "" : "code_switcher_#{lang&.downcase}"
  end

  #Determines whether the copy action should be shown for a given code block based on info in the code fence info
  def is_copy_action_enabled(node)
    node&.fence_info&.include?("codeCopyEnabled") || false
  end

  #Creates the tab header portion of the code switcher
  def create_tabbed_code_header(node)
    uuid = SecureRandom.uuid

    out("<ul class=\"code-tab-container #{uuid}\">")
    
    tab_number = 0
    tab_node = node
    while tab_node&.type&.to_s == 'code_block'
      label = get_code_language_label(tab_node)

      active_tab_class = (tab_number == 0) ? "active-tab" : ""
      code_lang_class = get_code_language_switcher_class(tab_node)
      out("<li class=\"#{active_tab_class} #{code_lang_class}\">")
      out("<a onclick=\"selectTab('#{code_lang_class}', '#{uuid}', #{tab_number})\">#{label}</a>")
      out("</li>")

      tab_node = tab_node&.next
      tab_number = tab_number + 1
    end

    out("</ul>")

    out("<ul class=\"code-tab-switcher #{uuid}\">")
  end
end

class Jekyll::Converters::Markdown
  # A Markdown renderer which uses CodeTabsCustomerRenderer to output the
  # final document. The CodeTabsCustomerRenderer renderer mainly uses the
  # parent render but updates code blocks to allow for tabbing behavior
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

Jekyll::Hooks.register :documents, :post_convert do |post|
  if post.content.include? "JdvpCodeTabs-baseurl"
    post.content = post.content.gsub("JdvpCodeTabs-baseurl", "#{post.site.baseurl}")
  end
end

Jekyll::Hooks.register :pages, :post_convert do |post|
  if post.content.include? "JdvpCodeTabs-baseurl"
    post.content = post.content.gsub("JdvpCodeTabs-baseurl", "#{post.site.baseurl}")
  end
end

Jekyll::Hooks.register :posts, :post_convert do |post|
  if post.content.include? "JdvpCodeTabs-baseurl"
    post.content = post.content.gsub("JdvpCodeTabs-baseurl", "#{post.site.baseurl}")
  end
end

#After the site is written, the necessary files this plugin's generateed code needs are also written
Jekyll::Hooks.register :site, :post_write do |site|
  #Copy CSS required for code tabs
  css = File.expand_path("../../assets/codeblock.css", __FILE__)
  FileUtils.mkdir_p("#{site.in_dest_dir("assets/")}")
  FileUtils.cp(css, "#{site.in_dest_dir("assets/codeblock.css")}")

  #Copy required javascript
  js = File.expand_path("../../assets/codeblock.js", __FILE__)
  FileUtils.cp(js, "#{site.in_dest_dir("assets/codeblock.js")}")

  #Copy icons for copy and theme actions
  copy_icon = File.expand_path("../../assets/icon_copy.svg", __FILE__)
  FileUtils.cp(copy_icon, "#{site.in_dest_dir("assets/icon_copy.svg")}")
  theme_icon = File.expand_path("../../assets/icon_theme.svg", __FILE__)
  FileUtils.cp(theme_icon, "#{site.in_dest_dir("assets/icon_theme.svg")}")
end