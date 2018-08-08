# encoding: utf-8

require 'fileutils'
require 'optparse'

require './generator'
require './page'
require './parser'

# TODO: intaractive specifying
# ignore route generation if Nuxt
params = ARGV.getopts(
  ':', 
  'demo',
  'vuetify',
  'coreui',
  'nuxt',
  'page-only',
  'navbar',
)

gen = Generator.generate(Parser.parse(ARGV[0]), mode: :rewrite, title: ARGV[1], params)


