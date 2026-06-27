import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return formatDate(date);
    }
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 2)} ${phone.substring(2, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 8)} ${phone.substring(8, 10)}';
    }
    return phone;
  }

  static String formatDaysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'En retard de ${-difference.inDays} jours';
    } else if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Demain';
    } else {
      return '${difference.inDays} jours restants';
    }
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount);
  }
}
