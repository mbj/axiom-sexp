module Axiom
  module Sexp
    # Generator for s-expressions
    module Generator
      # Incomplete sexp formatter operation table
      REGISTRY = {
        Relation::Base                            => [ :base                                       ],
        Relation::Materialized                    => [ :materialized                               ],
        Relation::Operation::Order                => [ :binary,    :order, :operand, :directions   ],
        Relation::Header                          => [ :collect                                    ],
        Relation::Operation::Order::DirectionSet  => [ :collect                                    ],
        Relation::Operation::Order::Ascending     => [ :unary,     :asc,  :attribute               ],
        Relation::Operation::Order::Descending    => [ :unary,     :desc, :attribute               ],
        Relation::Operation::Limit                => [ :binary,    :limit, :operand, :limit        ],
        Relation::Operation::Offset               => [ :binary,    :offset, :operand, :offset      ],
        Relation::Operation::Deletion             => [ :binary,    :delete, :operand, :other       ],
        Relation::Operation::Insertion            => [ :binary,    :insert, :operand, :other       ],
        Relation::Operation::Reverse              => [ :unary,     :reverse                        ],
        Algebra::Difference                       => [ :binary,    :difference                     ],
        Algebra::Extension                        => [ :extend                                     ],
        Algebra::Intersection                     => [ :intersect                                  ],
        Algebra::Join                             => [ :binary,    :join                           ],
        Algebra::Product                          => [ :binary,    :product                        ],
        Algebra::Projection                       => [ :binary,    :project, :operand, :header     ],
        Algebra::Rename                           => [ :binary,    :rename                         ],
        Algebra::Restriction                      => [ :binary,    :restrict, :operand, :predicate ],
        Algebra::Summarization                    => [ :binary,    :summarize                      ],
        Algebra::Union                            => [ :binary,    :union                          ],
        Function::Connective::Conjunction         => [ :binary,    :and                            ],
        Function::Connective::Disjunction         => [ :binary,    :or                             ],
        Function::Connective::Negation            => [ :unary,     :not                            ],
        Function::String::Length                  => [ :unary,     :length                         ],
        Function::Predicate::Equality             => [ :binary,    :eq                             ],
        Function::Predicate::Exclusion            => [ :binary,    :ex                             ],
        Function::Predicate::GreaterThan          => [ :binary,    :gt                             ],
        Function::Predicate::GreaterThanOrEqualTo => [ :binary,    :gte                            ],
        Function::Predicate::Inclusion            => [ :binary,    :in                             ],
        Function::Predicate::Inequality           => [ :binary,    :neq                            ],
        Function::Predicate::LessThan             => [ :binary,    :lt                             ],
        Function::Predicate::LessThanOrEqualTo    => [ :binary,    :lte                            ],
        Function::Predicate::Match                => [ :binary,    :match                          ],
        Function::Predicate::NoMatch              => [ :binary,    :no_match                       ],
        Function::Numeric::Absolute               => [ :binary,    :abs                            ],
        Function::Numeric::Addition               => [ :binary,    :add                            ],
        Function::Numeric::Division               => [ :binary,    :div                            ],
        Function::Numeric::Exponentiation         => [ :binary,    :exp                            ],
        Function::Numeric::Modulo                 => [ :binary,    :mod                            ],
        Function::Numeric::Multiplication         => [ :binary,    :mul                            ],
        Function::Numeric::SquareRoot             => [ :unary,     :sqr                            ],
        Function::Numeric::Subtraction            => [ :binary,    :sub                            ],
        Function::Numeric::UnaryMinus             => [ :unary,     :unary_minus                    ],
        Function::Numeric::UnaryPlus              => [ :unary,     :unary_plus                     ],
        Function::Proposition::Tautology          => [ :static,    :true                           ],
        Function::Proposition::Contradiction      => [ :static,    :false                          ],
        Attribute::String                         => [ :attribute                                  ],
        Attribute::Integer                        => [ :attribute                                  ]
      }

      # Transform veritas relation into s-expression
      #
      # @param [Axiom::Relation] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.visit(relation)
        name, *options = REGISTRY.fetch(relation.class) { return relation }
        send(name, relation, *options)
      end

      # Helper method for materialized s-expressions
      #
      # @param [Axiom::Relation::Materialized] relation
      # @param [Symbol] tag
      #
      # @return [Array]
      #
      # @api private
      #
      def self.materialized(materialized)
        [ :materialized, base_header(materialized.header), tuples(materialized) ]
      end
      private_class_method :materialized

      # Helper method for tuple s-expressions
      #
      # @param [Relation] relation
      #
      # @return [Array]
      #
      # @api private
      #
      def self.tuples(relation)
        relation.map(&:to_ary)
      end
      private_class_method :tuples

      # Helper method for static s-expressions
      #
      # @param [Axiom::Relation] _relation
      # @param [Symbol] tag
      #
      # @return [Array]
      #
      # @api private
      #
      def self.static(_relation, tag)
        [ tag ]
      end
      private_class_method :static

      # Helper for binary s-expressions
      #
      # @param [Axiom::Relation] relation
      # @param [Symbol] tag
      # @param [Symbol] left
      # @param [Symbol] right
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.binary(relation, tag, left = :left, right = :right)
        [ tag, visit(relation.public_send(left)), visit(relation.public_send(right)) ]
      end
      private_class_method :binary

      # Helper for unary s-expressions
      #
      # @param [Axiom::Relation] relation
      # @param [Symbol] tag
      # @param [Symbol] operand
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.unary(relation, tag, operand)
        [ tag, visit(relation.public_send(operand)) ]
      end
      private_class_method :unary

      # Helper for enumerable s-expressions
      #
      # @param [Enumerable<Axiom::Relation>] input
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.collect(input)
        input.map do |item|
          visit(item)
        end
      end
      private_class_method :collect
      
      # Helper for Axiom::Algebra::Extend s-expressions
      #
      # @param [Axiom::Algebra::Extend] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.extend(relation)
        [ :extend, visit(relation.operand), extensions(relation.extensions) ]
      end
      private_class_method :extend
      
      # Helper for Axiom::Algebra::Extend s-expressions
      #
      # @param [Hash] hash
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.extensions(hash)
        hash.map do |attribute, relation|
          [ attribute.name, visit(relation) ]
        end
      end
      private_class_method :extensions
      
      # Helper for Axiom::Relation::base s-expressions
      #
      # @param [Axiom::Relation::Base] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.base(relation)
        [ :base, relation.name, base_header(relation.header) ]
      end
      private_class_method :base

      # Helper for Axiom::Relation::base s-expressions
      #
      # @param [Axiom::Relation::Header] header
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.base_header(header)
        header.map do |attribute|
          base_attribute(attribute)
        end
      end
      private_class_method :base_header

      # Helper for Axiom::Relation::base s-expressions
      #
      # @param [Axiom::Attribute] attribute
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.base_attribute(attribute)
        [ attribute.name, attribute.class ]
      end
      private_class_method :base_attribute


      # Helper for Axiom::Attribute s-expressions
      #
      # @param [Axiom::Attribute] attribute
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.attribute(attribute)
        [ :attr, attribute.name ]
      end
      private_class_method :attribute

    end
  end
end
