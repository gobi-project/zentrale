class CreateTorfComplexMatchers < ActiveRecord::Migration
  def change
    create_table :torf_complex_matchers do |t|
      t.belongs_to :torf_rule
      t.belongs_to :torf_state
      t.integer :parent_complex_matcher_id
      t.string :type
      t.timestamps
    end
  end
end