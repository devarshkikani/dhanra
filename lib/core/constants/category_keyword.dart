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
    'Dmart': 'Household',
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

    // Utilities / Housing
    'bsesouth': 'Utilities',
    'tneb': 'Utilities',
    'bescom': 'Utilities',
    'gilp': 'Utilities',
    'dgvcl': 'Utilities',

    // Food & Groceries
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

    // FMCG & Household
    'hul': 'Household',
    'hindustanunilever': 'Household',
    'dabur': 'Household',
    'godrej': 'Household',
    'itc': 'Household',
    'patanjali': 'Household',

    // Personal Care / Beauty
    'lakme': 'Personal Care',
    'loreal': 'Personal Care',
    'nivea': 'Personal Care',
    'biotique': 'Personal Care',
    'patelcosmetics': 'Personal Care',

    // Clothing & Fashion
    'tommyhilfiger': 'Clothing',
    'max': 'Clothing',
    'wildcraft': 'Clothing',
    'louisphilippe': 'Clothing',

    // Electronics / Tech
    'croma': 'Household',
    'relianceRetail': 'Household',
    'viveks': 'Household',
    'dell': 'Household',
    'hp': 'Household',
    'lenovo': 'Household',
    'samsung': 'Household',
    'apple': 'Household',
    'oneplus': 'Household',

    // Telecom / Internet
    'jio': 'Utilities',
    'airtel': 'Utilities',
    'vi': 'Utilities',
    'bsnl': 'Utilities',

    // Travel & Transport
    'spicejet': 'Travel',
    'goair': 'Travel',
    'vistarajet': 'Travel',

    // Entertainment / Streaming
    'disneyplus': 'Entertainment',
    'applemusic': 'Subscriptions/Memberships',

    // Education / Learning
    'upGrad': 'Education',
    'simplilearn': 'Education',

    // Finance / Payments
    'phonepe': 'Savings/Investments',
    'googlepay': 'Savings/Investments',
    'razorpay': 'Savings/Investments',
    'payu': 'Savings/Investments',
    'billdesk': 'Utilities',

    // Investments / Stock Trading
    'angelbroking': 'Savings/Investments',
    '5paisa': 'Savings/Investments',

    // Insurance
    'bajajallianz': 'Insurance',
    'sbiinsurance': 'Insurance',
    'icinsurance': 'Insurance',

    // Donations / Charity
    'gatesfoundation': 'Charity/Donations',
    'givewell': 'Charity/Donations',

    // Health / Fitness
    'cultfit': 'Health',
    'fitternity': 'Health',
    'pharmEasy': 'Health',

    // Dining & Food Outlets
    'starbucks': 'Food',
    'subway': 'Food',
    'kfc': 'Food',

    // Household & DIY
    'pepperfry': 'Household',
    'urbanladder': 'Household',

    // Automotive
    'maruti': 'Transportation',
    'hyundai': 'Transportation',
    'tataMotors': 'Transportation',

    // Gifts / Misc
    'amazonpay': 'Gifts',
    'giftcards': 'Gifts',

    // Side Hustle / Freelance
    'uberdriver': 'Side Hustles',
    'olaDriver': 'Side Hustles',

    // 🏠 Housing / Utilities
    'maintenance': 'Housing',
    'electricity': 'Utilities',
    'waterbill': 'Utilities',
    'gas': 'Utilities',

    // 🚗 Transportation
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
    'cafe': 'Food',
    'restaurant': 'Food',
    'dining': 'Food',
    'eatery': 'Food',
    'barbeque': 'Food',

    // 💇 Personal Care
    'salon': 'Personal Care',
    'spa': 'Personal Care',
    'beauty': 'Personal Care',
    'parlour': 'Personal Care',

    // 🏥 Health
    'hospital': 'Health',
    'clinic': 'Health',
    'doctor': 'Health',
    'pharmacy': 'Health',
    'labs': 'Health',
    'diagnostic': 'Health',

    // 🧽 Household
    'dmart': 'Household',
    'supermarket': 'Household',
    'mart': 'Household',
    'kirana': 'Household',
    'grocery': 'Household',

    // 💼 Work-Related
    'cowork': 'Work-Related',
    'workspace': 'Work-Related',

    // 👶 Childcare
    'toys': 'Childcare',
    'daycare': 'Childcare',
    'schoolfees': 'Childcare',
    'playgroup': 'Childcare',
  };

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
// Map of categories to their respective colors (in hex format)
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
