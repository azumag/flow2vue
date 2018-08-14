# encoding: utf-8

require 'fileutils'
require 'optparse'

require './string_helper'
require './generator'
require './page'
require './parser'

# TODO: intaractive specifying
# ignore route generation if Nuxt
# -t : title
# -i : input file
params = ARGV.getopts(
  't:fi:', 
  'nonuxt',
  'novuetify',
  'cli2',
  'pageonly',
  'vuetify'
)

p params

Generator.generate(Parser.parse(params['i']), params)

