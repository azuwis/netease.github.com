require 'nokogiri'

module Netease
  class Projects

    def initialize(projects_dir='_projects', opts={})
      @projects_dir = projects_dir
      @default_layout   = opts[:default_layout] || 'project'
    end

    def capitalize(string)
      string[0] = string[0].upcase
      string
    end

    def execute(site)
      projects = []
      Dir[ "#{site.dir}/#{@projects_dir}/*" ].each do |entry|
        project = {}
        if (File.directory?("#{entry}/.git"))
          # readme
          readme_files = Dir.glob("#{entry}/README.md", File::FNM_CASEFOLD)
          readme_files += Dir.glob("#{entry}/README", File::FNM_CASEFOLD)
          if readme_files.size > 0
            project = site.engine.load_page(readme_files[0])
            parsed_html = Nokogiri::HTML(project.content)

            # title
            splited_title = parsed_html.css('h1, h2')[0].text.split(' - ')
            project.title = capitalize(splited_title[0])
            if splited_title.size > 1
              project.subtitle = capitalize(splited_title[1..-1].join(' - '))
            end

            # desc
            project.desc = parsed_html.css('p')[0].to_s

            # tags and links
            project.meta = {}
            parsed_html.css('ul')[0].css('li').each do |item|
              case item.text
              when /[Tt]ags: (?<tags>.+)/
                project.tags = $~[:tags].downcase.split(',').map {|x| x.strip}
              when /^(?<key>\w+): (?<value>.+)/
                project.meta[$~[:key].downcase.to_sym] = $~[:value]
              end
            end

            # prop for awestruct
            project.layout = @default_layout
            project.output_path = "/projects/#{project.title}.html"

            projects << project
            site.pages << project
          end

          # authors
          author_files = Dir.glob("#{entry}/AUTHORS", File::FNM_CASEFOLD)
          author_files += Dir.glob("#{entry}/AUTHOR", File::FNM_CASEFOLD)
          if author_files.size > 0
            project.authors = []
            author_text = open(author_files[0]).readlines
            pattern = /
              ^[-*]
              \s+
              (?<name>[^<]+)       # name
              /x
            author = {}
            author_text.each do |line|
              if line =~ pattern
                # save previous author when matching next one
                if author.has_key?(:name)
                  project.authors << author
                  author = {}
                end
                author[:name] = capitalize($~[:name].strip)
                line.scan(/<([^>]+)>/) do |item|
                  case item[0]
                  when /^https?:\/\//
                    author[:homepage] = item[0]
                  when /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
                    author[:email] = item[0]
                  when /^(?<key>\w+):\s?@?(?<value>.+)/
                    author[$~[:key].downcase.to_sym] = $~[:value]
                  end
                end
              else
                if author[:desc] == nil
                  author[:desc] = line
                else
                  author[:desc] += line
                end
              end
              # save author at EOF
              if line == author_text.last
                project.authors << author
              end
            end
          end
        end
      end
      site.send( 'projects=', projects )
    end

  end
end
