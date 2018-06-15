# encoding: utf-8

require 'fileutils'

APP_TITLE = ARGV[1] || 'NO TITLE'

class Page
  attr_accessor :name, :page_body, :forms, :display_name, :body, :transitions, :independent
  def initialize(name, page_body, forms, display_name, body, transitions)
    @name = name.delete('*')
    @page_body = page_body
    @forms = forms
    @display_name = display_name
    @body = body
    @transitions = transitions
    @independent = !name.scan(/^\*/).empty?
  end
end

class Generator
  DST_DIR = 'dst'
  SRC_DIR = '.scaffold'

  APP_FILE = '/src/App.vue'
  ROUTES_FILE = '/src/routes.js'
  PAGE_TEMPLATE_FILE = '/src/components/page.vue'

  def generate_scaffold
    FileUtils.rm_r(DST_DIR) if File.exist?(DST_DIR)
    FileUtils.cp_r(SRC_DIR, DST_DIR)
  end

  def rewrite_app_title
    FileUtils.cp(SRC_DIR + APP_FILE, DST_DIR + APP_FILE)
    app = File.read(DST_DIR + APP_FILE)
    app.gsub!('APP_TITLE', APP_TITLE)
    File.write(DST_DIR + APP_FILE, app)
  end

  def copy_routes
    FileUtils.cp(SRC_DIR + ROUTES_FILE, DST_DIR + ROUTES_FILE)
  end

  def add_routes(page)
    routes = File.read(DST_DIR + ROUTES_FILE)
    import = "import #{page.name} from './#{page.name}';\n"
    components = "\n},\n{\n path: '/#{page.name.downcase}', component: #{page.name} },\n]"
    routes.gsub!(/\},\n\]/, components)
    File.write(DST_DIR + ROUTES_FILE, import + routes)
  end

  def build_tag(tag, name, label, required, rules)
    rule = ":rules='#{rules}'" unless rules.empty?
    "<#{tag} v-model='#{name}' #{rule} label='#{label}' #{required}></#{tag}>"
  end

  def build_data(data)
    data_str = ""
    data.each do |k, v|
      data_str << "#{k}: #{v},"
    end
    "{#{data_str}}"
  end

  def generate_with(page)
    # page
    page_file =  DST_DIR + "/src/#{page.name}.vue"
    FileUtils.cp(SRC_DIR + PAGE_TEMPLATE_FILE, page_file)
    pagesrc = File.read(page_file)
    pagesrc.gsub!('PAGE_ID', page.name.downcase)
    pagesrc.gsub!('PAGE_NAME', page.display_name) if page.display_name

    # BODY GENERATION
    body = page.body.map do |line|
      "<div>#{line}</div>"
    end
    pagesrc.gsub!('BODY', body.join("\n"))

    # FORM GENERATION 
    data = {}
    unless page.forms.flatten.empty?
      form_src = page.forms.map do |form|
        next if form.empty?
        next if form[0] != "Input"
        form[2] = '' unless form[2]
        # FORMAT;
        # ["Input", "email", "(required)", "Email", "メール"]
        name = form[3]
        label = form[4]
        required = form[2].delete('(').delete(')')
        data[name] = '\'\''
        rules = ''
        ## MAKE RULES FOR VALIDATION
        unless required.empty?
          case form[1]
          when 'email'
            data['emailRules'] = "[v => !!v || 'Email is required', v => /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v) || 'Email must be valid']"
            rules = 'emailRules'
          when 'text'
            data['textRules'] = "[v => !!v || 'Text is required']" 
            rules = 'textRules'
          when 'password'
            data['passwordRules'] = "[v => !!v || 'Password is required']" 
            data['mask'] = true
            rules = 'passwordRules'
          end
        end
        build_tag('v-text-field', name, label, required, rules)
      end
      form_src.unshift("<v-form v-model='valid' lazy-validation>")
      form_src << "</v-form>"
      pagesrc.gsub!('===FORM===', form_src.join)
      data['valid'] = true
    else
      pagesrc.gsub!('===FORM===', '')
    end

    # TRANSITIONS GENERATION
    trs = page.transitions.map do |trn|
      next unless trn
      # TODO: structurize
      "<router-link to='/#{trn[2].strip.gsub(/^\*/,'').downcase}'>#{trn.first}</router-link>/"
    end
    pagesrc.gsub!('===LINK===', trs.join)

    pagesrc.gsub!('===DATA===', build_data(data))

    File.write(page_file, pagesrc)

    add_navbar(page) if page.independent
  end

  def add_navbar(page)
    page_file =  "dst/src/App.vue"
    pagesrc = File.read(page_file)

    tile = []
    tile << "<v-list-tile @click=\"$router.push('/#{page.name.downcase}')\">"
    tile << "<v-list-tile-action>"
    tile << "<v-icon>link</v-icon>" # TODO
    tile << "</v-list-tile-action>"
    tile << "<v-list-tile-content>"
    tile << "<v-list-tile-title>"
    tile << "#{page.display_name}"
    tile << "</v-list-tile-title>"
    tile << "</v-list-tile-content>"
    tile << "</v-list-tile>"
    tile << "</v-list>"

    pagesrc.gsub!('</v-list>', tile.join("\n"))

    File.write(page_file, pagesrc)

  end
end

gen = Generator.new
gen.generate_scaffold unless File.exist?('dst')
#gen.generate_scaffold 
gen.rewrite_app_title
gen.copy_routes

flow = File.read(ARGV[0])
flow << "\n" # insert \n for easy parsing
flow.delete!("\r")
page_scans = flow.scan(/\[(.*)\]/).flatten

pages = []
page_scans.each do |page_scan|
  puts "------#{page_scan}"
  page_body = flow.scan(/^\[#{page_scan.gsub('*','\*')}\]$(.*?)(^\[|^\n)/m)
  #pp page_body
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
    forms << line.scan(/\((.*?):(.*?)\)(\(.*?\))?(.*?):(.*?)$/).flatten
    break unless line.scan('---').empty?
  end

  body = []
  page_body.join.each_line do |line|
    next if line[0] == '('
    next if line[0] == 'T'
    break unless line.scan('---').empty?
    body << line
  end


  #pp page_body.to_s.scan(/Title\((.*?)\)/).flatten.first

  page = Page.new(
    page_scan,
    page_body,
    forms,
    page_body.to_s.scan(/Title\((.*?)\)/).flatten.first,
    body,
    transitions
  )
  gen.add_routes(page)
  gen.generate_with(page) 

#  pp page
end


