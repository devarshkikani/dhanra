import 'dart:ui';

class CategoryKeyWord {
  static final Map<String, String> upiKeywordCategoryMapping = {
    // 🏠 Housing / Utilities
    'tatapower': 'Utilities',
    'besscom': 'Utilities',
    'mseb': 'Utilities',
    'adani': 'Utilities',
    'torrentpower': 'Utilities',
    'ioenergy': 'Utilities',
    'rent': 'Housing',
    'nobroker': 'Housing',
    'mygate': 'Housing',

    // 🚗 Transportation
    'uber': 'Transportation',
    'ola': 'Transportation',
    'rapido': 'Transportation',
    'meru': 'Transportation',
    'blusmart': 'Transportation',

    // 🍔 Food
    'zomato': 'Food',
    'swiggy': 'Food',
    'dominos': 'Food',
    'mcdonalds': 'Food',
    'faasos': 'Food',
    'freshmenu': 'Food',
    'eatsure': 'Food',
    'pizza': 'Food',

    // 💇 Personal Care
    'nykaa': 'Personal Care',
    'purplle': 'Personal Care',
    'myglamm': 'Personal Care',
    'sugarcosmetics': 'Personal Care',
    'mamaearth': 'Personal Care',
    'wow': 'Personal Care',

    // 👗 Clothing / Fashion
    'myntra': 'Clothing',
    'ajio': 'Clothing',
    'jabong': 'Clothing',
    'meesho': 'Clothing',
    'snapdeal': 'Clothing',
    'limelane': 'Clothing',
    'fbb': 'Clothing',
    'maxfashion': 'Clothing',
    'pantaloons': 'Clothing',
    'westside': 'Clothing',
    'zudio': 'Clothing',
    'marksandspencer': 'Clothing',
    'levis': 'Clothing',
    'vanheusen': 'Clothing',
    'peterengland': 'Clothing',
    'allen solly': 'Clothing',
    'forever21': 'Clothing',
    'zara': 'Clothing',
    'hm': 'Clothing',
    'nike': 'Clothing',
    'adidas': 'Clothing',
    'puma': 'Clothing',
    'reebok': 'Clothing',
    'underarmour': 'Clothing',
    'crocs': 'Clothing',
    'uniqlo': 'Clothing',
    'bewakoof': 'Clothing',
    'campusshoes': 'Clothing',
    'campus': 'Clothing',
    'redtape': 'Clothing',
    'hrx': 'Clothing',

    // 🏥 Health
    'pharmeasy': 'Health',
    '1mg': 'Health',
    'apollo': 'Health',
    'netmeds': 'Health',
    'medlife': 'Health',
    'practo': 'Health',
    'mfine': 'Health',

    // 🎬 Entertainment
    'netflix': 'Entertainment',
    'hotstar': 'Entertainment',
    'primevideo': 'Entertainment',
    'zee5': 'Entertainment',
    'sonyliv': 'Entertainment',
    'bookmyshow': 'Entertainment',

    // ✈️ Travel
    'makemytrip': 'Travel',
    'goibibo': 'Travel',
    'yatra': 'Travel',
    'redbus': 'Travel',
    'indigo': 'Travel',
    'airindia': 'Travel',
    'vistara': 'Travel',
    'irctc': 'Travel',

    // 🎓 Education
    'byjus': 'Education',
    'unacademy': 'Education',
    'vedantu': 'Education',
    'toppr': 'Education',
    'coursera': 'Education',
    'udemy': 'Education',

    // 💳 Debt / Loans
    'cred': 'Debt/Loans',
    'paytmloan': 'Debt/Loans',
    'moneyview': 'Debt/Loans',
    'cashe': 'Debt/Loans',
    'nira': 'Debt/Loans',
    'krazybee': 'Debt/Loans',

    // 💰 Savings / Investments
    'zerodha': 'Savings/Investments',
    'groww': 'Savings/Investments',
    'upstox': 'Savings/Investments',
    'etmoney': 'Savings/Investments',
    'smallcase': 'Savings/Investments',
    'kuvera': 'Savings/Investments',

    // 🛡 Insurance
    'policybazaar': 'Insurance',
    'acko': 'Insurance',
    'digit': 'Insurance',
    'hdfclife': 'Insurance',
    'maxbupa': 'Insurance',
    'starhealth': 'Insurance',
    'tataaig': 'Insurance',

    // 🤝 Charity / Donations
    'giveindia': 'Charity/Donations',
    'ngo': 'Charity/Donations',
    'helpage': 'Charity/Donations',
    'crymail': 'Charity/Donations',

    // 🧽 Household
    'bigbasket': 'Household',
    'grofers': 'Household',
    'jiomart': 'Household',
    'amazon': 'Household',
    'flipkart': 'Household',
    'dunzo': 'Household',

    // 💼 Work-Related
    'zoho': 'Work-Related',
    'slack': 'Work-Related',
    'atlassian': 'Work-Related',
    'notion': 'Work-Related',
    'fiverr': 'Work-Related',
    'upwork': 'Work-Related',

    // 🐶 Pets
    'supertails': 'Pets',
    'headsupfortails': 'Pets',
    'petcrux': 'Pets',
    'wiggles': 'Pets',

    // 🔁 Subscriptions
    'spotify': 'Subscriptions/Memberships',
    'gaana': 'Subscriptions/Memberships',
    'wynk': 'Subscriptions/Memberships',
    'youtube': 'Subscriptions/Memberships',

    // 🧾 Taxes
    'incometax': 'Taxes',
    'gst': 'Taxes',
    'tds': 'Taxes',

    // 👶 Childcare
    'firstcry': 'Childcare',
    'hopscotch': 'Childcare',

    // 💵 Credit Categories
    'salary': 'Employment',
    'freelance': 'Side Hustles',
    'business': 'Business',
    'govt': 'Government Benefits',
    'pension': 'Retirement',
    'interest': 'Investments',
    'dividend': 'Investments',
    'gift': 'Gifts',
    'reward': 'Gifts',
  };

  static final Map<String, String> categoryIconMapping = {
    'Housing': '🏠',
    'Utilities': '🏠',
    'Transportation': '🚗',
    'Food': '🍔',
    'Personal Care': '💇',
    'Clothing': '👗',
    'Health': '🏥',
    'Entertainment': '🎬',
    'Travel': '✈️',
    'Education': '🎓',
    'Debt/Loans': '💳',
    'Savings/Investments': '💰',
    'Insurance': '🛡',
    'Charity/Donations': '🤝',
    'Household': '🧽',
    'Work-Related': '💼',
    'Pets': '🐶',
    'Subscriptions/Memberships': '🔁',
    'Taxes': '🧾',
    'Childcare': '👶',
    'Employment': '💵',
    'Side Hustles': '💵',
    'Business': '💵',
    'Government Benefits': '💵',
    'Retirement': '💵',
    'Investments': '💵',
    'Gifts': '💵',
  };
// Map of categories to their respective colors (in hex format)
  static final Map<String, String> categoryColorMapping = {
    'Housing': '#FFAB91', // Warm peach for home-related
    'Utilities': '#FFAB91', // Same as Housing for consistency
    'Transportation': '#4FC3F7', // Light blue for mobility
    'Food': '#FFCA28', // Yellow for food and dining
    'Personal Care': '#F06292', // Pink for beauty and care
    'Clothing': '#AB47BC', // Purple for fashion
    'Health': '#4CAF50', // Green for health and wellness
    'Entertainment': '#E91E63', // Vibrant pink for fun
    'Travel': '#26A69A', // Teal for travel and adventure
    'Education': '#5C6BC0', // Indigo for learning
    'Debt/Loans': '#EF5350', // Red for financial obligations
    'Savings/Investments': '#FFD700', // Gold for wealth
    'Insurance': '#78909C', // Blue-grey for security
    'Charity/Donations': '#8BC34A', // Light green for giving
    'Household': '#FF9800', // Orange for home essentials
    'Work-Related': '#546E7A', // Slate for professional expenses
    'Pets': '#8D6E63', // Brown for pet-related
    'Subscriptions/Memberships': '#7E57C2', // Deep purple for recurring
    'Taxes': '#B0BEC5', // Neutral grey for taxes
    'Childcare': '#F4A261', // Soft orange for family
    'Employment': '#4CAF50', // Green for income
    'Side Hustles': '#4CAF50', // Green for income
    'Business': '#4CAF50', // Green for income
    'Government Benefits': '#4CAF50', // Green for income
    'Retirement': '#4CAF50', // Green for income
    'Investments': '#4CAF50', // Green for income
    'Gifts': '#4CAF50', // Green for income
  };

  /// Returns a map containing the emoji icon and color for a given keyword or category.
  /// If the input is a keyword, it looks up the category and then the icon and color.
  /// If the input is a category, it directly returns the icon and color.
  /// Returns a default icon (❓) and color (#B0BEC5) if no match is found.
  static Map<String, String> getIconAndColor(String input) {
    String icon;
    String color;

    // Check if input is a keyword in upiKeywordCategoryMapping
    if (upiKeywordCategoryMapping.containsKey(input.toLowerCase())) {
      String category = upiKeywordCategoryMapping[input.toLowerCase()]!;
      icon = categoryIconMapping[category] ?? '❓';
      color = categoryColorMapping[category] ?? '#B0BEC5';
    }
    // Check if input is a category
    else if (categoryIconMapping.containsKey(input)) {
      icon = categoryIconMapping[input]!;
      color = categoryColorMapping[input] ?? '#B0BEC5';
    }
    // Default case for invalid input
    else {
      icon = '❓';
      color = '#B0BEC5'; // Default grey color
    }

    return {'icon': icon, 'color': color};
  }

  static Color parseHexColor(String hexColor) {
    // Remove the '#' if present
    String hex = hexColor.replaceFirst('#', '');
    // Parse the hex string to an integer, adding full opacity (FF) if not specified
    int colorInt = int.parse('FF$hex', radix: 16);
    return Color(colorInt);
  }
}
