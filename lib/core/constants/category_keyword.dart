import 'dart:ui';

class CategoryKeyWord {
  // A map that associates a keyword with its category.
  static final Map<String, String> upiKeywordCategoryMapping = {
    // 🚗 Transportation
    'uber': 'Transportation',
    'ola': 'Transportation',
    'rapido': 'Transportation',
    'meru': 'Transportation',
    'blusmart': 'Transportation',
    'maruti': 'Transportation',
    'hyundai': 'Transportation',
    'tataMotors': 'Transportation',
    'petrol': 'Transportation',
    'diesel': 'Transportation',
    'fuel': 'Transportation',
    'cng': 'Transportation',
    'metro': 'Transportation',
    'toll': 'Transportation',
    'parking': 'Transportation',
    'bpcl': 'Transportation',
    'hpcl': 'Transportation',
    'indianoil': 'Transportation',
    'ioc': 'Transportation',

    // 🍔 Food
    'zomato': 'Food',
    'swiggy': 'Food',
    'dominos': 'Food',
    'mcdonalds': 'Food',
    'faasos': 'Food',
    'freshmenu': 'Food',
    'eatsure': 'Food',
    'pizza': 'Food',
    'amul': 'Food',
    'parle': 'Food',
    'parle-g': 'Food',
    'haldirams': 'Food',
    'nestle': 'Food',
    'mccain': 'Food',
    'mdh': 'Food',
    'tatafoods': 'Food',
    'maggi': 'Food',
    'kellogg': 'Food',
    'britannia': 'Food',
    'starbucks': 'Food',
    'subway': 'Food',
    'kfc': 'Food',
    'cafe': 'Food',
    'restaurant': 'Food',
    'dining': 'Food',
    'eatery': 'Food',
    'barbeque': 'Food',

    // 💇 Personal Care
    'nykaa': 'Personal Care',
    'purplle': 'Personal Care',
    'myglamm': 'Personal Care',
    'sugarcosmetics': 'Personal Care',
    'mamaearth': 'Personal Care',
    'wow': 'Personal Care',
    'lakme': 'Personal Care',
    'loreal': 'Personal Care',
    'nivea': 'Personal Care',
    'biotique': 'Personal Care',
    'patelcosmetics': 'Personal Care',
    'salon': 'Personal Care',
    'spa': 'Personal Care',
    'beauty': 'Personal Care',
    'parlour': 'Personal Care',

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
    'tommyhilfiger': 'Clothing',
    'max': 'Clothing',
    'wildcraft': 'Clothing',
    'louisphilippe': 'Clothing',

    // 🏥 Health
    'pharmeasy': 'Health',
    '1mg': 'Health',
    'apollo': 'Health',
    'netmeds': 'Health',
    'medlife': 'Health',
    'practo': 'Health',
    'mfine': 'Health',
    'cultfit': 'Health',
    'fitternity': 'Health',
    'pharmEasy': 'Health',
    'hospital': 'Health',
    'clinic': 'Health',
    'doctor': 'Health',
    'pharmacy': 'Health',
    'labs': 'Health',
    'diagnostic': 'Health',

    // 🎬 Entertainment
    'netflix': 'Entertainment',
    'hotstar': 'Entertainment',
    'primevideo': 'Entertainment',
    'zee5': 'Entertainment',
    'sonyliv': 'Entertainment',
    'bookmyshow': 'Entertainment',
    'disneyplus': 'Entertainment',

    // ✈️ Travel
    'makemytrip': 'Travel',
    'goibibo': 'Travel',
    'yatra': 'Travel',
    'redbus': 'Travel',
    'indigo': 'Travel',
    'airindia': 'Travel',
    'vistara': 'Travel',
    'irctc': 'Travel',
    'spicejet': 'Travel',
    'goair': 'Travel',
    'vistarajet': 'Travel',
    'railway': 'Travel',

    // 🎓 Education
    'byjus': 'Education',
    'unacademy': 'Education',
    'vedantu': 'Education',
    'toppr': 'Education',
    'coursera': 'Education',
    'udemy': 'Education',
    'upgrad': 'Education',
    'simplilearn': 'Education',

    // 💳 Debt / Loans
    'cred': 'Debt/Loans',
    'paytmloan': 'Debt/Loans',
    'moneyview': 'Debt/Loans',
    'cashe': 'Debt/Loans',
    'nira': 'Debt/Loans',
    'krazybee': 'Debt/Loans',

    // 🤝 Charity / Donations
    'giveindia': 'Charity/Donations',
    'ngo': 'Charity/Donations',
    'helpage': 'Charity/Donations',
    'crymail': 'Charity/Donations',

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

    // 💵 Credit Categories
    'salary': 'Employment',
    'freelance': 'Side Hustles',
    'business': 'Business',
    'govt': 'Government Benefits',
    'pension': 'Retirement',
    'gift': 'Gifts',
    'reward': 'Gifts',

    // FMCG & Household
    'hindustanunilever': 'Household',
    'dabur': 'Household',
    'godrej': 'Household',
    'itc': 'Household',
    'patanjali': 'Household',
    'croma': 'Household',
    'relianceRetail': 'Household',
    'viveks': 'Household',
    'dell': 'Household',
    'blinkit': 'Household',
    'hp': 'Household',
    'lenovo': 'Household',
    'samsung': 'Household',
    'apple': 'Household',
    'oneplus': 'Household',
    'supermarket': 'Household',
    'mart': 'Household',
    'kirana': 'Household',
    'grocery': 'Household',
    'pepperfry': 'Household',
    'urbanladder': 'Household',
    'bigbasket': 'Household',
    'grofers': 'Household',
    'jiomart': 'Household',
    'dmart': 'Household',
    'amazon': 'Household',
    'flipkart': 'Household',
    'dunzo': 'Household',

    'applemusic': 'Subscriptions/Memberships',

    // Side Hustle / Freelance
    'uberdriver': 'Side Hustles',
    'oladriver': 'Side Hustles',

    // 💼 Work-Related
    'cowork': 'Work-Related',
    'workspace': 'Work-Related',

    'firstcry': 'Childcare',
    'hopscotch': 'Childcare',
    'toys': 'Childcare',
    'daycare': 'Childcare',
    'schoolfees': 'Childcare',
    'playgroup': 'Childcare',

    // 🏠 Housing / Utilities
    'tatapower': 'Utilities',
    'besscom': 'Utilities',
    'mseb': 'Utilities',
    'adani': 'Utilities',
    'torrentpower': 'Utilities',
    'ioenergy': 'Utilities',
    'bsesouth': 'Utilities',
    'tneb': 'Utilities',
    'bescom': 'Utilities',
    'gilp': 'Utilities',
    'dgvcl': 'Utilities',
    'jio': 'Utilities',
    'airtel': 'Utilities',
    'vi': 'Utilities',
    'bsnl': 'Utilities',
    'billdesk': 'Utilities',
    'electricity': 'Utilities',
    'waterbill': 'Utilities',
    'gas': 'Utilities',
    'maintenance': 'Housing',
    'rent': 'Housing',
    'nobroker': 'Housing',
    'mygate': 'Housing',

    // Finance / Payments
    'phonepe': 'Savings/Investments',
    'googlepay': 'Savings/Investments',
    'razorpay': 'Savings/Investments',
    // 'payu': 'Savings/Investments',
    'zerodha': 'Savings/Investments',
    'groww': 'Savings/Investments',
    'upstox': 'Savings/Investments',
    'etmoney': 'Savings/Investments',
    'smallcase': 'Savings/Investments',
    'kuvera': 'Savings/Investments',
    'angelbroking': 'Savings/Investments',
    '5paisa': 'Savings/Investments',
    'interest': 'Investments',
    'dividend': 'Investments',

    'policybazaar': 'Insurance',
    'acko': 'Insurance',
    'digit': 'Insurance',
    'hdfclife': 'Insurance',
    'maxbupa': 'Insurance',
    'starhealth': 'Insurance',
    'tataaig': 'Insurance',
    'bajajallianz': 'Insurance',
    'sbiinsurance': 'Insurance',
    'icinsurance': 'Insurance',

    // Donations / Charity
    'gatesfoundation': 'Charity/Donations',
    'givewell': 'Charity/Donations',

    // Gifts / Misc
    'amazonpay': 'Gifts',
    'giftcards': 'Gifts',
  };

  // A map that associates each category with a corresponding emoji icon.
  static final Map<String, String> categoryIconMapping = {
    // Essentials
    'Housing': '🏠',
    'Utilities': '💡',
    'Transportation': '🚗',
    'Food': '🍔',
    'Groceries': '🛒',
    'Personal Care': '💇',
    'Clothing': '👗',
    'Health': '🏥',
    'Pharmacy/Medicine': '💊',
    'Household': '🧽',

    // Lifestyle & Leisure
    'Entertainment': '🎬',
    'Travel': '✈️',
    'Dining Out': '🍽️',
    'Sports/Fitness': '🏋️',
    'Hobbies': '🎨',
    'Pets': '🐶',
    'Subscriptions/Memberships': '🔁',

    // Education & Growth
    'Education': '🎓',
    'Books': '📚',
    'Courses/Training': '🖥️',

    // Financial
    'Debt/Loans': '💳',
    'Savings/Investments': '💰',
    'Retirement': '🪙',
    'Taxes': '🧾',
    'Insurance': '🛡',
    'Charity/Donations': '🤝',

    // Income Sources
    'Employment': '💼',
    'Side Hustles': '🚀',
    'Business': '🏢',
    'Government Benefits': '🏛️',
    'Freelancing': '🖊️',
    'Investments Income': '📈',

    // Family & Relations
    'Childcare': '👶',
    'Elderly Care': '🧓',
    'Gifts': '🎁',
    'Events/Celebrations': '🎉',

    // Miscellaneous
    'Technology/Gadgets': '📱',
    'Repairs/Maintenance': '🛠️',
    'Legal': '⚖️',
    'Emergency': '🚨',
    'Miscellaneous': '❓',
  };

  // A map that associates each category with a color in hex format.
  static final Map<String, String> categoryColorMapping = {
    // Essentials
    'Housing': '#FFAB91', // Warm peach
    'Utilities': '#FF7043', // Burnt orange
    'Transportation': '#4FC3F7', // Light blue
    'Food': '#FFCA28', // Bright yellow
    'Groceries': '#9CCC65', // Fresh green
    'Personal Care': '#F06292', // Pink
    'Clothing': '#AB47BC', // Purple
    'Health': '#2E7D32', // Dark green
    'Pharmacy/Medicine': '#81C784', // Soft green
    'Household': '#FF9800', // Orange

    // Lifestyle & Leisure
    'Entertainment': '#E91E63', // Vibrant pink
    'Travel': '#26A69A', // Teal
    'Dining Out': '#FFA726', // Orange-gold
    'Sports/Fitness': '#1E88E5', // Strong blue
    'Hobbies': '#BA68C8', // Lavender
    'Pets': '#8D6E63', // Brown
    'Subscriptions/Memberships': '#7E57C2', // Deep purple

    // Education & Growth
    'Education': '#5C6BC0', // Indigo
    'Books': '#FFB74D', // Amber
    'Courses/Training': '#00ACC1', // Cyan

    // Financial
    'Debt/Loans': '#EF5350', // Red
    'Savings/Investments': '#FFD700', // Gold
    'Retirement': '#C0CA33', // Olive green
    'Taxes': '#B0BEC5', // Grey
    'Insurance': '#78909C', // Blue-grey
    'Charity/Donations': '#8BC34A', // Light green

    // Income Sources
    'Employment': '#4DD0E1', // Aqua
    'Side Hustles': '#FF7043', // Coral orange
    'Business': '#6D4C41', // Deep brown
    'Government Benefits': '#009688', // Strong teal
    'Freelancing': '#9575CD', // Light violet
    'Investments Income': '#43A047', // Forest green

    // Family & Relations
    'Childcare': '#F4A261', // Soft orange
    'Elderly Care': '#A1887F', // Warm taupe
    'Gifts': '#F06292', // Rose pink
    'Events/Celebrations': '#FF4081', // Hot pink

    // Miscellaneous
    'Technology/Gadgets': '#3949AB', // Indigo blue
    'Repairs/Maintenance': '#D84315', // Brick red
    'Legal': '#455A64', // Slate grey
    'Emergency': '#D32F2F', // Bold red
    'Miscellaneous': '#9E9E9E', // Neutral grey
  };

  /// Returns a map containing the emoji icon and color for a given keyword or category.
  ///
  /// If the input is a keyword, it looks up the category and then the icon and color.
  /// If the input is a category, it directly returns the icon and color.
  /// Returns a default icon (❓) and color (#B0BEC5) if no match is found.
  static Map<String, String> getIconAndColor(String input) {
    String icon;
    String color;

    // Check if input is a keyword in upiKeywordCategoryMapping
    if (upiKeywordCategoryMapping.containsKey(input.toLowerCase())) {
      final category = upiKeywordCategoryMapping[input.toLowerCase()]!;
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

  // Parses a hex color string (e.g., '#RRGGBB') into a Flutter Color object.
  static Color parseHexColor(String hexColor) {
    // Remove the '#' if present
    final hex = hexColor.replaceFirst('#', '');
    // Parse the hex string to an integer, adding full opacity (FF) if not specified
    final colorInt = int.parse('FF$hex', radix: 16);
    return Color(colorInt);
  }
}
