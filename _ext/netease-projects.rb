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
        end
      end
      site.send( 'projects=', projects )
    end

  end
end
