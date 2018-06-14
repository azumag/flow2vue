# encoding: utf-8

require 'fileutils'

flow = File.read('flow.txt')
flow << "\n" # insert \n for easy parsing
#puts flow
#
APP_TITLE = 'VUE_GEN_TITLE'

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

  def rewrite_app_title
    app_file = 'dst/src/App.vue'
    FileUtils.cp('.scaffold/src/App.vue', app_file)
    app = File.read(app_file)
    app.gsub!('APP_TITLE', APP_TITLE)
    File.write(app_file, app)
  end

  def copy_routes
    routes_file = "dst/src/routes.js"
    FileUtils.cp('.scaffold/src/routes.js', routes_file)
  end

  def generate_route(page)
    routes_file = "dst/src/routes.js"
    routes = File.read(routes_file)

    import = "import #{page.name} from './#{page.name}';\n"

    components = "\n},\n{\n path: '/#{page.name.downcase}', component: #{page.name} },\n]"

    routes.gsub!(/\},\n\]/, components)

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
      "<router-link to='/#{trn[2].downcase.strip}'>#{trn.first}</router-link>/"
    end
    pagesrc.gsub!('===LINK===', trs.join)

    File.write(page_file, pagesrc)

  end
end

gen = Generator.new
gen.generate_scaffold unless File.exist?('dst')
#gen.generate_scaffold 
gen.rewrite_app_title
gen.copy_routes

pages = []
page_scans.each do |page_scan|
  page_body = flow.scan(/^\[#{page_scan}\]$(.*?)(^\[|^\n)/m)
  #pp flow
  #pp flow.scan(/\[#{page_scan}\]\n(.*?)^\n$/m)
  transitions = []
 
  ## parse transitions
  tr_state = nil
  trs = []
  page_body.join.each_line do |tr|
    unless tr.scan('---').compact.empty?
      tr_state = :head
      next
    end
    case tr_state
    when :head
      trs = [tr]
      tr_state = :arrow
    when :arrow
      trs << tr.scan(/=({.*?})?=>(.*)/).flatten
      transitions << trs.flatten
      tr_state = :head
    end
  end

  forms = []
  page_body.join.each_line do |line|

  end

  page = Page.new(
    page_scan,
    page_body,
    page_body.to_s.scan(/DisplayName\((.*?)\)/).flatten.first,
    page_body.to_s.scan(/DisplayName\(.*?\)((.|\r|\n)*?)---/m),
    transitions
  )
  gen.generate_route(page)
  gen.generate_with(page) 
end


