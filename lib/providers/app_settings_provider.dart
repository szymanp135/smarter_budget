import 'package:flutter/material.dart';
import '../constants.dart';
import 'user_provider.dart';

enum AppTheme { light, dark }

enum AppLanguage { pl, en }

enum AppCurrency { pln, eur }

class AppSettingsProvider extends ChangeNotifier {
  final UserProvider _userProvider;

  AppTheme _theme = AppTheme.light;
  AppLanguage _language = AppLanguage.pl;
  AppCurrency _currency = AppCurrency.pln;

  static const double _exchangeRate = 4.2;

  AppSettingsProvider(this._userProvider);

  void syncSettings(
    AppTheme theme,
    AppLanguage language,
    AppCurrency? currency,
  ) {
    _theme = theme;
    _language = language;
    _currency = currency ?? AppCurrency.pln;
    notifyListeners();
  }

  ThemeMode get themeMode =>
      _theme == AppTheme.light ? ThemeMode.light : ThemeMode.dark;

  AppTheme get theme => _theme;

  AppLanguage get language => _language;

  AppCurrency get currency => _currency;

  void toggleTheme(AppTheme theme) {
    _theme = theme;
    _saveUserSettings(theme: theme);
    notifyListeners();
  }

  void changeLanguage(AppLanguage lang) {
    _language = lang;
    _saveUserSettings(language: lang);
    notifyListeners();
  }

  Future<void> changeCurrency(AppCurrency newCurrency) async {
    if (_currency == newCurrency) return;

    final double? currentLimit = _userProvider.currentUser?.monthlyLimit;
    double? newLimitToSave;

    if (currentLimit != null && currentLimit > 0) {
      if (_currency == AppCurrency.pln && newCurrency == AppCurrency.eur) {
        newLimitToSave = currentLimit / _exchangeRate;
      } else if (_currency == AppCurrency.eur &&
          newCurrency == AppCurrency.pln) {
        newLimitToSave = currentLimit * _exchangeRate;
      }
    }

    _currency = newCurrency;
    notifyListeners();

    if (_userProvider.currentUser != null) {
      await _userProvider.updateSettings(
        currency: newCurrency,
        monthlyLimit: newLimitToSave,
      );
    }
  }

  Future<void> _saveUserSettings({
    AppTheme? theme,
    AppLanguage? language,
    AppCurrency? currency,
  }) async {
    if (_userProvider.currentUser != null) {
      await _userProvider.updateSettings(
        theme: theme,
        language: language,
        currency: currency,
      );
    }
  }

  String currencySymbol() {
    switch (_currency) {
      case AppCurrency.pln:
        return "zł";
      case AppCurrency.eur:
        return "€";
    }
  }

  double convertAmount(double amount) {
    if (_currency == AppCurrency.eur) return amount / _exchangeRate;
    return amount;
  }

  String t(String key) {
    if (_language == AppLanguage.pl) {
      return _plStrings[key] ?? key;
    } else {
      return _enStrings[key] ?? key;
    }
  }

  /*String translateCategory(String categoryKey) {
    return t(categoryKey);
  }*/

  String getCategoryKey(String translatedName) {
    final map = _language == AppLanguage.pl ? _plStrings : _enStrings;
    for (var entry in map.entries) {
      if (entry.value == translatedName) {
        return entry.key;
      }
    }
    return translatedName;
  }

  /*IconData getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_bus_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'OtherExpense':
        return Icons.category_rounded;
      case 'Salary':
        return Icons.account_balance_wallet_rounded;
      case 'Gift':
        return Icons.card_giftcard_rounded;
      case 'Bonus':
        return Icons.star_rounded;
      case 'Investment':
        return Icons.trending_up_rounded;
      case 'OtherIncome':
        return Icons.attach_money_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Bills':
        return Colors.redAccent;
      case 'Entertainment':
        return Colors.pinkAccent;
      case 'OtherExpense':
        return Colors.grey;
      case 'Salary':
        return Colors.green;
      case 'Gift':
        return Colors.amber;
      case 'Bonus':
        return Colors.teal;
      case 'Investment':
        return Colors.indigo;
      case 'OtherIncome':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }*/

  final Map<String, String> _plStrings = {
    'app_name': 'Smarter Budget',
    'add_transaction': 'Dodaj transakcję',
    'edit_transaction': 'Edytuj transakcję',
    'title': 'Tytuł',
    'amount': 'Kwota',
    'category': 'Kategoria',
    'date': 'Data',
    'description': 'Opis (opcjonalnie)',
    'description2': 'Opis',
    'expense': 'Wydatek',
    'income': 'Przychód',
    'save': 'Zapisz',
    'select_category': 'Wybierz kategorię',
    'save_changes': 'Zapisz zmiany',
    'my_transactions': 'Moje transakcje',
    'transactions': 'Transakcje',
    'statistics': 'Statystyki',
    'my_statistics': 'Moje statystyki',
    'settings': 'Ustawienia',
    'theme': 'Motyw',
    'language': 'Język',
    'currency': 'Waluta',
    'no_transactions': 'Brak transakcji.',
    'login': 'Zaloguj',
    'register': 'Zarejestruj',
    'username': 'Nazwa użytkownika',
    'password': 'Hasło',
    'invalid_credentials': 'Nieprawidłowe dane logowania',
    'username_exists': 'Nazwa użytkownika już istnieje',
    'passwords_do_not_match': 'Hasła nie pasują',
    'repeat_password': 'Powtórz hasło',
    'fill_all_fields': 'Wypełnij wszystkie pola',
    'create_account': 'Utwórz konto',
    'go_to_login': 'Przejdź do logowania',
    'english': 'Angielski',
    'polish': 'Polski',
    'light_theme': 'Jasny',
    'dark_theme': 'Ciemny',
    'enter_amount': 'Wprowadź kwotę',
    'invalid_number': 'Nieprawidłowa liczba',
    'select_currency_title': 'Wybierz walutę',
    'select_currency_prompt': 'Wybierz domyślną walutę dla swojego konta',
    'welcome_message': 'Witaj,',
    'example_hint': 'np. 2000.00',
    'preferences': 'Preferencje',
    'budget': 'Budżet',
    'data_section': 'Dane',
    'monthly_limit': 'Limit miesięczny',
    'no_limit': 'Brak limitu',
    'save_csv': 'Zapisz CSV',
    'download_history': 'Pobierz plik z historią',
    'logout': 'Wyloguj się',
    'set_limit': 'Ustaw limit',
    'limit_description':
        'Wpisz maksymalną kwotę, jaką planujesz wydać w miesiącu.',
    'cancel': 'Anuluj',
    'logout_confirmation': 'Potwierdzenie wylogowania',
    'logout_message': 'Czy na pewno chcesz się wylogować?',
    'yes': 'Tak',
    'no': 'Nie',
    'type': 'Typ',
    'csv_saved': 'Zapisano w Pobranych:\n',
    'csv_error': 'Błąd zapisu: ',
    'select_period': 'Wybierz okres czasu:',
    'your_balance': 'Twój bilans',
    'yearly_balance': 'Bilans roczny',
    'monthly_balance': 'Bilans miesięczny',
    'category_details': 'Szczegóły kategorii',
    '1_month': '1 Miesiąc',
    '3_months': '3 Miesiące',
    '6_months': '6 Miesięcy',
    '1_year': '1 Rok',
    'all_time': 'Wszystko',
    'your_budget': 'Twój budżet',
    'over_budget_by': 'Przekroczono o',
    'next': 'Dalej',
    'back': 'Wstecz',
    'step_type': 'Rodzaj',
    'step_details': 'Dane',
    'step_review': 'Zapisz',
    'transaction_deleted': 'Usunięto transakcję',
    'undo': 'Cofnij',
    'credits_header': 'Autorzy',
    'credits':
        'Autor: Aleksandra Zawadka\nKontrybucja: Paweł Szymański\nWersja $appVersion',
    'categories': 'Kategorie',
    'category_manager': 'Menadżer Kategorii',
    'categories_uninitialized': 'Kategorie nie zostały wczytane',
    'manage_categories': 'Zarządzaj kategoriami',
    'manage_categories_subtext': 'Dodaj, zmień lub usuń kategorie',
    'add_category': 'Dodaj kategorię',
    'category_enter_name': 'Podaj nazwę',
    'pick_color': 'Wybierz kolor:',
    'pick_icon': 'Wybierz ikonkę:',
    'pick_type': 'Wybierz rodzaj:',
    'add': 'Dodaj',
    'done': 'Gotowe',
    'warning_empty_text_field': 'Pole nie może być puste',
    'warning_such_category_exists': 'Ta kategoria już istnieje',
    'no_categories': 'Brak kategorii.',

    // Kategorie
    'Food': 'Jedzenie',
    'Transport': 'Transport',
    'Shopping': 'Zakupy',
    'Bills': 'Rachunki',
    'Entertainment': 'Rozrywka',
    'OtherExpense': 'Inne wydatki',
    'Salary': 'Wypłata',
    'Gift': 'Prezent',
    'Bonus': 'Premia',
    'Investment': 'Inwestycje',
    'OtherIncome': 'Inne przychody',
  };

  final Map<String, String> _enStrings = {
    'app_name': 'Smarter Budget',
    'add_transaction': 'Add Transaction',
    'edit_transaction': 'Edit Transaction',
    'title': 'Title',
    'amount': 'Amount',
    'category': 'Category',
    'date': 'Date',
    'description': 'Description (optional)',
    'description2': 'Description',
    'expense': 'Expense',
    'income': 'Income',
    'save': 'Save',
    'select_category': 'Select Category',
    'save_changes': 'Save Changes',
    'my_transactions': 'My Transactions',
    'transactions': 'Transactions',
    'statistics': 'Statistics',
    'my_statistics': 'My Statistics',
    'settings': 'Settings',
    'theme': 'Theme',
    'language': 'Language',
    'currency': 'Currency',
    'no_transactions': 'No transactions found.',
    'login': 'Login',
    'register': 'Register',
    'username': 'Username',
    'password': 'Password',
    'invalid_credentials': 'Invalid credentials',
    'username_exists': 'Username already exists',
    'passwords_do_not_match': 'Passwords do not match',
    'repeat_password': 'Repeat password',
    'fill_all_fields': 'Fill all fields',
    'create_account': 'Create Account',
    'go_to_login': 'Go to Login',
    'english': 'English',
    'polish': 'Polish',
    'light_theme': 'Light',
    'dark_theme': 'Dark',
    'enter_amount': 'Enter amount',
    'invalid_number': 'Invalid number',
    'select_currency_title': 'Select Currency',
    'select_currency_prompt': 'Choose default currency for your account',
    'welcome_message': 'Welcome,',
    'example_hint': 'e.g. 2000.00',
    'preferences': 'Preferences',
    'budget': 'Budget',
    'data_section': 'Data',
    'monthly_limit': 'Monthly Limit',
    'no_limit': 'No limit set',
    'save_csv': 'Save CSV',
    'download_history': 'Download history file',
    'logout': 'Log out',
    'set_limit': 'Set Limit',
    'limit_description':
        'Enter the maximum amount you plan to spend per month.',
    'cancel': 'Cancel',
    'logout_confirmation': 'Log out confirmation',
    'logout_message': 'Are you sure you want to log out?',
    'yes': 'Yes',
    'no': 'No',
    'type': 'Type',
    'csv_saved': 'Saved to Downloads:\n',
    'csv_error': 'Save error: ',
    'select_period': 'Select time period:',
    'your_balance': 'Your Balance',
    'yearly_balance': 'Yearly Balance',
    'monthly_balance': 'Monthly Balance',
    'category_details': 'Category Details',
    '1_month': '1 Month',
    '3_months': '3 Months',
    '6_months': '6 Months',
    '1_year': '1 Year',
    'all_time': 'All Time',
    'your_budget': 'Your Budget',
    'over_budget_by': 'Over budget by',
    'next': 'Next',
    'back': 'Back',
    'step_type': 'Type',
    'step_details': 'Details',
    'step_review': 'Review',
    'transaction_deleted': 'Transaction deleted',
    'undo': 'Undo',
    'credits_header': 'Credits',
    'credits':
        'Author: Aleksandra Zawadka\nContribution: Paweł Szymański\nVersion $appVersion',
    'categories': 'Categories',
    'category_manager': 'Category Manager',
    'categories_uninitialized': "Categories couldn't initialize",
    'manage_categories': 'Manage categories',
    'manage_categories_subtext': 'Add, change or remove categories',
    'add_category': 'Add category',
    'category_enter_name': 'Enter name',
    'pick_color': 'Pick color:',
    'pick_icon': 'Pick icon:',
    'pick_type': 'Pick type:',
    'add': 'Add',
    'done': 'Done',
    'warning_empty_text_field': 'Field cannot be empty',
    'warning_such_category_exists': 'Such category already exists',
    'no_categories': 'No categories found.',

    // Categories
    'Food': 'Food',
    'Transport': 'Transport',
    'Shopping': 'Shopping',
    'Bills': 'Bills',
    'Entertainment': 'Entertainment',
    'OtherExpense': 'Other Expense',
    'Salary': 'Salary',
    'Gift': 'Gift',
    'Bonus': 'Bonus',
    'Investment': 'Investment',
    'OtherIncome': 'Other Income',
  };
}
