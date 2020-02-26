class ChangeItemTypeDefaultForInboxComments < ActiveRecord::Migration[5.1]
  def change
    change_column_default :inbox_comments, :item_type, from: "Comment", to: ""
  end
end
