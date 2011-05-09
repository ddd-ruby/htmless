# hammer-render

## Syntax

Experimental fast xhtml builder with rich syntax:

    Hammer::FormatedBuilder.new.go_in do
      xhtml5!
      html do
        head { title 'a title' }
        body do
          div.id('menu').class('left') do
            ul do
              li 'home'
              li 'contacts', :class => 'active'
            end
          end
          div.id('content') do
            article.id 'article1' do
              h1 'header'
              p('some text').class('centered')
              div(:class => 'like').class('hide').with do
                text 'like on '
                strong 'Facebook'
              end
            end
          end
        end
      end
    end.to_xhtml
    #=>
    <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>a title</title>
      </head>
      <body>
        <div id="menu" class="left">
          <ul>
            <li>home</li>
            <li class="active">contacts</li>
          </ul>
        </div>
        <div id="content">
          <article id="article1">
            <h1>header</h1>
            <p class="centered">some text</p>
            <div class="like hide">like on
              <strong>Facebook</strong>
            </div>
          </article>
        </div>
      </body>
    </html>


## Helpers

You can mix it directly to Builder's instance

  require 'active_support'
  require 'action_view'

  Hammer::FormatedBuilder.new.go_in do
    extend ActionView::Helpers::NumberHelper
    div number_with_precision(Math::PI, :precision => 4)
  end.to_xhtml # => <div>3.1416</div>

or make your own Builder

  require 'active_support'
  require 'action_view'

  class MyBuilder < Hammer::FormatedBuilder
    include ActionView::Helpers::NumberHelper
  end

  MyBuilder.new.go_in do
    div number_with_precision(Math::PI, :precision => 4)
  end.to_xhtml # => <div>3.1416</div>

## Extensibility

  class MyBuilder < Hammer::FormatedBuilder

    # define new method to all tags
    redefine_class :abstract_tag do
      def hide!
        self.class 'hidden'
      end
    end

    # add pseudo tag
    define_tag_class :component, :div do
      class_eval <<-RUBYCODE, __FILE__, __LINE__
        def open(id, attributes = nil, &block)
          super(attributes, &nil).id(id).class('component')
          block ? with(&block) : self
        end
      RUBYCODE
    end
  end

  MyBuilder.new.go_in do
    div[:content].with do
      span.id('secret').class('left').hide!
      component('component-1') do
        strong 'something'
      end
    end
  end.to_xhtml

and result is

  <div id="content">
    <span id="secret" class="left hidden"></span>
    <div id="component-1" class="component">
      <strong>something</strong>
    </div>
  </div>


## Benchmark

### Synthetic

                                user     system      total        real
  render                    5.010000   0.000000   5.010000 (  5.185034)
  render3                   4.990000   0.020000   5.010000 (  5.037699)
  HammerBuilder::Standard   5.620000   0.000000   5.620000 (  5.643001)
  HammerBuilder::Formated   5.610000   0.010000   5.620000 (  5.623096)
  erubis                    8.040000   0.010000   8.050000 (  8.139744)
  erubis-reuse              4.970000   0.000000   4.970000 (  4.990626)
  fasterubis                8.060000   0.030000   8.090000 (  8.096832)
  fasterubis-reuse          4.930000   0.010000   4.940000 (  4.934972)
  tenjin                   12.390000   0.270000  12.660000 ( 12.642816)
  tenjin-reuse              3.540000   0.000000   3.540000 (  3.557388)
  erector                  15.320000   0.010000  15.330000 ( 15.378344)
  markaby                  20.750000   0.030000  20.780000 ( 21.371292)
  tagz                     73.200000   0.140000  73.340000 ( 73.306450)

### In Rails 3

  BenchTest#test_erubis_partials (3.34 sec warmup)
             wall_time: 3.56 sec
                memory: 0.00 KB
               objects: 0
               gc_runs: 15
               gc_time: 0.53 ms
  BenchTest#test_erubis_single (552 ms warmup)
             wall_time: 544 ms
                memory: 0.00 KB
               objects: 0
               gc_runs: 4
               gc_time: 0.12 ms
  BenchTest#test_hammer_builder (2.33 sec warmup)
             wall_time: 847 ms
                memory: 0.00 KB
               objects: 0
               gc_runs: 5
               gc_time: 0.17 ms
  BenchTest#test_tenjin_partial (942 ms warmup)
             wall_time: 1.21 sec
                memory: 0.00 KB
               objects: 0
               gc_runs: 7
               gc_time: 0.25 ms
  BenchTest#test_tenjin_single (531 ms warmup)
             wall_time: 532 ms
                memory: 0.00 KB
               objects: 0
               gc_runs: 6
               gc_time: 0.20 ms

### Conclusion

Template engines are faster than HammerBuilder when template does not content a lot of inserting or partials. On the
other hand when partials are used, HammerBuilder beats down template engines. There is quite a overhead to render partials.
So which one is better, is dependent on how much your rendering is fragmented / dynamic.

To use Tenjin in Rails 3 a did some hacking.
