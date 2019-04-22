# frozen_string_literal: true

module CodePraise
  module Mapper
    module TestCaseParser
      def self.parse(code)
        ast = Parser::CurrentRuby.parse(code)
        test_cases = []
        find_test_cases(ast, test_cases)
        test_cases.map do |test_case|
          { message:  test_case.loc.expression.source }
        end
      end

      def self.find_test_cases(ast, result)
        return unless ast.is_a?(Parser::AST::Node)

        if ast.to_a[1] == :it
          result << ast
        else
          ast.children.each do |child|
            find_test_cases(child, result)
          end
        end
      end
    end
  end
end
