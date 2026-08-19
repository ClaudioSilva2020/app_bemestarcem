import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/common/product_image.dart';
import 'package:bemestarcem/helpers/formatters.dart';
import 'package:bemestarcem/models/cart_product.dart';
import 'package:flutter/material.dart';

/// Linha do carrinho: miniatura quadrada arredondada, nome, preço total do
/// item e o seletor de quantidade — tudo dentro do card, sem transbordar.
class ShopItemList extends StatelessWidget {
  const ShopItemList(
    this.item, {
    super.key,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  final CartProduct item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final product = item.product!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 1.5,
      shadowColor: Colors.black26,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 84.0,
                width: 84.0,
                color: const Color(0xFFF2F4F7),
                child: ProductImage(product, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    formatPrice(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: darkYellow,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  _QuantityStepper(
                    quantity: item.quantity,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
              tooltip: 'Remover do carrinho',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  static const int _max = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28.0,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: quantity < _max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20.0,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 16.0,
          color: onTap == null ? Colors.black26 : darkYellow,
        ),
      ),
    );
  }
}
