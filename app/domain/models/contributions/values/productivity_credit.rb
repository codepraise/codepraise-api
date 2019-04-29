# frozen_string_literal: true

module CodePraise
  module Value
    class ProductivityCredit < SimpleDelegator

      def self.build_object(line_contributions=nil, method_contributions=nil)
        obj = new
        add_line_credits(obj, line_contributions) if line_contributions
        add_method_credits(obj, method_contributions) if method_contributions
        obj
      end

      def self.build_by_hash(hash)
        obj = new
        obj[:line] = hash[:line]
        obj[:method] = hash[:method]
        obj[:contributors] = hash[:contributors]
        obj
      end

      def initialize
        super(Hash.new(Hash))
        %i[line method].each do |metric|
          self[metric] = Hash.new(0)
        end
        self[:contributors] = Set.new
      end

      def line_credits
        self[:line]
      end

      def method_credits
        self[:method]
      end

      def line_percentage
        sum = line_credits.values.reduce(&:+)
        line_credits.keys.each_with_object({}) do |name, hash|
          hash[name] = sum.zero? ? 0 : ((line_credits[name].to_f / sum) * 100).round
        end
      end

      def contributors
        self[:contributors]
      end

      private

      def self.add_line_credits(obj, line_contributions)
        line_contributions.each do |line|
          obj[:line][line.contributor.username] += line.credit
          obj[:contributors].add(line.contributor)
        end
      end

      def self.add_method_credits(obj, method_contributions)
        method_contributions.each do |method|
          total = method.line_credits.values.sum
          method.line_credits.each do |k, v|
            obj[:method][k] += (v.to_f / total)
          end
        end
      end

      private_class_method :add_line_credits, :add_method_credits
    end
  end
end
