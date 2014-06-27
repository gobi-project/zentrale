class CreateTorfSimpleMatchers < ActiveRecord::Migration
  def change
    create_table :torf_simple_matchers do |t|
      t.belongs_to :torf_rule
      t.belongs_to :torf_complex_matcher
      t.belongs_to :torf_resource
      t.belongs_to :torf_state
      t.string :type
      t.integer :value
      t.timestamps
    end
  end
end