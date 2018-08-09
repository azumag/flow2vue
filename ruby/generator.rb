# encoding: utf-8

require 'fileutils'

class Generator
  DST_DIR = 'dst'
  SRC_DIR = '.scaffold'
  BASE_DIR = '/base'
  CLI2_DIR = '/cli2'

  APP_FILE = '/src/App.vue'
  ROUTES_FILE = '/src/routes.js'
  PAGE_TEMPLATE_FILE = '/src/components/page.vue'

  class << self

    def generate(pages, params)
      rewrite = params['f']
      
      if rewrite 
        generate_scaffold(params)
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

    def generate_scaffold(params)
      unless params['pageonly']
        FileUtils.rm_r(DST_DIR) if File.exist?(DST_DIR)
        FileUtils.copy_entry(SRC_DIR + CLI2_DIR, DST_DIR) if params['cli2'] 
      end
      FileUtils.rm_r(DST_DIR + '/src') if File.exist?(DST_DIR + '/src')
      FileUtils.copy_entry(SRC_DIR + BASE_DIR, DST_DIR)
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
      import = "import #{page.name} from './#{page.name}'\n"
      components = "},\n  {\n    path: '/#{page.name.to_snake}', component: #{page.name}\n  }\n]"

      routes.gsub!(/\}\n\]/, components)
      File.write(DST_DIR + ROUTES_FILE, import + routes)
    end

    def build_tag(tag, name, label, required, rules)
      rule = ":rules='#{rules}'" unless rules.empty?
      #"<#{tag} v-model='#{name}' #{rule} label='#{label}' #{required}></#{tag}>"
      "<div><label>#{name}</label><#{tag} /></div>"
    end

    def build_data(data)
      data_str = []
      data.each do |k, v|
        data_str << "#{k}: #{v}"
      end
      
      if data_str.empty?
        ''
      else
        "\n      #{data_str.join(",\n      ")}\n    "
      end
    end

    def generate_with(page, params)
      # page
      page_file =  DST_DIR + "/src/#{page.name}.vue"
      FileUtils.cp(SRC_DIR + BASE_DIR + PAGE_TEMPLATE_FILE, page_file)
      pagesrc = File.read(page_file)
      pagesrc.gsub!('PAGE_ID', page.name)
      pagesrc.gsub!('PAGE_NAME', page.display_name) if page.display_name

      # BODY GENERATION
      body = page.body.map {|line| "<div>#{line}</div>" }
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
         # unless required.empty?
         #   case form[1]
         #   when 'email'
         #     data['emailRules'] = "[v => !!v || 'Email is required', v => /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v) || 'Email must be valid']"
         #     rules = 'emailRules'
         #   when 'text'
         #     data['textRules'] = "[v => !!v || 'Text is required']" 
         #     rules = 'textRules'
         #   when 'password'
         #     data['passwordRules'] = "[v => !!v || 'Password is required']" 
         #     data['mask'] = true
         #     rules = 'passwordRules'
         #   end
         # end

          #build_tag('v-text-field', name, label, required, rules)
          build_tag('input', name, label, nil, rules)
        end
        #form_src.unshift("<v-form v-model='valid' lazy-validation>")
        form_src.unshift("<form>")
        #form_src << "</v-form>"
        form_src << "</form>"
        pagesrc.gsub!('===FORM===', form_src.compact.join("\n"))
        data['valid'] = true
      else
        pagesrc.gsub!('===FORM===', '')
      end

      # TRANSITIONS GENERATION
      trs = page.transitions.map do |trn|
        next unless trn
        # TODO: structurize
        #"<router-link to='/#{trn[2].strip.sub(/^\*/,'').downcase}'>#{trn.first}</router-link>/"
        "<div>\n<router-link to=\"/#{trn[2].strip.sub(/^\*/,'').to_snake}\">#{trn.first}</router-link></div>"
        #"<v-btn @click='$router.push(\"/#{trn[2].strip.sub(/^\*/,'').to_snake}\")'>#{trn.first}</v-btn>"
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
      if true
        tile << "<div>"
        tile << "<router-link to=\"$router.push('/#{page.name.to_snake}')\">"
        tile << "#{page.display_name}"
        tile << "</router-link>"
        tile << "</div>"
      else
        tile << "<v-list-tile @click=\"$router.push('/#{page.name.to_snake}')\">"
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
      end

      tile << "<!-- NAVBAR --//>"
      pagesrc.gsub!('<!-- NAVBAR -->', tile.join("\n"))

      File.write('dst/src/App.vue', pagesrc)
    end
  end
end


