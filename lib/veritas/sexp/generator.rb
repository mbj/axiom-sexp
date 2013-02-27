require 'veritas'

module Veritas
  module Sexp
    # Generator for s-expressions
    module Generator
      # Incomplete sexp formatter operation table
      REGISTRY = IceNine.deep_freeze( 
        Relation::Base                           => [ :base                                       ],
        Relation::Operation::Order               => [ :binary,    :order, :operand, :directions   ],
        Relation::Header                         => [ :collect                                    ],
        Relation::Operation::Order::DirectionSet => [ :collect                                    ],
        Relation::Operation::Order::Ascending    => [ :unary,     :asc,  :attribute               ],
        Relation::Operation::Order::Descending   => [ :unary,     :desc, :attribute               ],
        Relation::Operation::Limit               => [ :binary,    :limit, :operand, :limit        ],
        Relation::Operation::Offset              => [ :binary,    :offset, :operand, :offset      ],
        Algebra::Restriction                     => [ :binary,    :restrict, :operand, :predicate ],
        Algebra::Extension                       => [ :extend                                     ],
        Algebra::Projection                      => [ :binary,    :project, :operand, :header     ],
        Algebra::Join                            => [ :binary,    :join                           ],
        Algebra::Product                         => [ :binary,    :product                        ],
        Function::Predicate::Equality            => [ :binary,    :eql                            ],
        Function::Numeric::Absolute              => [ :binary,    :abs                            ],
        Function::Numeric::Addition              => [ :binary,    :add                            ],
        Function::Numeric::Division              => [ :binary,    :div                            ],
        Function::Numeric::Exponentiation        => [ :binary,    :exp                            ],
        Function::Numeric::Modulo                => [ :binary,    :mod                            ],
        Function::Numeric::Multiplication        => [ :binary,    :mul                            ],
        Function::Numeric::SquareRoot            => [ :unary,     :sqr                            ],
        Function::Numeric::Subtraction           => [ :binary,    :sub                            ],
        Function::Numeric::UnaryMinus            => [ :unary,     :unary_minus                    ],
        Function::Numeric::UnaryPlus             => [ :unary,     :unary_plus                     ],
        Attribute::String                        => [ :attribute                                  ],
        Attribute::Integer                       => [ :attribute                                  ]
      )

      # Transform veritas relation into s-expression
      #
      # @param [Veritas::Relation] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.visit(relation)
        name, *options = REGISTRY.fetch(relation.class) { return relation }
        send(name, relation, *options)
      end

      # Helper for binary s-expressions
      #
      # @param [Veritas::Relation] relation
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
      # @param [Veritas::Relation] relation
      # @param [Symbol] tag
      # @param [Symbol] operand
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.unary(relation, tag, operand = :operand)
        [ tag, visit(relation.public_send(operand)) ]
      end
      private_class_method :unary

      # Helper for enumerable s-expressions
      #
      # @param [Enumerable<Veritas::Relation>] input
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
      
      # Helper for Veritas::Algebra::Extend s-expressions
      #
      # @param [Veritas::Algebra::Extend] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.extend(relation)
        [ :extend, visit(relation.operand), extensions(relation.extensions) ]
      end
      private_class_method :extend
      
      # Helper for Veritas::Algebra::Extend s-expressions
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
      
      # Helper for Veritas::Relation::base s-expressions
      #
      # @param [Veritas::Relation::Base] relation
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.base(relation)
        [ :base, relation.name, base_header(relation.header) ]
      end
      private_class_method :base

      # Helper for Veritas::Relation::base s-expressions
      #
      # @param [Veritas::Relation::Header] header
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

      # Helper for Veritas::Relation::base s-expressions
      #
      # @param [Veritas::Attribute] attribute
      #
      # @return [Array] 
      #
      # @api private
      #
      def self.base_attribute(attribute)
        [ attribute.name, attribute.class ]
      end
      private_class_method :base_attribute


      # Helper for Veritas::Attribute s-expressions
      #
      # @param [Veritas::Attribute] attribute
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
