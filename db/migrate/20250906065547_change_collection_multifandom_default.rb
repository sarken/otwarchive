class ChangeCollectionMultifandomDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :collections, :multifandom, from: nil, to: false
    change_column_null :collections, :multifandom, false
  end
end
