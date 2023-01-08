require "commonmarker"
require "jekyll-commonmark-ghpages"
require "jekyll"
require "securerandom"

class CodeTabsCustomerRenderer < JekyllCommonMarkCustomRenderer
  @added_copy_snackbar = false

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

    if (is_copy_action_enabled(node))
      if (!@added_copy_snackbar)
        out("<div id=\"code_copied_snackbar\">Copied!</div>")
        @added_copy_snackbar = true
      end
    end

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
      out("<button class=\"code_switcher_copy_button\" title=\"Copy\" onclick=\"copyText(\'#{individual_code_block_id}\', \'#{get_code_copy_Lines(node)}\')\"></button>")
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
    node&.fence_info&.sub(/ codeCopyEnabled=?"?([\ \-\,0-9]*)"?/, "")&.split(/[\s,]/, 2)
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

  def get_code_copy_Lines(node)
    node&.fence_info[/ codeCopyEnabled=?"?([\ \-\,0-9]*)"?/, 1] || ""
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

def get_resource_string(site)
 return "<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Roboto+Mono\"/>" +
        "<link rel=\"stylesheet\" href=\"#{site.baseurl}/assets/codeblock.css\"/>" +
        "<script src=\"#{site.baseurl}/assets/codeblock.js\"></script>"
end

def add_resource_links_in_html_head(site)
  site_directory = "#{site.in_dest_dir("/")}"

  # For every html file in the generated site 
  Dir.glob("**/*.html", base: site_directory).each do |file_name|
    file_plus_path = "#{site_directory}#{file_name}"

    # Check if the file contains a code switcher and skip it if it does not
    if (!File.foreach(file_plus_path).grep(/code_switcher_container_parent/).any?)
      next
    end

    # If the file has a code switcher and a head element, add the resource links to the end of the head element
    if (File.foreach(file_plus_path).grep(/<\/head>/).any?)
      File.write(file_plus_path, File.open(file_plus_path, &:read).sub("</head>","#{get_resource_string(site)}</head>"))
    # Otherwise if it has a html element add a head element with the resource links
    elsif (File.foreach(file_plus_path).grep(/<\/html>/).any?)
      File.write(file_plus_path, File.open(file_plus_path, &:read).sub(/(<html.*>)/,"#{$1}<head>#{get_resource_string(site)}</head>"))
    end
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

  #Add CSS & JS references to files that use code tabs
  add_resource_links_in_html_head(site)
end