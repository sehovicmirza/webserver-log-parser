#!/usr/bin/env ruby

def process(log_file)
  page_views = parse_logs(log_file)
  total_views, unique_views = build_rank_lists(page_views)

  display_stats(total_views, unique_views)
end

def parse_logs(log_file)
  page_views = {}

  File.readlines(log_file).each do |line|
    page, ip = line.split(' ')
    page_views[page] ||= { total_count: 0, unique_count: 0, ips: [] }

    unless page_views[page][:ips].include?(ip)
      page_views[page][:unique_count] += 1
      page_views[page][:ips] << ip
    end

    page_views[page][:total_count] += 1
  end

  page_views
end

def build_rank_lists(page_views)
  total_views_ranking = page_views.sort_by { |page, views| views[:total_count] }.reverse
  unique_views_ranking = page_views.sort_by { |page, views| views[:unique_count] }.reverse

  return total_views_ranking, unique_views_ranking
end

def display_stats(total, unique)
  puts "\nTotal page views:\n\n"
  total.each { |page, views| puts "#{page} #{views[:total_count]} views" }
  puts "\n"

  puts "\nUnique page views:\n\n"
  unique.each { |page, views| puts "#{page} #{views[:unique_count]} unique views" }
  puts "\n"
end

if $0 == __FILE__
  raise ArgumentError, "Please provide log file. Usage: #{$0} <filename>" unless ARGV.length == 1
  process(ARGV[0])
end
