# encoding: utf-8

require 'fileutils'

require './generator'
require './page'
require './parser'

gen = Generator.generate(Parser.parse(ARGV[0]), mode: :rewrite, title: ARGV[1])


