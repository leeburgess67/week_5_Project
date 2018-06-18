require_relative('../db/sql_runner')
require_relative('./shop.rb')
require('pry-byebug')


class Product

  attr_reader :id, :supplier_id
  attr_accessor :description, :cost_price, :retail_price, :bookstock

  def initialize(options)
    @id = options['id'].to_i
    @description = options['description']
    @cost_price = options['cost_price'].to_i
    @retail_price = options['retail_price'].to_i
    @bookstock = options['bookstock'].to_i
    @supplier_id = options['supplier_id'].to_i
  end
  #CREATE
  def save()
    sql = "INSERT INTO products
    (
      description,
      cost_price,
      retail_price,
      bookstock,
      supplier_id
    )
    VALUES
    (
      $1, $2, $3, $4, $5
    )
    RETURNING *"
    values = [@description, @cost_price, @retail_price, @bookstock, @supplier_id]
    product = SqlRunner.run(sql, values).first
    @id = product['id'].to_i
  end

  #READ
  def self.all()
    sql = "SELECT * FROM products"
    products = SqlRunner.run( sql )
    result =  products.map { |product| Product.new( product ) }
  end


  def self.find( id )
    sql = "SELECT * FROM products
    WHERE id = $1"
    values = [id]
    product = SqlRunner.run( sql, values )
    result = Product.new( product.first )
    return result
  end



  #UPDATE
  def update()
    sql = "UPDATE products
    SET
    (
    description,
    cost_price,
    retail_price,
    bookstock,
    supplier_id
    ) =
    (
      $1, $2, $3, $4, $5
    )
    WHERE id = $6"
    values = [@description, @cost_price, @retail_price, @bookstock, @supplier_id, @id]
    SqlRunner.run( sql, values )
  end

  #DELETE
  def self.delete_all
    sql = "DELETE FROM products"
    SqlRunner.run( sql )
  end

  def delete()
    sql = "DELETE FROM products
    WHERE id = $1"
    values = [@id]
    SqlRunner.run( sql, values )
  end


  def sold(qty, shop)
    @bookstock -= qty
    value = @retail_price.to_i * qty.to_i
    return shop.takings += value
  end

  def refund(qty, shop)
    @bookstock += qty
    value = @retail_price.to_i * qty.to_i
    return shop.takings -= value
  end

  def markup
      return  @retail_price - @cost_price
  end













end
