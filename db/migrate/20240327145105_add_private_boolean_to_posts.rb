class AddPrivateBooleanToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :public, :boolean, default: true, null: false

    Post.update_all(public: true)
  end
end
