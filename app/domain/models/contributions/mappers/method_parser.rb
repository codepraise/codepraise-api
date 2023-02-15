# frozen_string_literal: true

require 'parser/current'

module CodePraise
  module Mapper
    # Find all method in a file
    module MethodParser
      def self.parse_methods(line_entities)
        ast = Parser::CurrentRuby.parse(line_of_code(line_entities).dump)
        all_methods_hash(ast, line_entities)
      end

      def self.line_of_code(line_entities)
        line_entities.map(&:code).join("\n")
      end

      def self.all_methods_hash(ast, line_entities)
        methods_ast = []
        find_methods_tree(ast, methods_ast)

        methods_ast.inject([]) do |result, method_ast|
          result.push(name: method_name(method_ast),
                      lines: select_entities(method_ast, line_entities),
                      type: method_type(method_ast))
        end
      end

      def self.select_entities(method_ast, line_entities)
        first_no = method_ast.loc.first_line - 1
        last_no = method_ast.loc.last_line - 1
        line_entities[first_no..last_no]
      end

      private

      def self.method_type(method_ast)
        method_ast.type.to_s
      end

      def self.method_name(method_ast)
        method_ast.loc.expression.source_line
      end

      def self.find_methods_tree(ast, methods_ast)
        return nil unless ast.is_a?(Parser::AST::Node)

        if %i[def block defs].include?(ast.type)
          methods_ast.append(ast)
        else
          ast.children.each do |child_ast|
            find_methods_tree(child_ast, methods_ast)
          end
        end
      end

      private_class_method :find_methods_tree, :method_name, :method_type
    end
  end
end
