class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
    add_index :articles, :title, :unique => true
  end
end
