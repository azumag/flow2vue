# encoding: utf-8

require 'fileutils'

flow = File.read('flow.txt')
puts flow

page_scans = flow.scan(/\[(.*)\]/).flatten

class Page
  attr_accessor :name, :page_body, :display_name, :body, :transitions
  def initialize(name, page_body, display_name, body, transitions)
    @name = name
    @page_body = page_body
    @display_name = display_name
    @body = body
    @transitions = transitions
  end
end

class Generator
  def generate_scaffold
    FileUtils.rm_r('dst')
    FileUtils.cp_r('.scaffold', 'dst')
  end

  def generate_route(page)
    routes_file = "dst/src/routes.js"
    routes = File.read(routes_file)

    import = "import #{page.name} from './#{page.name}';\n"

    components = "\n},\n{\n path: '/#{page.name.downcase}', component: #{page.name} },\n]"

    routes.gsub!(/},\n]/, components)

    File.write(routes_file, import + routes)
  end

  def generate_with(page)
    # page
    page_file =  "dst/src/#{page.name}.vue"
    FileUtils.cp('.scaffold/src/components/page.vue', page_file)
    pagesrc = File.read(page_file)
    pagesrc.gsub!('page', page.name.downcase)
    pagesrc.gsub!('PAGE_NAME', page.display_name) if page.display_name
    pagesrc.gsub!('BODY', page.body.join) if page.body

    trs = page.transitions.map do |trn|
      next unless trn
      # TODO: structurize
      "<router-link to='/#{trn[1].downcase.strip}'>#{trn.first}</router-link>"
    end
    pagesrc.gsub!('===LINK===', trs.join)

    File.write(page_file, pagesrc)

  end
end

gen = Generator.new
gen.generate_scaffold unless File.exist?('dst')

pages = []
page_scans.each do |page_scan|
  page_body = flow.scan(/^\[#{page_scan}\]$(.*?)(^\[|^\n)/m)
  transitions = []
  transitions << page_body.to_s.scan(/---(.*?)==>(.*?)\\n/).first
  page_body.to_s.scan(/==>.*?\\n(.*?)\\n==>(.*?)\\n/).each do |tr|
    transitions << tr
  end

  page = Page.new(
    page_scan,
    page_body,
    page_body.to_s.scan(/DisplayName\((.*?)\)/).flatten.first,
    page_body.to_s.scan(/DisplayName\(.*?\)((.|\r|\n)*?)---/m),
    transitions
  )
  pp page
  #pp page_body.to_s.scan(/(---|=.*?\\n)((.|\r|\n)*?)=(.*?)/)
  #gen.generate_route(page)
  gen.generate_with(page) 
end



