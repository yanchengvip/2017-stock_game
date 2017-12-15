list = []
Dir.foreach("fe_html2.0/css") { |f| list << f }
list.delete_if{ |f| f =~ /^[.]/ }.map{|x| x.gsub(".css", "")}
require 'uri'
list.each do |file|
  original_css = IO.read("fe_html2.0/css/"+file)
  reg = /url\("?..\/images(.*?)"?\)/
  cdn_css = original_css.gsub(reg){ |s| s = "asset_url(\"h5/images/#{URI.encode ($1)}\")" }
  f = File.open("app/assets/stylesheets/h5/#{file}.scss", "w")
  f.write(cdn_css)
  f.close
end
system "cp -r fe_html2.0/images  app/assets/images/h5"
system "cp -r fe_html2.0/js/*  app/assets/javascripts/h5"
system "cp -r fe_html2.0/video/  app/assets/audios/h5"
