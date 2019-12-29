# frozen_string_literal: true

require 'selenium-webdriver'
require 'thread'
require 'io/console'

BASE_URL = 'http://localhost:3000'
MAX_LINKS = 30
CSS_SELECTOR = 'a:not(.mw-jump-link)'
SLEEPS = {
  's' => 5,
  'n' => 1,
  'f' => 0
}

puts 'Opening Chrome...'
driver = Selenium::WebDriver.for :chrome

puts "Navigating to #{BASE_URL}..."
driver.navigate.to BASE_URL

def out(text)
  puts "\r#{text}"
end

def instructions(mode)
  out "(W)ait, (S)low, (N)ormal, (F)ast, (Q)uit. Current mode: #{mode.upcase}"
end

mode = 'w'
instructions(mode)

def click_link(driver, mode)
  out "Finding links..."
  elements = driver.find_elements(css: CSS_SELECTOR).first(MAX_LINKS).select do |element|
    next false unless element.attribute('href').to_s.start_with?(BASE_URL)
    next false unless element.displayed?

    size = element.size
    size.width > 0 && size.height > 0
  end
  out "Found #{elements.size} clickable links in the first #{MAX_LINKS} links."
  # out elements.map { |element| "  <#{element.tag_name} href=#{element.attribute('href')}>" }

  element = elements.sample
  out "Clicking <#{element.tag_name} href=#{element.attribute('href')}>..."
  element.click
  instructions(mode)
rescue StandardError => e
  out "Error: #{e.message}"
end

thread = Thread.new do
  loop do
    case mode
    when 's', 'f', 'n'
      click_link(driver, mode)
      sleep SLEEPS.fetch(mode, 0)
    when 'w'
      sleep 0.1
    when 'q'
      break
    end
  end
end

loop do
  mode = STDIN.getch.downcase
  instructions(mode)
  if mode == 'q'
    thread.join
    break
  end
end

3.downto(1) do |i|
  print "\rSleeping for #{i} seconds... "
  sleep 1
end

driver.quit
