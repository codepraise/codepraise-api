# frozen_string_literal: true

module CodePraise
  module Value
    class QualityCredit < SimpleDelegator
      LEVEL_SCORE = {
        'A' => 3,
        'B' => 2,
        'C' => 1,
        'D' => 0,
        'E' => -1,
        'F' => -2
      }.freeze

      def self.build_object(complexity = nil, idiomaticity = nil, comments = nil)
        obj = new
        add_complexity_credits(obj, complexity) if complexity
        add_idiomaticity_credits(obj, idiomaticity) if idiomaticity
        add_documentation_credits(obj, comments) if comments
        obj
      end

      def self.build_by_hash(hash)
        obj = new
        obj[:complexity] = hash[:complexity]
        obj[:idiomaticity] = hash[:idiomaticity]
        obj
      end

      def initialize
        super(Hash.new(Hash))
        %i[complexity idiomaticity documentation].each do |metric|
          self[metric] = Hash.new(0)
        end
      end

      private

      def self.add_complexity_credits(obj, complexity)
        complexity.method_complexities.each do |method_complexity|
          method_complexity.contributors.each do |name, percentage|
            obj[:complexity][name] += LEVEL_SCORE[method_complexity.level] *
                                      (percentage.to_f / 100)
          end
        end
      end

      def self.add_idiomaticity_credits(obj, idiomaticity)
        idiomaticity.offenses.each do |offense|
          offense.contributors.each do |name, line_count|
            obj[:idiomaticity][name] += 0.5 * line_count
          end
        end
      end

      def self.add_documentation_credits(obj, comments)
        comments.each do |comment|
          comment.contributors.each do |name, line_count|
            credit = comment.is_documentation ? 1 : 0
            obj[:documentation][name] += credit * line_count
          end
        end
      end

      private_class_method :add_complexity_credits, :add_idiomaticity_credits,
                           :add_documentation_credits
    end
  end
end
