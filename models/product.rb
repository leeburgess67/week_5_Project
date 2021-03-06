require_relative('../db/sql_runner')
require_relative('./shop.rb')
require_relative('./supplier.rb')
require('pry-byebug')

class Product

  attr_reader :id, :supplier_id, :upn
  attr_accessor :description, :cost_price, :retail_price, :bookstock

  def initialize(options)
    @id = options['id'].to_i
    @description = options['description']
    @cost_price = options['cost_price'].to_i
    @retail_price = options['retail_price'].to_i
    @bookstock = options['bookstock'].to_i
    @supplier_id = options['supplier_id'].to_i
    @upn = options['upn'].to_i
  end

  #CREATE
  def save()
    sql = "INSERT INTO products
    (
    description,
    cost_price,
    retail_price,
    bookstock,
    supplier_id,
    upn
    )
    VALUES
    (
    $1, $2, $3, $4, $5, $6
    )
    RETURNING *"
    values = [@description, @cost_price, @retail_price, @bookstock, @supplier_id, @upn]
    product = SqlRunner.run(sql, values).first
    @id = product['id'].to_i
  end

  #READ
  def self.all()
    sql = "SELECT * FROM products ORDER BY bookstock"
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

  def supplier()
    sql = "SELECT * FROM suppliers
    WHERE id = $1"
    values = [@supplier_id]
    result = SqlRunner.run( sql, values ) #an array of
    Supplier.new( result.first )
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
    supplier_id,
    upn
    ) =
    (
    $1, $2, $3, $4, $5, $6
    )
    WHERE id = $7"
    values = [@description, @cost_price, @retail_price, @bookstock, @supplier_id, @upn, @id]
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


  #METHODS
  def sell(qty)
    @bookstock -= qty
    update()
  end

  def delivered(qty)
    @bookstock += qty
    update()
  end

  def markup
    return  @retail_price - @cost_price
  end

  def check_stock
    return "stock-red" if @bookstock < 2
    return "stock-green" if @bookstock > 3
    return "stock-amber" if @bookstock > 1
  end

  def return_stock_warning
    return "Warning" if @bookstock < 2
    return "Ok" if @bookstock > 3
    return "Low" if @bookstock > 1
  end

  def get_markup_percentage
    markup_percentage = ((markup/@cost_price.to_f) * 100.0).round(0)
    return "#{markup_percentage}%"
  end

  def convert_to_cash(number)#1000
    return "£#{number}"
  end

  #CLASS METHODS
  def self.find_by_upn(upn)
    sql = "SELECT * FROM products
    WHERE upn = $1"
    values = [upn]
    result = SqlRunner.run(sql, values)
    if result.ntuples == 0
      return nil
    else
      product = Product.new(result.first)
      return product
    end
  end

end
