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
  'demo',
  'pageonly',
  'nuxt',
  'cli2',
  'vuetify',
  'dark'
)

p params

Generator.generate(Parser.parse(params['i']), params)
