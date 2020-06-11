# -*- coding: utf-8 -*-
require 'colorize'

file = 'mid_presentation'

desc 'push platex.rake to local gem'
task :push do
  system "cp -i platex.rake ~/Github/ornb/lib/platex"
end
task :default do
  system 'rake -f platex.rake -T'
end

desc "mid_presen"
task :mid do
  textheight =<<'EOS'
\setlength{\textheight}{275mm}
\headheight 5mm
\topmargin -30mm
\textwidth 185mm
\oddsidemargin -15mm
\evensidemargin -15mm
\pagestyle{empty}
EOS

title_author =<<'EOS'
\title{EAMを用いた歪み解析}
\author{情報科学科 \hspace{5mm} 19610311 \hspace{5mm} 西谷滋人}
\date{}
EOS
  cont = File.read("#{file}.tex")
  cont.gsub!('{jsarticle}','[a4j,twocolumn]{jsarticle}')
#  cont.gsub!('{graphicx}','[dvipdfmx]{graphicx}')
  cont.gsub!('{hyperref}',"[dvipdfmx]{hyperref}\n\\usepackage{pxjahyper}")
  cont.gsub!(/\\setcounter{secnumdepth}{(.+?)}/, textheight)
  cont.gsub!(/\\author{(.+?)}/,'')
  cont.gsub!(/\\date{(.+?)}/,'')
  cont.gsub!(/\\title{(.+?)}/, title_author)
  cont.gsub!(/\\tableofcontents/,'')
  File.open("#{file}.tex",'w'){ |f| f.print cont }
  system "rake -f #{__FILE__} platex"
end

desc "platex"
task :platex do
  dir = "figs/strain_field"
  Dir.entries(dir).each do |file|
    if m = file.match(/#{dir}\.(.+)\.png/)
      p t_file = dir+"_"+m[1]+'.png'
      FileUtils.mv(File.join(dir,file), File.join(dir,t_file))
    end
  end

  p file
  cont = File.read("#{file}.tex")
  File.open("#{file}.tex",'w'){ |f| f.print cont }
  system "platex #{file}"
  commands = ["platex #{file}.tex",
              "pbibtex #{file}", # change bibtex to pbibtex for junsrt
              "platex #{file}.tex",
              "dvipdfmx #{file}.dvi",
              "open #{file}.pdf"]
  commands.each do |com|
    puts com.red
    system com
  end
end
