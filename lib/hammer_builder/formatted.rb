module HammerBuilder
  # Builder implementation with formatting (indented by '  ')
  # Slow down is less then 1%
  class Formatted < Standard

    dynamic_classes do
      extend :AbstractTag do
        def open(attributes = nil)
          @output << NEWLINE << SPACES.fetch(@stack.size, SPACE) << LT << @tag
          @builder.current = self
          attributes(attributes)
          default
          self
        end
      end

      extend :AbstractDoubleTag do
        def with
          flush_classes
          @output << GT
          @content         = nil
          @builder.current = nil
          yield
          #if (content = yield).is_a?(String)
          #  @output << EscapeUtils.escape_html(content, false)
          #end
          @builder.flush
          @output << NEWLINE << SPACES.fetch(@stack.size-1, SPACE) << SLASH_LT << @stack.pop << GT
          nil
        end
      end
    end

    def comment(comment)
      flush
      @_output << NEWLINE << SPACES.fetch(@_stack.size, SPACE) << COMMENT_START << comment.to_s << COMMENT_END
    end
  end
end
