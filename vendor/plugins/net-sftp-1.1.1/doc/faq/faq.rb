#--
# =============================================================================
# Copyright (c) 2005, Jamis Buck (jamis@jamisbuck.org)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
# 
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
# 
#     * The names of its contributors may not be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# =============================================================================
#++

require 'yaml'
require 'redcloth'

def process_faq_list( faqs )
  puts "<ul>"
  faqs.each do |faq|
    process_faq_list_item faq
  end
  puts "</ul>"
end

def process_faq_list_item( faq )
  question = faq.keys.first
  answer = faq.values.first

  print "<li>"

  question_text = RedCloth.new(question).to_html.gsub( %r{</?p>},"" )
  if answer.is_a?( Array )
    puts question_text
    process_faq_list answer
  else
    print "<a href='##{question.object_id}'>#{question_text}</a>"
  end

  puts "</li>"
end

def process_faq_descriptions( faqs, path=nil )
  faqs.each do |faq|
    process_faq_description faq, path
  end
end

def process_faq_description( faq, path )
  question = faq.keys.first
  path = ( path ? path + " " : "" ) + question
  answer = faq.values.first

  if answer.is_a?( Array )
    process_faq_descriptions( answer, path )
  else
    title = RedCloth.new( path ).to_html.gsub( %r{</?p>}, "" )
    answer = RedCloth.new( answer || "" )

    puts "<a name='#{question.object_id}'></a>"
    puts "<div class='faq-title'>#{title}</div>"
    puts "<div class='faq-answer'>#{answer.to_html}</div>"
  end
end

faqs = YAML.load( File.read( "faq.yml" ) )

puts <<-EOF
<html>
  <head>
    <title>Net::SFTP FAQ</title>
    <style type="text/css">
      a, a:visited, a:active {
        color: #00F;
        text-decoration: none;
      }

      a:hover {
        text-decoration: underline;
      }

      .faq-list {
        color: #000;
        font-family: vera-sans, verdana, arial, sans-serif;
      }

      .faq-title {
        background: #007;
        color: #FFF;
        font-family: vera-sans, verdana, arial, sans-serif;
        padding-left: 1em;
        padding-top: 0.5em;
        padding-bottom: 0.5em;
        font-weight: bold;
        font-size: large;
        border: 1px solid #000;
      }

      .faq-answer {
        margin-left: 1em;
        color: #000;
        font-family: vera-sans, verdana, arial, sans-serif;
      }

      .faq-answer pre {
        margin-left: 1em;
        color: #000;
        background: #FFE;
        font-size: normal;
        border: 1px dotted #CCC;
        padding: 1em;
      }

      h1 {
        background: #005;
        color: #FFF;
        font-family: vera-sans, verdana, arial, sans-serif;
        padding-left: 1em;
        padding-top: 1em;
        padding-bottom: 1em;
        font-weight: bold;
        font-size: x-large;
        border: 1px solid #00F;
      }
    </style>
  </head>
  <body>
  <h1>Net::SFTP FAQ</h1>
  <div class="faq-list">
EOF

process_faq_list( faqs )
puts "</div>"
process_faq_descriptions( faqs )

puts "</body></html>"
