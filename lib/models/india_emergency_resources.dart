class IndiaEmergencyResource {
  final String id;
  final String name;
  final String phoneNumber;
  final String description;
  final String category;

  const IndiaEmergencyResource({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.category,
  });
}

class IndiaGovernmentPortal {
  final String id;
  final String name;
  final String url;
  final String description;
  final String caseType;
  final String state;

  const IndiaGovernmentPortal({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.caseType,
    required this.state,
  });
}

class OnlineFraudGuide {
  final String id;
  final String type;
  final String title;
  final String description;
  final List<String> steps;
  final String reportingUrl;
  final String phoneNumber;

  const OnlineFraudGuide({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.steps,
    required this.reportingUrl,
    required this.phoneNumber,
  });
}

// Emergency resources specific to India
class IndiaEmergencies {
  static const List<IndiaEmergencyResource> resources = [
    IndiaEmergencyResource(
      id: '1',
      name: 'Police Emergency',
      phoneNumber: '100',
      description: 'Emergency police response for any criminal threat, assault, or danger',
      category: 'Police',
    ),
    IndiaEmergencyResource(
      id: '2',
      name: 'Women Helpline',
      phoneNumber: '1091',
      description: 'National Women Helpline - 24/7 support for women in distress',
      category: 'Women Safety',
    ),
    IndiaEmergencyResource(
      id: '3',
      name: 'Ambulance/Medical',
      phoneNumber: '102',
      description: 'Emergency medical ambulance and healthcare',
      category: 'Medical',
    ),
    IndiaEmergencyResource(
      id: '4',
      name: 'Fire Department',
      phoneNumber: '101',
      description: 'Fire emergency and rescue services',
      category: 'Fire Safety',
    ),
    IndiaEmergencyResource(
      id: '5',
      name: 'Disaster Management',
      phoneNumber: '1070',
      description: 'National Disaster Management Authority helpline',
      category: 'Disaster',
    ),
    IndiaEmergencyResource(
      id: '6',
      name: 'Toll Free Cyber Crime',
      phoneNumber: '1930',
      description: 'Cyber crime and online fraud reporting - toll free',
      category: 'Cyber Crime',
    ),
    IndiaEmergencyResource(
      id: '7',
      name: 'Child Abuse',
      phoneNumber: '1098',
      description: 'Childline India - 24/7 support for children in crisis',
      category: 'Child Safety',
    ),
    IndiaEmergencyResource(
      id: '8',
      name: 'Senior Citizen',
      phoneNumber: '1090',
      description: 'Elder abuse and senior citizen helpline',
      category: 'Senior Care',
    ),
  ];

  static const List<OnlineFraudGuide> fraudGuides = [
    OnlineFraudGuide(
      id: '1',
      type: 'romance_scam',
      title: 'Romance Scam / Online Dating Fraud',
      description:
          'When someone poses as a romantic interest to trick you into sending money or personal information',
      steps: [
        '1. STOP all contact immediately',
        '2. Do NOT send any more money',
        '3. Screenshot all conversations',
        '4. Document transaction details (date, time, amount, method)',
        '5. Report to the dating platform',
        '6. File FIR at nearest police station',
        '7. Report to Cyber Crime portal',
        '8. Inform your bank to reverse transactions',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '2',
      type: 'job_scam',
      title: 'Fake Job Offer / Employment Scam',
      description:
          'When fake job offers are used to extract money or personal details. Usually asking upfront payment for training, documents, or fees.',
      steps: [
        '1. Do NOT pay any upfront fees',
        '2. Verify company through official website',
        '3. Screenshot all job offer communications',
        '4. Check company phone number from official site',
        '5. Report to job portal where you saw the ad',
        '6. File complaint with Cyber Crime',
        '7. Alert your bank if money was transferred',
        '8. Warn others about the job posting',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '3',
      type: 'investment_scam',
      title: 'Fake Investment / Financial Scheme',
      description:
          'Promises of guaranteed returns, unrealistic profits, or exclusive investment opportunities online',
      steps: [
        '1. Check if the company is registered with SEBI',
        '2. Verify through RBI or financial regulator',
        '3. Screenshot all scheme details and messages',
        '4. Document all transactions and amounts',
        '5. DO NOT send more money',
        '6. Report to SEBI Complaint Portal',
        '7. File FIR with local police',
        '8. Inform your bank immediately',
      ],
      reportingUrl: 'https://scores.sebi.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '4',
      type: 'banking_phishing',
      title: 'Banking/Phishing Fraud',
      description:
          'Fake bank websites, phishing links, or calls claiming to be from your bank asking for credentials',
      steps: [
        '1. NEVER click links in suspicious emails/SMS',
        '2. Go directly to bank website (type URL yourself)',
        '3. Call your bank on official number (back of card)',
        '4. Screenshot the phishing attempt',
        '5. Report to RBI Cyber Crime Cell',
        '6. Register complaint with your bank immediately',
        '7. Change all passwords from safe device',
        '8. Monitor account for fraudulent transactions',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '5',
      type: 'seller_scam',
      title: 'Online Purchase Fraud / Seller Scam',
      description:
          'Fake sellers, non-delivery, counterfeit products, or payment fraud on e-commerce platforms',
      steps: [
        '1. Report immediately to the e-commerce platform',
        '2. Use platform\'s dispute resolution process',
        '3. Screenshot all product details and messages',
        '4. Document transaction and payment proof',
        '5. Request refund through platform escrow',
        '6. File complaint if platform doesn\'t help',
        '7. Report to Cyber Crime if amount is large',
        '8. File consumer complaint if needed',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '6',
      type: 'loan_scam',
      title: 'Instant Loan / Loan Scam',
      description:
          'Fake instant loan apps or websites charging upfront fees, asking for personal data, or predatory terms',
      steps: [
        '1. DO NOT download suspicious loan apps',
        '2. Verify lender is RBI registered',
        '3. Legitimate loans do NOT charge upfront fees',
        '4. Screenshot the fraudulent app/website',
        '5. Uninstall the suspicious app immediately',
        '6. Report to app store (Google Play, Apple)',
        '7. File cyber crime complaint with screenshots',
        '8. Check if your data was compromised',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
    OnlineFraudGuide(
      id: '7',
      type: 'sextortion',
      title: 'Sextortion / Blackmail (Sexual Content)',
      description:
          'When criminals extort money by threatening to share intimate photos or videos',
      steps: [
        '1. DO NOT pay any ransom (won\'t stop blackmailer)',
        '2. Block the person immediately everywhere',
        '3. DO NOT engage or respond further',
        '4. Screenshot threats and evidence',
        '5. Report to platform where contact happened',
        '6. File FIR at police station (cyber crime unit)',
        '7. Report to NCMEC CyberTipline if international',
        '8. Seek counseling support if emotionally distressed',
      ],
      reportingUrl: 'https://cybercrime.gov.in',
      phoneNumber: '1930',
    ),
  ];

  static const List<IndiaGovernmentPortal> governmentPortals = [
    IndiaGovernmentPortal(
      id: '1',
      name: 'Cyber Crime Reporting Portal',
      url: 'https://cybercrime.gov.in',
      description: 'Official portal for reporting all cyber crimes and online fraud in India',
      caseType: 'Cyber Crime, Online Fraud, Phishing, Scams',
      state: 'All India',
    ),
    IndiaGovernmentPortal(
      id: '2',
      name: 'National Crime Records Bureau (NCRB)',
      url: 'https://ncrb.gov.in',
      description: 'Official crime statistics and FIR filing information',
      caseType: 'Crime Records, FIR Status, Complaint Filing',
      state: 'All India',
    ),
    IndiaGovernmentPortal(
      id: '3',
      name: 'SEBI Complaints Portal',
      url: 'https://scores.sebi.gov.in',
      description: 'Report financial fraud, investment scams, and securities violations',
      caseType: 'Investment Fraud, Securities Violations, Ponzi Schemes',
      state: 'All India',
    ),
    IndiaGovernmentPortal(
      id: '4',
      name: 'RBI Consumer Complaints',
      url: 'https://www.rbi.org.in/commonperson/English/Scripts/complaints.aspx',
      description: 'Report banking fraud, loan scams, and financial misconduct',
      caseType: 'Banking Fraud, Loan Scams, ATM Issues',
      state: 'All India',
    ),
    IndiaGovernmentPortal(
      id: '5',
      name: 'Consumer Online Disputes',
      url: 'https://nclat.nic.in',
      description: 'Online consumer dispute resolution for faulty products/services',
      caseType: 'Product Defects, Service Issues, Consumer Rights',
      state: 'All India',
    ),
    IndiaGovernmentPortal(
      id: '6',
      name: 'Delhi Police Cyber Crime',
      url: 'https://www.delhipolice.gov.in',
      description: 'Delhi Police cyber crime unit for local complaints',
      caseType: 'All Cyber Crimes (Delhi)',
      state: 'Delhi',
    ),
    IndiaGovernmentPortal(
      id: '7',
      name: 'Women Safety Portal (Delhi)',
      url: 'https://www.delhipolice.gov.in/womensafety',
      description: 'Women-specific safety resources and complaint filing',
      caseType: 'Harassment, Assault, Stalking',
      state: 'Delhi',
    ),
  ];
}
