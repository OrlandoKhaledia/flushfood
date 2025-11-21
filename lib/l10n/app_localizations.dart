import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'flashfood',
      'onboardingTitle1': 'Add items to your inventory',
      'onboardingTitle2': 'Track expiry & reduce waste',
      'onboardingTitle3': 'Shopping lists & analytics',
      'searchHint': 'Search items',
      'dashboardTitle': 'Dashboard',
      'sortByExpiry': 'Sort by expiry',
      'sortByName': 'Sort by name',
      'addItemTooltip': 'Add item',
      'emptyState': 'No items match your filters.\nTap + to add something!',
      'total': 'Total',
      'expiring': 'Expiring',
      'low': 'Low',
    }
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get searchHint => _localizedValues[locale.languageCode]!['searchHint']!;
  String get dashboardTitle => _localizedValues[locale.languageCode]!['dashboardTitle']!;
  String get sortByExpiry => _localizedValues[locale.languageCode]!['sortByExpiry']!;
  String get sortByName => _localizedValues[locale.languageCode]!['sortByName']!;
  String get addItemTooltip => _localizedValues[locale.languageCode]!['addItemTooltip']!;
  String get emptyState => _localizedValues[locale.languageCode]!['emptyState']!;
  String get total => _localizedValues[locale.languageCode]!['total']!;
  String get expiring => _localizedValues[locale.languageCode]!['expiring']!;
  String get low => _localizedValues[locale.languageCode]!['low']!;

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
