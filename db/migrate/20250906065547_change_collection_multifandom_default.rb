class ChangeCollectionMultifandomDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :collections, :multifandom, from: nil, to: false
  end
end
