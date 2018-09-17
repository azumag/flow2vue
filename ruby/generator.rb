# encoding: utf-8

require 'fileutils'
require 'json'

class Generator
  DST_DIR = 'dst'
  SRC_DIR = '.scaffold'
  BASE_DIR = '/base'
  CLI2_DIR = '/cli2'

  APP_FILE = '/src/App.vue'
  APP_VUETIFY_FILE = '/src_vuetify/App.vue'
  ROUTES_FILE = '/src/routes.js'
  PAGE_TEMPLATE_FILE = '/src/components/page.vue'

  VUETIFY_VERSION = '^1.1.11'
  MATELIAL_ICON_VERSION = '^3.0.3'
  VUE_AWESOME_VERSION = '^3.1.0'

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

      add_packages(params)

      add_imports(params)

      select_template(params)

      copy_routes #if params['nonuxt']
      pages.each do |page|
        add_routes(page) #if params['nonuxt']
        generate_with(page, params)
      end

      title = params['t']
      rewrite_app_title(title) if title
    end

    def rewrite_top_tags(params)
      return unless params['vuetify']

    end

    def select_template(params)
      destination_file = DST_DIR + APP_FILE

      src_file =
        if params['vuetify']
          SRC_DIR + BASE_DIR + APP_VUETIFY_FILE
        else
          SRC_DIR + BASE_DIR + APP_FILE
        end

      app = File.read(src_file)

      # app.gsub!('APP_TITLE', title)
      File.write(destination_file, app)
    end

    def add_imports(params)
      main_src = File.read(DST_DIR + '/src/main.js')
      imports = []
      usings  = []
      if params['vuetify']
        imports << "import Vuetify from 'vuetify'"
        imports << "import 'vuetify/dist/vuetify.min.css'"
        imports << "import 'vue-awesome/icons/flag'"
        imports << "import 'vue-awesome/icons'"
        imports << "import Icon from 'vue-awesome/components/Icon'"
        imports << "import 'material-design-icons-iconfont/dist/material-design-icons.css'"

        usings << "Vue.use(Vuetify)"
        usings << "Vue.component('icon', Icon)"
      end

      main_src.gsub!('// -- additional imports', imports.join("\n"))
      main_src.gsub!('// -- additional usings', usings.join("\n"))

      File.write(DST_DIR + '/src/main.js', main_src)
    end

    def add_packages(params)
      return unless params['vuetify']
      package_json = JSON.parse(File.read(DST_DIR + '/package.json'))
      package_json['dependencies']["vuetify"] = VUETIFY_VERSION
      package_json['dependencies']["material-design-icons-iconfont"] = MATELIAL_ICON_VERSION
      package_json['dependencies']["vue-awesome"] = VUE_AWESOME_VERSION
      File.write(DST_DIR + '/package.json', JSON.pretty_generate(package_json))
    end

    def generate_scaffold(params)
      unless params['pageonly']
        FileUtils.rm_rf(DST_DIR) if File.exist?(DST_DIR)
        FileUtils.copy_entry(SRC_DIR + CLI2_DIR, DST_DIR) if params['cli2']
      end
      FileUtils.rm_rf(DST_DIR + '/src') if File.exist?(DST_DIR + '/src')
      FileUtils.copy_entry(SRC_DIR + BASE_DIR, DST_DIR)
    end

    def rewrite_app_title(title)
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

    def build_input(name, label, required, rules, params)
      rule = ":rules='#{rules}'" unless rules.empty?
      if params['vuetify']
        "<v-text-field v-model='#{name}' #{rule} label='#{label}' #{required}></v-text-field>"
      else
        "<div><label>#{name}</label><input /></div>"
      end
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

          #build_tag('v-text-field', name, label, required, rules)
          build_input(name, label, nil, rules, params)
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

      add_navbar(page, params) if page.independent
    end

    def add_navbar(page, params)
      page_file =  "dst/src/App.vue"
      pagesrc = File.read(page_file)

      tile = []
      unless params['vuetify']
        tile << "<div>"
        # tile << "<a @click=\"$router.push('/#{page.name.to_snake}')\">"
        tile << "<router-link to=\"/#{page.name.to_snake}\">"
        tile << "#{page.display_name}"
        tile << "</router-link>"
        # tile << "</a>"
        tile << "</div>"
      else
        tile << "<v-list-tile @click=\"$router.push('/#{page.name.to_snake}')\">"
        tile << "            <v-list-tile-action>"
        tile << "            <v-icon>link</v-icon>" # TODO
        tile << "          </v-list-tile-action>"
        tile << "          <v-list-tile-content>"
        tile << "            <v-list-tile-title>"
        tile << "              #{page.display_name}"
        tile << "            </v-list-tile-title>"
        tile << "          </v-list-tile-content>"
        tile << "        </v-list-tile>"
      end

      tile << "          <!-- NAVBAR -->"
      pagesrc.gsub!('<!-- NAVBAR -->', tile.join("\n"))

      File.write(page_file, pagesrc)
    end
  end
end
