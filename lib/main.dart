
abstract class Product {
  final String name;
  final double price;
  int quantity;

  Product(this.name, this.price, this.quantity);

  bool isExpired();
  bool isShipped();
}

class PershiableProduct extends Product {
  DateTime expiryDate;
  double weight;

  PershiableProduct(
      String name,
      double price,
      int quantity,
      this.expiryDate,
      this.weight,
      ) : super(name, price, quantity);

  @override
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  @override
  bool isShipped() {
    return true;
  }
}

class NonPerishableProduct extends Product {
  final bool needsShipping;
  final double? weight;

  NonPerishableProduct(
      String name,
      double price,
      int quantity, {
        this.needsShipping = false,
        this.weight,
      }) : super(name, price, quantity);

  @override
  bool isExpired() => false;

  @override
  bool isShipped() => needsShipping;
}


class Customer {
  final String name;
  double balance;

  Customer(this.name, this.balance);
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem(this.product, this.quantity);
}

class Cart {
  final List<CartItem> items = [];

  void add(Product product, int quantity) {
    if (quantity > product.quantity) {
      throw Exception("Not enough quantity in stock for ${product.name}");
    }
    items.add(CartItem(product, quantity));
  }

  bool isEmpty() => items.isEmpty;

  double getSubtotal() {
    double total = 0;
    for (var item in items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  List<ShippableItem> getShippableItems() {
    List<ShippableItem> shippables = [];
    for (var item in items) {
      if (item.product.isShipped()) {
        double weight = 0;
        if (item.product is PershiableProduct) {
          weight = (item.product as PershiableProduct).weight * item.quantity;
        } else if (item.product is NonPerishableProduct) {
          weight = ((item.product as NonPerishableProduct).weight ?? 0) * item.quantity;
        }
        shippables.add(ShippableItem("${item.quantity}x ${item.product.name}", weight));
      }
    }
    return shippables;
  }
}

class ShippableItem {
  final String name;
  final double weight;

  ShippableItem(this.name, this.weight);
}

class ShippingService {
  void ship(List<ShippableItem> items) {
    if (items.isEmpty) return;

    print(" Shipment paper");
    for (var item in items) {
      print("${item.name} ${item.weight.toStringAsFixed(0)}g");
    }

    double totalWeight = items.fold(0, (sum, item) => sum + item.weight);
    print("Total package weight ${totalWeight / 1000}kg");
  }
}

void checkout(Customer customer, Cart cart) {
  if (cart.isEmpty()) {
    print( "Cart is empty");
    return;
  }

  for (var item in cart.items) {
    if (item.product.isExpired()) {
      print(" Product ${item.product.name} is expired");
      return;
    }

    if (item.quantity > item.product.quantity) {
      print(" Not enough quantity for ${item.product.name}");
      return;
    }
  }

  double subtotal = cart.getSubtotal();
  double shippingFee = 30;
  double total = subtotal + shippingFee;

  if (customer.balance < total) {
    print(" Insufficient balance");
    return;
  }

  for (var item in cart.items) {
    item.product.quantity -= item.quantity;
  }

  customer.balance -= total;

  var shippingService = ShippingService();
  var shippableItems = cart.getShippableItems();
  shippingService.ship(shippableItems);

  print(" Checkout receipt ");
  for (var item in cart.items) {
    print("${item.quantity}x ${item.product.name} ${item.product.price * item.quantity}");
  }
  print("----------------------");
  print("Subtotal \$${subtotal}");
  print("Shipping \$${shippingFee}");
  print("Amount \$${total}");
  print("Customer balance: \$${customer.balance}");
}

void main() {
  var customer = Customer("Mariem", 1000);

  var cheese = PershiableProduct("Cheese", 100, 5, DateTime(2025, 12, 1), 200);
  var biscuits = PershiableProduct("Biscuits", 150, 3, DateTime(2025, 10, 1), 700);
  var scratchCard = NonPerishableProduct("Scratch Card", 50, 10);
  var tv = NonPerishableProduct("TV", 5000, 2, needsShipping: true, weight: 15000);

  var cart = Cart();
  cart.add(cheese, 2);
  cart.add(biscuits, 1);
  cart.add(scratchCard, 1);

  checkout(customer, cart);


}
