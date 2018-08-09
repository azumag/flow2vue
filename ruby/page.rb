# encoding: utf-8

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
