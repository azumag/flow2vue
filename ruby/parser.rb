# encoding: utf-8

require 'fileutils'

class Parser
  def self.parse(file)
    flow = File.read(file)
    flow << "\n" # insert \n for easy parsing
    flow.delete!("\r")
    page_scans = flow.scan(/\[(.*)\]/).flatten
    pages = []

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
      pages << page

    end
    pages
  end
end


