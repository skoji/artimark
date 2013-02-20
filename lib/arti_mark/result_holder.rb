module ArtiMark
  class Context
    attr_accessor :title, :head_inserters, :toc
    def initialize(param = {})
      @head_inserters = []
      @toc = []
      @lang = param[:lang] || 'en'
      @title = param[:title] || 'ArtiMark generated document'
      @stylesheets = param[:stylesheets] || []
      @stylesheets_alt = param[:stylesheets_alt] || []
      @pages = []
      head_inserter do
        ret = ""
        @stylesheets.each { |s|
          ret << "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{s}\" />\n"
        }
        @stylesheets_alt.each { |s,m|
          ret << "<link rel=\"stylesheet\" type=\"text/css\" media = \"#{m}\" href=\"#{s}\" />\n"  
        }
        ret
      end
    end
  
    def head_inserter(&block)
      head_inserters << block
    end

    def start_html(title = nil)
      @title = title if !title.nil?
      if @pages.size >0 && !@pages.last.frozen?
        end_html
      end
      page = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      page << "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"#{@lang}\" xml:lang=\"#{@lang}\">\n"
      page << "<head>\n"
      page << "<title>#{@title}</title>\n"
      @head_inserters.each {
        |f|
        page << f.call
      }
      page << "</head>\n"
      page << "<body>\n"
      @pages << page
      @toc << title
    end

    def end_html
      page = @pages.last
      if !page.frozen?
        page << "</body>\n"
        page << "</html>\n"
        page.freeze 
      end
    end

    def toc=(label)
      @toc[-1] = label if @toc.size > 0
    end

    def <<(text)
      if @pages.size == 0 || @pages.last.frozen?
        start_html
      end
      @pages.last << text
    end

    def result
      if !@pages.last.frozen?
        end_html
      end
      @pages
    end
  end
end