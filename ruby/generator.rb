# encoding: utf-8

require 'fileutils'

class Generator
  DST_DIR = 'dst'
  SRC_DIR = '.scaffold'
  BASE_DIR = '/base'

  APP_FILE = '/src/App.vue'
  ROUTES_FILE = '/src/routes.js'
  PAGE_TEMPLATE_FILE = '/src/components/page.vue'

  class << self

    def generate(pages, params)
      rewrite = params['f']
      
      if rewrite 
        generate_scaffold 
      else
        if File.exist?('dst')
          puts "The 'dst' directory is already exist."
          puts "Please use -f option or delete the dst directory."
          exit 1
        end
      end
      copy_routes if params['nonuxt']
      pages.each do |page|
        add_routes(page) if params['nonuxt']
        generate_with(page, params) 
      end

      title = params['t']
      rewrite_app_title(title) if title
    end

    def generate_scaffold
      FileUtils.rm_r(DST_DIR) if File.exist?(DST_DIR)
      FileUtils.cp_r(SRC_DIR + BASE_DIR, DST_DIR)
    end

    def rewrite_app_title(title)
      FileUtils.cp(SRC_DIR + BASE_DIR + APP_FILE, DST_DIR + APP_FILE)
      app = File.read(DST_DIR + APP_FILE)
      app.gsub!('APP_TITLE', title)
      File.write(DST_DIR + APP_FILE, app)
    end

    def copy_routes
      FileUtils.cp(SRC_DIR + BASE_DIR + ROUTES_FILE, DST_DIR + ROUTES_FILE)
    end

    def add_routes(page)
      routes = File.read(DST_DIR + ROUTES_FILE)
      import = "import #{page.name} from './#{page.name}';\n"
      components = "\n},\n{\n path: '/#{page.name.to_snake}', component: #{page.name} },\n]"
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

    def generate_with(page, params)
      # page
      page_file =  DST_DIR + "/src/#{page.name}.vue"
      FileUtils.cp(SRC_DIR + BASE_DIR + PAGE_TEMPLATE_FILE, page_file)
      pagesrc = File.read(page_file)
      pagesrc.gsub!('PAGE_ID', page.name)
      pagesrc.gsub!('PAGE_NAME', page.display_name) if page.display_name

      # BODY GENERATION
      body = page.body.map do |line|
        "<div>#{line}</div>"
      end
      pagesrc.gsub!('===BODY===', body.join("\n"))

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
        pagesrc.gsub!('===FORM===', form_src.join("\n"))
        data['valid'] = true
      else
        pagesrc.gsub!('===FORM===', '')
      end

      # TRANSITIONS GENERATION
      trs = page.transitions.map do |trn|
        next unless trn
        # TODO: structurize
        #"<router-link to='/#{trn[2].strip.sub(/^\*/,'').downcase}'>#{trn.first}</router-link>/"
        "<v-btn @click='$router.push(\"/#{trn[2].strip.sub(/^\*/,'').downcase}\")'>#{trn.first}</v-btn>"
      end
      pagesrc.gsub!('===LINK===', trs.join("\n"))

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
end


