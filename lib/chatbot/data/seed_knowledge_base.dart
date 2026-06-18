import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility to seed the Firestore `knowledge_base` collection with
/// comprehensive knowledge about Philippine government documents.
/// Run this once (e.g. from a debug button or a test) to populate
/// the knowledge base. Subsequent runs will add duplicates unless you
/// clear the collection first.
class KnowledgeBaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds the `knowledge_base` collection with all knowledge chunks.
  Future<void> seed() async {
    debugPrint('[INFO] KnowledgeBaseSeeder: Starting to seed knowledge base...');

    final chunks = _buildAllChunks();
    final batch = _firestore.batch();
    final collection = _firestore.collection('knowledge_base');

    for (final chunk in chunks) {
      final docRef = collection.doc(); // auto-ID
      batch.set(docRef, chunk);
    }

    await batch.commit();
    debugPrint('[INFO] KnowledgeBaseSeeder: Seeded ${chunks.length} knowledge chunks.');
  }

  /// Clears all existing knowledge base documents before re-seeding.
  Future<void> clearAndSeed() async {
    debugPrint('[INFO] KnowledgeBaseSeeder: Clearing existing knowledge base...');
    final snapshot = await _firestore.collection('knowledge_base').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    debugPrint('[INFO] KnowledgeBaseSeeder: Cleared ${snapshot.docs.length} documents.');
    await seed();
  }

  List<Map<String, String>> _buildAllChunks() {
    return [
      ..._passportChunks(),
      ..._birthCertChunks(),
      ..._driverLicenseChunks(),
      ..._nationalIDChunks(),
      ..._seniorCitizenChunks(),
      ..._pwdIDChunks(),
      ..._nbiClearanceChunks(),
      ..._philHealthIDChunks(),
      ..._postalIDChunks(),
      ..._policeClearanceChunks(),
      ..._umidChunks(),
      ..._voterIDChunks(),
    ];
  }

  List<Map<String, String>> _passportChunks() => [
    {
      'documentType': 'Passport',
      'title': 'Passport Overview',
      'content':
          'A Philippine passport is an official travel document issued by the Department of Foreign Affairs (DFA). '
          'It certifies the identity and nationality of the holder for international travel. '
          'Philippine passports are valid for 10 years for adults (18 and above) and 5 years for minors. '
          'All Filipino citizens are eligible to apply for a passport.',
      'category': 'overview',
    },
    {
      'documentType': 'Passport',
      'title': 'Passport Application Fees',
      'content':
          'Regular processing passport costs PHP 950.00 with 15-20 working days processing time. '
          'Rush processing costs PHP 1,200.00 with 10-12 working days. '
          'Express processing costs PHP 1,500.00 with 7 working days. '
          'Payment can be made via cash, credit/debit card, or GCash at DFA offices. '
          'For courtesy lane (senior citizens, PWDs, OFWs, solo parents), the regular fee of PHP 950.00 still applies but with priority processing.',
      'category': 'fees',
    },
    {
      'documentType': 'Passport',
      'title': 'Passport Application Steps',
      'content':
          'Step 1: Schedule an appointment online at the DFA website (passport.gov.ph). '
          'Step 2: Go to the DFA office on your scheduled date with all required documents. '
          'Step 3: Submit your application form and documents at the receiving counter. '
          'Step 4: Have your biometrics captured (photo, fingerprints, signature). '
          'Step 5: Pay the processing fee. '
          'Step 6: Receive your passport via courier delivery or pick up at the DFA office.',
      'category': 'steps',
    },
    {
      'documentType': 'Passport',
      'title': 'Passport Eligibility and Special Cases',
      'content':
          'All Filipino citizens can apply for a passport regardless of age. '
          'Minors (below 18) must be accompanied by a parent/guardian and must present additional documents such as birth certificate and parental consent. '
          'For renewal, the old passport must be presented. If lost, a police report and affidavit of loss are required. '
          'Dual citizens must present their Identification Certificate (IC) or Order of Approval from the Bureau of Immigration.',
      'category': 'eligibility',
    },
    {
      'documentType': 'Passport',
      'title': 'Passport Application Tips',
      'content':
          'Book your DFA appointment as early as possible — slots fill up fast, especially during peak travel seasons. '
          'Arrive at least 30 minutes before your scheduled time. '
          'Bring original documents plus at least 2 photocopies of each. '
          'Wear a collared shirt for the photo — the background will be white. '
          'Check the DFA website for the latest list of satellite offices and consular offices. '
          'If you are an OFW, you can avail of the courtesy lane for faster processing.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _birthCertChunks() => [
    {
      'documentType': 'BirthCert',
      'title': 'Birth Certificate Overview',
      'content':
          'A Philippine birth certificate (PSA-issued) is the official record of a person\'s birth. '
          'It is issued by the Philippine Statistics Authority (PSA), formerly the National Statistics Office (NSO). '
          'This document is a primary requirement for almost all government transactions including passport applications, school enrollment, and employment. '
          'It contains the full name, date and place of birth, and parents\' information of the individual.',
      'category': 'overview',
    },
    {
      'documentType': 'BirthCert',
      'title': 'Birth Certificate Fees',
      'content':
          'A PSA-issued birth certificate costs PHP 155.00 for a copy obtained at PSA outlets or Serbilis centers. '
          'Online requests via PSAHelpline.ph cost PHP 155.00 plus a delivery fee of PHP 150.00 (Metro Manila) or PHP 200.00 (provincial). '
          'Rush processing is available at PSA Serbilis centers for an additional fee. '
          'Processing time is typically 3-5 working days for walk-in requests and 5-8 working days for online orders.',
      'category': 'fees',
    },
    {
      'documentType': 'BirthCert',
      'title': 'Birth Certificate Application Steps',
      'content':
          'Step 1: Go to the nearest PSA Serbilis Center or visit PSAHelpline.ph for online requests. '
          'Step 2: Fill out the request form with complete details (full name, date of birth, place of birth, parents\' names). '
          'Step 3: Submit the form and pay the required fee. '
          'Step 4: Wait for the processing period. '
          'Step 5: Claim your birth certificate at the outlet or receive it via delivery. '
          'For late registration of birth, visit the local civil registrar first before requesting from PSA.',
      'category': 'steps',
    },
    {
      'documentType': 'BirthCert',
      'title': 'Birth Certificate Tips',
      'content':
          'Make sure the spelling of names and dates match across all your documents — any discrepancy may require a correction petition. '
          'If your birth was not registered, you need to file for late registration at your local civil registrar\'s office. '
          'Keep multiple authenticated copies of your birth certificate as it is required for many government transactions. '
          'You can also request copies through SM Serbilis centers located in select SM malls nationwide. '
          'For corrections in your birth certificate, you may need to file a petition under RA 9048 (clerical errors) or RA 10172 (gender/date of birth).',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _driverLicenseChunks() => [
    {
      'documentType': 'DriverLicense',
      'title': 'Driver\'s License Overview',
      'content':
          'A Philippine driver\'s license is issued by the Land Transportation Office (LTO). '
          'It is required for anyone who wants to legally operate a motor vehicle in the Philippines. '
          'There are several license types: Student Permit (valid 1 year), Non-Professional (5 years), Professional (5 years), and Conductor\'s License. '
          'The driver\'s license also serves as a valid government-issued ID for various transactions.',
      'category': 'overview',
    },
    {
      'documentType': 'DriverLicense',
      'title': 'Driver\'s License Fees',
      'content':
          'Student Permit application fee is PHP 292.63. '
          'Non-Professional driver\'s license (new) costs approximately PHP 585.00. '
          'Professional driver\'s license (new) costs approximately PHP 720.63. '
          'License renewal fees are slightly lower depending on the license type. '
          'Additional fees may apply for drug testing (PHP 300-500) and medical certificate (PHP 200-500) from accredited clinics. '
          'The LTO accepts cash, GCash, Maya, and credit/debit card payments at select branches.',
      'category': 'fees',
    },
    {
      'documentType': 'DriverLicense',
      'title': 'Driver\'s License Steps',
      'content':
          'For a new license: Step 1: Get a Student Permit first — visit any LTO branch with your requirements. '
          'Step 2: Hold the Student Permit for at least 1 month before applying for a Non-Professional license. '
          'Step 3: Complete the Comprehensive Driver\'s Education (CDE) course from an LTO-accredited driving school. '
          'Step 4: Schedule an appointment at the LTO PORTAL (portal.lto.gov.ph). '
          'Step 5: Visit the LTO branch, pass the written and practical driving exams. '
          'Step 6: Submit biometrics and pay the fee. '
          'Step 7: Receive your license card.',
      'category': 'steps',
    },
    {
      'documentType': 'DriverLicense',
      'title': 'Driver\'s License Tips',
      'content':
          'Always book your appointment online through the LTO PORTAL to avoid long queues. '
          'Get your medical certificate and drug test from LTO-accredited clinics only — the results are automatically sent to LTO electronically. '
          'For renewal, you can renew up to 6 months before your license expires without penalty. '
          'If your license has been expired for more than 2 years, you may need to retake the exams. '
          'Bring at least 2 valid IDs as backup when visiting the LTO. '
          'The LTO has an online portal for checking license status and violation records.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _nationalIDChunks() => [
    {
      'documentType': 'NationalID',
      'title': 'National ID (PhilSys) Overview',
      'content':
          'The Philippine Identification System (PhilSys) ID, commonly called the National ID, is a government-issued identification document under Republic Act No. 11055. '
          'It serves as a valid proof of identity for all transactions, both public and private. '
          'The Philippine Statistics Authority (PSA) is the implementing agency. '
          'Registration is free of charge for all Filipino citizens and resident aliens.',
      'category': 'overview',
    },
    {
      'documentType': 'NationalID',
      'title': 'National ID Registration Steps',
      'content':
          'Step 1: Visit the nearest PhilSys registration center or PSA office. Walk-in registration is available in many areas. '
          'Step 2: Fill out the PhilSys Registration Form with your personal information. '
          'Step 3: Present at least one supporting document (birth certificate, passport, or any government-issued ID). '
          'Step 4: Have your biometrics captured (photo, fingerprints, iris scan). '
          'Step 5: Receive your transaction slip with your PhilSys Number (PSN). '
          'Step 6: Wait for the delivery of your PhilSys ID card — delivery is free via Philippine Postal Corporation.',
      'category': 'steps',
    },
    {
      'documentType': 'NationalID',
      'title': 'National ID Fees and Processing',
      'content':
          'Registration for the National ID is completely FREE of charge. There are no fees for first-time registration. '
          'Delivery of the physical ID card is also free via PhilPost. '
          'Processing time for the physical card varies but typically takes 3-6 months after registration. '
          'In the meantime, you can use your ePhilID (digital version) or the printed Transaction Slip as a valid ID for transactions. '
          'Replacement of a lost or damaged card may incur a fee (typically PHP 100-200).',
      'category': 'fees',
    },
    {
      'documentType': 'NationalID',
      'title': 'National ID Tips',
      'content':
          'If you haven\'t received your physical PhilSys ID card yet, you can check the delivery status at philsys.gov.ph. '
          'Your ePhilID is equally valid as the physical card — you can present it on your phone. '
          'The National ID is accepted for all government and private transactions including banking, SIM registration, and employment. '
          'Make sure the details on your National ID match your other government documents to avoid issues. '
          'Children can also be registered but will need to update their biometrics at ages 5, 10, 15, and when they turn 18.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _seniorCitizenChunks() => [
    {
      'documentType': 'SeniorCitizen',
      'title': 'Senior Citizen ID Overview',
      'content':
          'The Senior Citizen ID is issued to Filipino citizens aged 60 years and above under Republic Act No. 9994 (Expanded Senior Citizens Act). '
          'It entitles the holder to a 20% discount and VAT exemption on medicine, medical services, transportation, restaurants, recreation, and more. '
          'The ID is issued by the Office of the Senior Citizens Affairs (OSCA) in the city or municipality where the senior citizen resides.',
      'category': 'overview',
    },
    {
      'documentType': 'SeniorCitizen',
      'title': 'Senior Citizen ID Benefits',
      'content':
          'Benefits include: 20% discount on medicines at all drugstores, 20% discount on medical and dental services, '
          '20% discount on public transport fares, 20% discount at restaurants and hotels, '
          'free flu and pneumococcal vaccinations at government health centers, '
          'exemption from individual income tax (if earning below the poverty threshold), '
          'priority lanes in all government and commercial establishments, '
          'and a monthly stipend of PHP 500 from DSWD for indigent senior citizens.',
      'category': 'eligibility',
    },
    {
      'documentType': 'SeniorCitizen',
      'title': 'Senior Citizen ID Application Steps',
      'content':
          'Step 1: Visit the OSCA office in your barangay or city/municipal hall. '
          'Step 2: Fill out the Senior Citizen Registration Form. '
          'Step 3: Submit the required documents (birth certificate or any valid government-issued ID, 2 recent 1x1 photos, proof of residence). '
          'Step 4: The OSCA office will process and issue your Senior Citizen ID. '
          'Processing is usually completed within the same day or within a few working days. '
          'The Senior Citizen ID is issued free of charge.',
      'category': 'steps',
    },
    {
      'documentType': 'SeniorCitizen',
      'title': 'Senior Citizen ID Tips',
      'content':
          'The Senior Citizen ID is free — do not pay any fixers or intermediaries. '
          'You can use the Senior Citizen ID as a valid government ID for other transactions. '
          'If you move to a new city or municipality, you need to transfer your OSCA registration. '
          'Always carry your Senior Citizen ID when making purchases to avail of the 20% discount. '
          'The Senior Citizen booklet/purchase record is also issued with your ID — use it to track your discounted purchases.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _pwdIDChunks() => [
    {
      'documentType': 'PwdID',
      'title': 'PWD ID Overview',
      'content':
          'The Person with Disability (PWD) ID is issued to Filipino citizens with physical, mental, or sensory disabilities under Republic Act No. 7277 (Magna Carta for Persons with Disabilities). '
          'It entitles the holder to a 20% discount and VAT exemption on certain goods and services. '
          'The ID is issued by the barangay or the city/municipal social welfare and development office (CSWDO/MSWDO) where the PWD resides.',
      'category': 'overview',
    },
    {
      'documentType': 'PwdID',
      'title': 'PWD ID Benefits and Eligibility',
      'content':
          'PWD ID holders are entitled to: 20% discount on medicines, 20% discount on medical and dental services, '
          '20% discount on transportation, 20% discount at restaurants, hotels, and recreational facilities, '
          'educational assistance and scholarship programs, tax exemptions on specific items, '
          'priority lanes in all establishments, and accessible features in public spaces. '
          'Eligibility: Any person with a Long-term physical, mental, intellectual, or sensory impairment that limits daily activities.',
      'category': 'eligibility',
    },
    {
      'documentType': 'PwdID',
      'title': 'PWD ID Application Steps',
      'content':
          'Step 1: Get a medical certificate or clinical assessment from a licensed physician confirming the disability. '
          'Step 2: Visit the Persons with Disability Affairs Office (PDAO) or CSWDO/MSWDO in your city/municipality. '
          'Step 3: Fill out the PWD Registration Form. '
          'Step 4: Submit the required documents (medical certificate, 1x1 ID photo, valid ID or birth certificate, barangay certificate of residency). '
          'Step 5: The office will process and issue your PWD ID, usually within the same day or a few working days. '
          'The PWD ID is issued free of charge.',
      'category': 'steps',
    },
    {
      'documentType': 'PwdID',
      'title': 'PWD ID Tips',
      'content':
          'The PWD ID is free — do not pay any fixers. '
          'The PWD ID needs to be renewed every 3 years with an updated medical certificate. '
          'PWD discounts can be combined with senior citizen discounts — but only the higher discount applies (not both). '
          'Some cities have online registration portals for PWD IDs — check your local government\'s website. '
          'Report any establishment that refuses to honor your PWD discount to the DTI or the PDAO.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _nbiClearanceChunks() => [
    {
      'documentType': 'NBIClearance',
      'title': 'NBI Clearance Overview',
      'content':
          'The NBI Clearance is a document issued by the National Bureau of Investigation certifying that the applicant has no pending criminal case or derogatory record. '
          'It is commonly required for employment, business permits, travel visa applications, firearm license applications, and other legal transactions. '
          'The clearance is valid for 1 year from the date of issue.',
      'category': 'overview',
    },
    {
      'documentType': 'NBIClearance',
      'title': 'NBI Clearance Fees',
      'content':
          'The NBI Clearance fee is PHP 155.00 for regular processing. '
          'An additional convenience fee of PHP 24.00 applies for online appointments. '
          'Payment for online appointments can be made through GCash, Maya, online banking, Bayad Center, and 7-Eleven. '
          'Walk-in applicants pay PHP 155.00 at the NBI office. '
          'Processing time: clearances are usually released on the same day if there are no "hits" (matching records). If there is a hit, additional verification takes 7-14 working days.',
      'category': 'fees',
    },
    {
      'documentType': 'NBIClearance',
      'title': 'NBI Clearance Application Steps',
      'content':
          'Step 1: Register and schedule an appointment online at clearance.nbi.gov.ph. '
          'Step 2: Pay the clearance fee through the available payment channels. '
          'Step 3: Go to the NBI branch on your scheduled date with your valid ID. '
          'Step 4: Present your reference number and valid ID at the entrance. '
          'Step 5: Proceed to the biometrics section (photo and fingerprint capture). '
          'Step 6: Wait for the results. If NO HIT, your clearance will be printed and released on the same day. '
          'If there is a HIT, you will be given a specific date to return for your clearance.',
      'category': 'steps',
    },
    {
      'documentType': 'NBIClearance',
      'title': 'NBI Clearance Tips',
      'content':
          'Book your appointment early — NBI slots fill up quickly, especially at the start of each month. '
          'Bring a valid government-issued ID with a photo (passport, driver\'s license, PhilSys ID, etc.). '
          'If you get a "hit," don\'t panic — it usually just means someone with a similar name has a record, and it can be cleared by verification. '
          'Some malls have NBI satellite offices with shorter queues. '
          'Multi-purpose NBI clearances (valid for all uses) are now available — you no longer need to specify the purpose. '
          'For renewals, you can use the same NBI online account.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _philHealthIDChunks() => [
    {
      'documentType': 'PhilHealthID',
      'title': 'PhilHealth ID Overview',
      'content':
          'The PhilHealth ID is issued by the Philippine Health Insurance Corporation (PhilHealth) to its members. '
          'PhilHealth is the national health insurance program that provides financial assistance for hospitalization, surgeries, and medical procedures. '
          'All employed, self-employed, and voluntary members can get a PhilHealth ID. '
          'Members of the informal economy and indigent families can also register through the Sponsored Program (4Ps, DSWD-listed).',
      'category': 'overview',
    },
    {
      'documentType': 'PhilHealthID',
      'title': 'PhilHealth Registration and Fees',
      'content':
          'PhilHealth registration is free. The PhilHealth ID card is also issued free of charge. '
          'Monthly contributions depend on your category: Employed members contribute 5% of monthly income (shared by employer and employee). '
          'Voluntary and self-employed members contribute based on a fixed schedule (minimum PHP 500/month). '
          'Indigent members and senior citizens are covered by the government — no personal contributions required. '
          'OFW contributions are based on a separate schedule set by PhilHealth.',
      'category': 'fees',
    },
    {
      'documentType': 'PhilHealthID',
      'title': 'PhilHealth Registration Steps',
      'content':
          'Step 1: Fill out the PhilHealth Member Registration Form (PMRF) — available online or at any PhilHealth office. '
          'Step 2: Prepare your valid ID and birth certificate. '
          'Step 3: Visit the nearest PhilHealth Local Health Insurance Office (LHIO) or submit online via the PhilHealth Member Portal. '
          'Step 4: Submit the form and required documents. '
          'Step 5: You will be assigned a PhilHealth Identification Number (PIN). '
          'Step 6: Your PhilHealth ID will be issued at the office or mailed to you.',
      'category': 'steps',
    },
    {
      'documentType': 'PhilHealthID',
      'title': 'PhilHealth Tips',
      'content':
          'You can now register and update your PhilHealth records online via the PhilHealth Member Portal (memberinquiry.philhealth.gov.ph). '
          'Keep your PhilHealth contributions updated to ensure coverage when hospitalized. '
          'PhilHealth covers a wide range of medical procedures — check the case rate list before your procedure to know what\'s covered. '
          'You can use your PhilHealth ID as a valid government ID. '
          'If you change employers, make sure your new employer continues your PhilHealth contributions under the same PIN.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _postalIDChunks() => [
    {
      'documentType': 'PostalID',
      'title': 'Postal ID Overview',
      'content':
          'The Postal ID is a government-issued identification card by the Philippine Postal Corporation (PhilPost/Post Office). '
          'It is one of the most accessible and affordable government IDs in the Philippines. '
          'The Postal ID is accepted as valid identification in most government and private sector transactions. '
          'It is available in two types: the regular card and the premium (improved security features) card.',
      'category': 'overview',
    },
    {
      'documentType': 'PostalID',
      'title': 'Postal ID Fees',
      'content':
          'The regular Postal ID costs PHP 504.00 (inclusive of delivery fee). '
          'The premium Postal ID costs PHP 654.00 (inclusive of delivery fee). '
          'Rush processing is available for an additional fee of approximately PHP 200.00. '
          'Online applications through the PHLPost eServices website may have different pricing. '
          'Payment can be made via cash at the post office, GCash, or online payment options.',
      'category': 'fees',
    },
    {
      'documentType': 'PostalID',
      'title': 'Postal ID Application Steps',
      'content':
          'Step 1: Go to the nearest Post Office or apply online at postcards.phlpost.gov.ph. '
          'Step 2: Fill out the Postal ID application form. '
          'Step 3: Submit the required documents (valid ID or birth certificate, 1x1 photo, proof of address like a utility bill). '
          'Step 4: Pay the required fee. '
          'Step 5: Have your photo and biometrics captured at the Post Office. '
          'Step 6: Your Postal ID will be delivered to your registered address within 15-30 working days.',
      'category': 'steps',
    },
    {
      'documentType': 'PostalID',
      'title': 'Postal ID Tips',
      'content':
          'The Postal ID is one of the easiest government IDs to obtain — requirements are minimal. '
          'You can apply online to skip the queue at the Post Office (only biometrics need to be done in person). '
          'Make sure to bring a utility bill or barangay clearance as proof of address. '
          'The Postal ID is widely accepted for bank account opening, passport application as supporting ID, and SIM registration. '
          'Keep the receipt/tracking number to check the delivery status of your ID.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _policeClearanceChunks() => [
    {
      'documentType': 'PoliceClearance',
      'title': 'Police Clearance Overview',
      'content':
          'A Police Clearance Certificate is issued by the Philippine National Police (PNP) certifying that the applicant has no pending criminal case or derogatory record in the police files. '
          'It is commonly required for employment applications, business permits, travel visa applications, and gun license applications. '
          'The clearance is issued at the police station with jurisdiction over the applicant\'s place of residence. '
          'It is valid for 6 months from the date of issue.',
      'category': 'overview',
    },
    {
      'documentType': 'PoliceClearance',
      'title': 'Police Clearance Fees',
      'content':
          'The Police Clearance fee is PHP 150.00 for local employment purposes. '
          'For travel/abroad purposes, the fee is PHP 200.00. '
          'Some police stations charge an additional PHP 50 for the clearance form. '
          'Payment is usually in cash at the police station. '
          'Processing time is typically same-day — you can get your clearance within 1-3 hours.',
      'category': 'fees',
    },
    {
      'documentType': 'PoliceClearance',
      'title': 'Police Clearance Steps',
      'content':
          'Step 1: Go to the police station that has jurisdiction over your area of residence. '
          'Step 2: Request and fill out the Police Clearance application form. '
          'Step 3: Present the required documents (valid ID, barangay clearance, 2 pcs 1x1 photo). '
          'Step 4: Pay the processing fee. '
          'Step 5: Have your photo and fingerprints taken. '
          'Step 6: Wait for the clearance to be processed and printed — usually within 1-3 hours on the same day.',
      'category': 'steps',
    },
    {
      'documentType': 'PoliceClearance',
      'title': 'Police Clearance Tips',
      'content':
          'Go early in the morning to avoid long lines — most police stations process clearances from 8 AM to 3 PM. '
          'Get a barangay clearance first, as it is a requirement for the Police Clearance. '
          'Some cities now offer online appointment scheduling for police clearance — check your local PNP station\'s social media page. '
          'The National Police Clearance System (NPCS) via the PNP website is now available for online applications in some areas. '
          'If you recently moved, you may need to get a clearance from both your old and new jurisdictions.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _umidChunks() => [
    {
      'documentType': 'UMID',
      'title': 'UMID Overview',
      'content':
          'The Unified Multi-Purpose ID (UMID) is a government-issued identification card that integrates the ID systems of SSS, GSIS, PhilHealth, and Pag-IBIG. '
          'It serves both as a valid government ID and as a card for accessing social security benefits. '
          'UMID is available to all active members of SSS (private sector) or GSIS (government employees). '
          'The UMID card contains the holder\'s biometric data and is considered one of the most secure Philippine government IDs.',
      'category': 'overview',
    },
    {
      'documentType': 'UMID',
      'title': 'UMID Application Steps',
      'content':
          'Step 1: Ensure you are a registered and active member of SSS or GSIS. '
          'Step 2: Visit the nearest SSS branch for SSS members or GSIS branch for GSIS members. '
          'Step 3: Request and fill out the UMID application form (or apply through the SSS website for appointment scheduling). '
          'Step 4: Submit the required documents (2 valid IDs, E-1/E-4 form for SSS, or Service Record for GSIS). '
          'Step 5: Have your biometrics captured (photo, fingerprints, signature). '
          'Step 6: Wait for the UMID card to be produced and delivered — typically 3-6 months.',
      'category': 'steps',
    },
    {
      'documentType': 'UMID',
      'title': 'UMID Fees and Processing',
      'content':
          'The UMID card is issued free of charge for first-time applicants. '
          'Replacement for lost or damaged cards costs PHP 200.00. '
          'There is no rush processing option — processing takes 3-6 months. '
          'You will receive an SMS notification when your card is ready for pickup. '
          'UMID cards are picked up at the SSS branch where you applied.',
      'category': 'fees',
    },
    {
      'documentType': 'UMID',
      'title': 'UMID Tips',
      'content':
          'Check if you are eligible by logging into your My.SSS or GSIS Member Online account first. '
          'Bring at least 2 valid IDs when visiting the SSS/GSIS branch — you need at least one primary ID. '
          'You can check the status of your UMID card through the SSS website or by calling the SSS hotline (1455). '
          'The UMID card can also be used for ATM withdrawals of SSS benefits if you link it to your bank account. '
          'Make sure to update your SSS records (address, civil status) before applying for the UMID.',
      'category': 'tips',
    },
  ];

  List<Map<String, String>> _voterIDChunks() => [
    {
      'documentType': 'VoterID',
      'title': 'Voter\'s ID Overview',
      'content':
          'The Voter\'s ID (or Voter\'s Identification Card) is issued by the Commission on Elections (COMELEC) to registered Filipino voters. '
          'It serves as proof of voter registration and as a valid government-issued ID. '
          'Registration is open to all Filipino citizens aged 15 and above (but must be at least 18 on Election Day to vote). '
          'COMELEC has been issuing the new biometric Voter\'s ID with enhanced security features.',
      'category': 'overview',
    },
    {
      'documentType': 'VoterID',
      'title': 'Voter Registration and ID Steps',
      'content':
          'Step 1: Visit your local COMELEC office during the voter registration period (usually opens several months before an election). '
          'Step 2: Fill out the Voter Registration Form (VRF). '
          'Step 3: Present a valid ID or any supporting document that proves your identity and residence. '
          'Step 4: Have your biometrics captured (photo, fingerprints, signature). '
          'Step 5: Your application will be processed and added to the voter\'s list. '
          'Step 6: Once approved, you can claim your Voter\'s ID at the COMELEC office. '
          'You can also register online through the COMELEC iRehistro system for pre-registration.',
      'category': 'steps',
    },
    {
      'documentType': 'VoterID',
      'title': 'Voter Registration Details',
      'content':
          'Voter registration is completely free of charge. The Voter\'s ID is also issued for free. '
          'Registration periods are set by COMELEC and are typically suspended a few months before each election. '
          'Make sure to register at the COMELEC office that has jurisdiction over your place of residence. '
          'If you have moved, you need to file for a Transfer of Registration at your new COMELEC office. '
          'Deactivated voters (those who failed to vote in two consecutive elections) can reactivate by filing a reactivation form.',
      'category': 'fees',
    },
    {
      'documentType': 'VoterID',
      'title': 'Voter ID Tips',
      'content':
          'Register as early as possible during the voter registration period — lines get extremely long near the deadline. '
          'Bring a valid ID and proof of address when registering. '
          'Check your registration status at the COMELEC website\'s Precinct Finder before every election. '
          'If you haven\'t received your biometric Voter\'s ID yet, you can still vote using the voter\'s list — the ID is not required to vote. '
          'Report any issues with your voter registration to COMELEC immediately — corrections must be filed before the election period.',
      'category': 'tips',
    },
  ];
}
