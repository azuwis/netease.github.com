require 'nokogiri'

module Netease
  class Transform

    def initialize
    end

    def transform(site, page, input)
      # process on every project page
      if site.projects.include?(page)
        html = Nokogiri::HTML(input)
        html_main = html.css('div[role="main"]')

        # add 'lead' class to the first paragraph
        html_main.css('p').first['class'] = 'lead'

        # remove first h1/h2
        html_main.css('h1, h2').first.remove

        # remove meta data
        html_ul = html_main.css('ul')
        if html_ul.size > 0 && html_ul[0].css('li').text.include?('Tags:')
          html_ul[0].remove
        end

        html.to_html
      else
        input
      end
    end

  end
end
