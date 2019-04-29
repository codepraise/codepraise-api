# frozen_string_literal: true

require_relative 'quality_credit'
require_relative 'productivity_credit'

module CodePraise
  module Value
    # Value of credits shared by contributors for file, files, or folder
    class CreditShare < SimpleDelegator
      # rubocop:disable Style/RedundantSelf
      LEVEL_SCORE = {
        'A' => 10,
        'B' => 9,
        'C' => 8,
        'D' => 7,
        'E' => 6,
        'F' => 5
      }.freeze

      def self.build_object(file_contributions)
        obj = new
        obj[:quality_credit] = QualityCredit
          .build_object(file_contributions.complexity,
                        file_contributions.idiomaticity)
        obj[:productivity_credit] = ProductivityCredit
          .build_object(file_contributions.lines,
                        file_contributions.methods)
        obj
      end

      def self.build_by_hash(hash)
        obj = new
        obj[:quality_credit] = QualityCredit
          .build_by_hash(hash[:quality_credit])
        obj[:productivity_credit] = ProductivityCredit
          .build_by_hash(hash[:productivity_credit])
        obj
      end

      def initialize
        super(Hash.new(Hash))
        %i[quality_credit productivity_credit].each do |metric|
          self[metric] = Hash.new(0)
        end
      end

      def productivity_credit
        self[:productivity_credit]
      end

      def contributors
        productivity_credit.contributors
      end

      def line_percentage
        productivity_credit.line_percentage
      end

      def +(other)
        raise TypeError, 'Must be CreditShare' unless other.is_a?(CodePraise::Value::CreditShare)

        contributors = self.contributors + other.contributors
        result = {
          quality_credit: sum_quality(self[:quality_credit],
                                      other[:quality_credit]),
          productivity_credit: sum_productivtiy(self[:productivity_credit],
                                                other[:productivity_credit],
                                                contributors),
        }
        CreditShare.build_by_hash(result)
      end

      def sum_quality(qc1, qc2)
        {
          complexity: sum_hash(qc1[:complexity], qc2[:complexity]),
          idiomaticity: sum_hash(qc1[:idiomaticity], qc2[:idiomaticity]),
          documentation: sum_hash(qc1[:documentation], qc2[:documentation])
        }
      end

      def sum_productivtiy(pc1, pc2, contributors)
        {
          line: sum_hash(pc1[:line], pc2[:line]),
          method: sum_hash(pc1[:method], pc2[:method]),
          contributors: contributors
        }
      end

      def sum_hash(hash1, hash2)
        max_hash(hash1, hash2)
          .keys.each_with_object(Hash.new(0)) do |name, hash|
            hash[name] = hash1[name].to_f + hash2[name].to_f
          end
      end

      def max_hash(hash1, hash2)
        if hash1.keys.length > hash2.keys.length
          hash1
        else
          hash2
        end
      end



      ### following methods allow two CreditShare objects to test equality
      def sorted_credit
        @share.to_a.sort_by { |a| a[0] }
      end

      def sorted_contributors
        @contributors.to_a.sort_by(&:username)
      end

      def state
        [sorted_credit, sorted_contributors]
      end

      def ==(other)
        other.class == self.class && other.state == self.state
      end



      alias eql? ==

      def hash
        state.hash
      end
      #############


      def add_collective_ownership(ownership_score)
        ownership_score.each do |k, v|
          @collective_ownership[k] = {
            coefficient_variation: ownership_score[k],
            level: coefficient_variantion_level(ownership_score[k])
          }
        end
      end

      def coefficient_variantion_level(coefficient_variantion)
        case coefficient_variantion
        when 0..50
          'A'
        when 50..100
          'B'
        when 100..150
          'C'
        when 150..200
          'D'
        when 200..250
          'E'
        when 250..(1.0 / 0.0)
          'F'
        end
      end

      # rubocop:enable Style/RedundantSelf
    end
  end
end
