import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/models/app_transaction.dart';

class TransactionListItem extends StatelessWidget {
  final AppTransaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSale = transaction.type == 'Venda';

    final iconColor = isSale ? Colors.greenAccent[400] : Colors.redAccent[400];
    final iconData = isSale ? Icons.trending_up : Icons.trending_down;
    final prefixSign = isSale ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor?.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 28, color: iconColor),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.entityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.type,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ${transaction.itemCount} itens',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Data: ${transaction.date} | ID: ${transaction.id}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$prefixSign R\$ ${transaction.totalValue}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSale ? Colors.greenAccent[400] : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
