require 'mechanize'
require 'netaddr'
require 'net/http'

CDIR_MASK = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/(\d{1,2})$/

def calculate_total_ip_addresses(company)
  url = "http://bgp.he.net/search?search%5Bsearch%5D=#{company}&commit=Search"
  total_ips = 0
  agent = Mechanize.new
  agent.get(url) do |page|
    sizes = page.search('.w100p a').map do |link|
      valid_ip = link.text.match CDIR_MASK
      if valid_ip
        NetAddr::CIDR.create(valid_ip[0]).size
      end
    end.compact
    total_ips = sizes.reduce(0) {|acc,i| acc += i}
  end
  return total_ips
end

def get_domain_head(domain)
  Net::HTTP.start(domain) do |http|
    http.open_timeout = 0.5
    http.read_timeout = 0.5
    return http.head('/')
  end
end

if __FILE__ == 'ip_ranges.rb'
  target_company = ARGV.first

  if target_company.nil?
    puts "Invalid parameter, inform a valid company name"
  else
    puts "Total IP addresses for #{target_company}: #{calculate_total_ip_addresses(target_company)}"
  end
end