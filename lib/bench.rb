require 'benchmark'
require "#{File.dirname(__FILE__)}/render.rb"
require "#{File.dirname(__FILE__)}/render_1.rb"
require "#{File.dirname(__FILE__)}/render_2.rb"
require "#{File.dirname(__FILE__)}/render_3.rb"

class ::Class
  def spy
    klass = self
    Class.new(self) do
      public_instance_methods.each do |name|
        define_method(name) do |*args, &block|
          puts "#{name} called on #{klass} with #{args.inspect}"
          ret = super(*args, &block)
          puts @output.inspect, @stack.inspect
          ret
        end
      end
    end
  end
end

#r = Render3::Builder.new
#r.body do
#  r.p.id('i').class('a', 'b').with { r.text 'c' }
#  r.p.id('i').class('a', 'b') { r.text 'c' }
#  r.p.id('i'); r.current.class('a', 'b') { r.text 'c' }
#  r.p('c')['i'].class('a', 'b')
#  r.p('c')['i'].class(['a', 'b'])
#  r.p 'c', :id => 'i', :class => ['a', 'b']
#  r.p('c', :class => 'a b')['i']
#end
#puts r
#
#exit


TIMES = 50000
#TIMES =  10000
#TIMES =  1

class AModel
  attr_reader :a, :b
  def initialize(a,b)
    @a, @b = a, b
  end
end

require 'markaby'
require 'erubis'

model = AModel.new 'a', 'b'
(TIMES/100).times do
  r = Render::Builder.new
  r.html.with do
    r.head
    r.body.with do
      r.div.id('menu').with do
        r.ul.with do
          10.times do
            r.li.with { r.text model.a }
            r.li.with { r.text model.b }
          end
        end
      end
      r.div.id('content').with do
        10.times { r.text 'asd asha sdha sdjhas ahs'*10 }
      end
    end
  end
end

Benchmark.bm(20) do |b|
  b.report("render") do
    model = AModel.new 'a', 'b'    
    TIMES.times do
      r = Render::Builder.new
      r.html.with do
        r.head
        r.body.with do
          r.div.id('menu').with do
            r.ul.with do
              10.times do
                r.li model.a
                r.li model.b
              end
            end
          end
          r.div.id('content').with do
            10.times { r.text 'asd asha sdha sdjhas ahs'*10 }
          end
        end
      end
    end
  end
  b.report("render3") do
    model = AModel.new 'a', 'b'
    TIMES.times do
      r = Render3::Builder.new
      r.html do
        r.head
        r.body do
          r.div :id => 'menu' do
            r.ul do
              10.times do
                r.li model.a
                r.li model.b
              end
            end
          end
          r.div['content'].with do
            10.times { r.text 'asd asha sdha sdjhas ahs'*10 }
          end
        end
      end
    end
  end

  b.report('markaby') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      r = Markaby::Builder.new(:model => model) do
        html do
          head {}
          body do
            div :id => 'menu' do
              ul do
                10.times do
                  li model.a
                  li model.b
                end
              end
            end
            div :id => 'content' do
              10.times { text 'asd asha sdha sdjhas ahs'*10 }
            end
          end
        end
      end
      #      puts r.to_s
    end
  end

  TEMPLATE = <<TMP
<html>
<head></head>
<body><div id="menu"><ul>
<% 10.times do %>
<li><%= model.a %></li><li><%= model.b %></li>
<% end %>
</ul></div>
<div id="content">
<% 10.times do %>
<%= 'asd asha sdha sdjhas ahs'*10 %>
<% end %>
</div></body></html>
TMP

  b.report('erubis') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      Erubis::Eruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end
  b.report('erubis-cache') do
    model = AModel.new 'a', 'b'
    erub = Erubis::Eruby.new(TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
    GC.start
  end
  b.report('fasterubis') do
    model = AModel.new 'a', 'b'
    TIMES.times do
      Erubis::FastEruby.new(TEMPLATE).result(binding())
    end
    GC.start
  end

  b.report('fasterubis-cache') do
    model = AModel.new 'a', 'b'
    erub = Erubis::FastEruby.new(TEMPLATE)
    TIMES.times do
      erub.result(binding())
    end
    GC.start
  end
end


