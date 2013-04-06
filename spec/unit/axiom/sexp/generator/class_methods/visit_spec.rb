require 'spec_helper'

describe Axiom::Sexp::Generator, '.visit' do
  let(:object) { described_class }

  subject { object.visit(relation) }

  let(:header)        { Axiom::Relation::Header.coerce([[:foo, Integer]]) }
  let(:base_relation) { Axiom::Relation::Base.new(:name, header)          }

  let(:sorted_base_relation) { base_relation.sort_by { |r| [r.foo.asc] } }

  let(:other_header)        { Axiom::Relation::Header.coerce([[:bar, Integer]]) }
  let(:other_base_relation) { Axiom::Relation::Base.new(:other, other_header)   }

  def self.expect_sexp
    it 'should return correct sexp' do
      should eql(yield)
    end
  end

  context 'with proposition' do
    context 'tautology' do
      let(:relation) { Axiom::Function::Proposition::Tautology.new }

      expect_sexp do
        [ :true ]
      end
    end

    context 'contradiction' do
      let(:relation) { Axiom::Function::Proposition::Contradiction.new }

      expect_sexp do
        [ :false ]
      end
    end
  end

  context 'with materialized relation' do
    let(:relation) { Axiom::Relation.new(header, [ [ 1 ] ] ) }

    expect_sexp do
      [ :materialized, [ [ :foo, Axiom::Attribute::Integer ] ], [ [ 1 ] ] ]
    end
  end

  context 'with base relation' do
    let(:relation) { base_relation }

    expect_sexp do
      [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ]
    end
  end

  context 'order' do
    let(:relation) { sorted_base_relation }

    expect_sexp do
      [ :order,
        [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
        [[ :asc, [ :attr, :foo ] ]]
      ]
    end
  end

  context 'offset' do
    let(:relation) { sorted_base_relation.drop(2) }

    expect_sexp do
      [
        :offset,
        [ :order,
          [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
          [[ :asc, [ :attr, :foo ] ]]
        ],
        2
      ]
    end
  end

  context 'limit' do
    let(:relation) { sorted_base_relation.take(2) }

    expect_sexp do
      [
        :limit,
        [ :order,
          [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
          [[ :asc, [ :attr, :foo ] ]]
        ],
        2
      ]
    end
  end

  context 'restriction' do
    let(:relation) { base_relation.restrict { |r| r.foo.eq('bar') } }

    expect_sexp do
      [ :restrict,
        [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
        [ :eq, [ :attr, :foo ] , 'bar' ]
      ]
    end
  end

  context 'product' do
    let(:relation) { base_relation.product(other_base_relation) }

    expect_sexp do
      [ :product,
        [ :base, 'name',  [ [ :foo, Axiom::Attribute::Integer ] ] ],
        [ :base, 'other', [ [ :bar, Axiom::Attribute::Integer ] ] ]
      ]
    end
  end

  context 'join' do
    let(:relation) { base_relation.join(base_relation) }

    expect_sexp do
      [ :join,
        [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
        [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ]
      ]
    end
  end

  context 'projection' do
    let(:relation) { base_relation.project([:foo]) }

    expect_sexp do
      [ :project,
        [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
        [ [ :attr, :foo ] ]
      ]
    end
  end

  context 'extension' do
    context 'with plain attribute' do
      let(:relation) { base_relation.extend { |r| r.add(:bar, r.foo) } }

      expect_sexp do
        [ :extend,
          [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
          [
            [ :bar, [ :attr, :foo ] ]
          ]
        ]
      end
    
    end

    context 'with multiplication' do
      let(:relation) { base_relation.extend { |r| r.add(:bar, r.foo * 2) } }

      expect_sexp do
        [ :extend,
          [ :base, 'name', [ [ :foo, Axiom::Attribute::Integer ] ] ],
          [
            [ :bar, [ :mul, [ :attr, :foo ], 2 ] ]
          ]
        ]
      end
    
    end
  end
end
