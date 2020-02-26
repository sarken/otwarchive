class AddItemTypeToInboxComments < ActiveRecord::Migration[5.1]
  def change
    add_column :inbox_comments, :item_type, :string, default: "Comment"
  end
end
