import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PatientFormApp(),
    ),
  );
}

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
  }

  ThemeData getTheme() {
    if (themeMode == ThemeMode.dark) {
      return ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF007DC5),
          secondary: Color(0xFFFF6F00),
        ),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF004080)),
      );
    } else {
      return ThemeData(
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          primary: Color(0xFF005DA3),
          secondary: Color(0xFF007DC5),
        ),
        scaffoldBackgroundColor: Color(0xFFE3F2FD),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF005DA3)),
      );
    }
  }
}

// Entry Widget
class PatientFormApp extends StatelessWidget {
  const PatientFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getTheme(),
      home: const PatientDetailsScreen(),
    );
  }
}

// Custom AppBar with Theme Switch
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AppBar(
      title: Text(title),
      actions: [
        Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (_) => themeProvider.toggleTheme(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient data
  String patientName = '';
  String patientAge = '';
  String patientGender = '';
  String patientAddress = '';
  String patientMobile = '';
  String patientEmail = '';
  DateTime? patientDOB;
  String? patientID;

  @override
  void initState() {
    super.initState();
    patientID =
        'PT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          patientDOB ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        patientDOB = picked;
        final today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month ||
            (today.month == picked.month && today.day < picked.day)) {
          age--;
        }
        patientAge = age.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Patient Registration'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_pin,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Patient ID: $patientID',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Personal Information',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Full Name*', prefixIcon: Icon(Icons.person)),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter patient name'
                      : null,
                  onChanged: (value) => setState(() => patientName = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth*',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: patientDOB != null
                                  ? DateFormat('dd/MM/yyyy').format(patientDOB!)
                                  : '',
                            ),
                            validator: (_) =>
                                patientDOB == null ? 'Required' : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Age (years)*',
                            prefixIcon: Icon(Icons.timeline)),
                        controller: TextEditingController(text: patientAge),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        onChanged: (value) =>
                            setState(() => patientAge = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Gender*', prefixIcon: Icon(Icons.people)),
                  value: patientGender.isEmpty ? null : patientGender,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select gender'
                      : null,
                  onChanged: (value) => setState(() => patientGender = value!),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem<String>(
                        value: gender, child: Text(gender));
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Contact Information',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Mobile Number*',
                      prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter mobile number'
                      : null,
                  onChanged: (value) => setState(() => patientMobile = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => setState(() => patientEmail = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Address*', prefixIcon: Icon(Icons.home)),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter address'
                      : null,
                  onChanged: (value) => setState(() => patientAddress = value),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final patientData = {
                          'id': patientID,
                          'name': patientName,
                          'age': patientAge,
                          'gender': patientGender,
                          'dob': patientDOB != null
                              ? DateFormat('dd/MM/yyyy').format(patientDOB!)
                              : '',
                          'mobile': patientMobile,
                          'email': patientEmail,
                          'address': patientAddress,
                          'registrationDate':
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientFormScreen(patientData: patientData),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue to Medical Form'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientFormScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  const PatientFormScreen({super.key, required this.patientData});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String placeOfInitialAdmission = '';
  String transferInICUFrom = '';
  DateTime? dateOfAdmissionInWard;
  DateTime? dateOfAdmissionInICU;
  DateTime? dateOfFinalOutcome;
  bool underwentOperativeProcedure = false;
  String finalOutcome = '';
  String diagnosis = '';
  bool infectionPresentOnAdmission = false;
  bool haiOccurred = false;
  bool daiOccurred = false;

  // Additional fields
  String antibioticsPriorAdmission = '';
  String antibioticsWithin48hrs = '';
  String provisionalDiagnosis = '';
  String underlyingDisease = '';
  String deviceInsertedOutsideHospital = '';
  String anyOtherDrugGiven = '';

  // Operative Procedure Fields
  DateTime? dateOfOperativeProcedure;
  String nameOfOperativeProcedure = '';

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  void _navigateToPage2(BuildContext context) {
    final Map<String, dynamic> page1Data = {
      'admission': {
        'placeOfInitialAdmission': placeOfInitialAdmission,
        'transferInICUFrom': transferInICUFrom,
        'dateOfAdmissionInWard': dateOfAdmissionInWard?.toIso8601String(),
        'dateOfAdmissionInICU': dateOfAdmissionInICU?.toIso8601String(),
        'dateOfFinalOutcome': dateOfFinalOutcome?.toIso8601String(),
      },
      'procedure': {
        'underwentOperativeProcedure': underwentOperativeProcedure,
        'dateOfOperativeProcedure': dateOfOperativeProcedure?.toIso8601String(),
        'nameOfOperativeProcedure': nameOfOperativeProcedure,
      },
      'outcome': {
        'finalOutcome': finalOutcome,
      },
      'diagnosis': {
        'provisionalDiagnosis': provisionalDiagnosis,
        'underlyingDisease': underlyingDisease,
      },
      'antibiotics': {
        'antibioticsPriorAdmission': antibioticsPriorAdmission,
        'antibioticsWithin48hrs': antibioticsWithin48hrs,
        'anyOtherDrugGiven': anyOtherDrugGiven,
      },
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Page2Screen(
          patientData: widget.patientData,
          page1Data: page1Data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Patient Form - Page 1'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Place of Initial Admission',
                ),
                value: placeOfInitialAdmission.isEmpty
                    ? null
                    : placeOfInitialAdmission,
                onChanged: (String? newValue) {
                  setState(() {
                    placeOfInitialAdmission = newValue!;
                  });
                },
                items: <String>[
                  'ICU',
                  'Ward',
                  'Emergency',
                ].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Transfer In ICU From'),
                value: transferInICUFrom.isEmpty ? null : transferInICUFrom,
                onChanged: (String? newValue) {
                  setState(() {
                    transferInICUFrom = newValue!;
                  });
                },
                items: <String>[
                  'Ward',
                  'Different Hospital',
                  'Other (Specify)',
                ].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  dateOfAdmissionInWard == null
                      ? 'Date of Admission in Ward'
                      : 'Date of Admission in Ward: ${dateOfAdmissionInWard!.toLocal()}'
                          .split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfAdmissionInWard = pickedDate;
                    });
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  dateOfAdmissionInICU == null
                      ? 'Date of Admission in ICU'
                      : 'Date of Admission in ICU: ${dateOfAdmissionInICU!.toLocal()}'
                          .split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfAdmissionInICU = pickedDate;
                    });
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  dateOfFinalOutcome == null
                      ? 'Date of Final Outcome'
                      : 'Date of Final Outcome: ${dateOfFinalOutcome!.toLocal()}'
                          .split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfFinalOutcome = pickedDate;
                    });
                  });
                },
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Underwent Operative Procedure'),
                value: underwentOperativeProcedure,
                onChanged: (value) {
                  setState(() {
                    underwentOperativeProcedure = value!;
                  });
                },
              ),
              if (underwentOperativeProcedure) ...[
                ListTile(
                  title: Text(
                    dateOfOperativeProcedure == null
                        ? 'Date of Operative Procedure'
                        : 'Date: ${dateOfOperativeProcedure!.toLocal()}'
                            .split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () {
                    _selectDate(context, (pickedDate) {
                      setState(() {
                        dateOfOperativeProcedure = pickedDate;
                      });
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name of Operative Procedure',
                  ),
                  onChanged: (value) {
                    setState(() {
                      nameOfOperativeProcedure = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Final Outcome'),
                value: finalOutcome.isEmpty ? null : finalOutcome,
                onChanged: (String? newValue) {
                  setState(() {
                    finalOutcome = newValue!;
                  });
                },
                items: ['Death', 'Discharge', 'Transfer']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Antibiotics taken prior to admission'),
                onChanged: (value) {
                  antibioticsPriorAdmission = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Antibiotics given within 48 hrs'),
                onChanged: (value) {
                  antibioticsWithin48hrs = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Provisional Diagnosis'),
                onChanged: (value) {
                  provisionalDiagnosis = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Underlying Disease'),
                onChanged: (value) {
                  underlyingDisease = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Any Other Drug Given'),
                onChanged: (value) {
                  anyOtherDrugGiven = value;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _navigateToPage2(context);
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page2Screen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> page1Data;

  const Page2Screen({
    super.key,
    required this.patientData,
    required this.page1Data,
  });

  @override
  State<Page2Screen> createState() => _Page2ScreenState();
}

class _Page2ScreenState extends State<Page2Screen> {
  bool haiOccurred = false;
  bool daiOccurred = false;
  String microbialEtiologyHAI = '';
  String susceptibilityPatternHAI = '';
  String microbialEtiologyDAI = '';
  String susceptibilityPatternDAI = '';
  String haiSite = '';
  String daiSite = '';
  String numberOfEpisodesHAI = '';
  String numberOfEpisodesDAI = '';

  final _formKey = GlobalKey<FormState>();

  void _navigateToPage3() {
    final Map<String, dynamic> page2Data = {
      'hai': {
        'haiOccurred': haiOccurred,
        'numberOfEpisodes': numberOfEpisodesHAI,
        'site': haiSite,
        'microbialEtiology': microbialEtiologyHAI,
        'susceptibilityPattern': susceptibilityPatternHAI,
      },
      'dai': {
        'daiOccurred': daiOccurred,
        'numberOfEpisodes': numberOfEpisodesDAI,
        'site': daiSite,
        'microbialEtiology': microbialEtiologyDAI,
        'susceptibilityPattern': susceptibilityPatternDAI,
      }
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Page3Screen(
          patientData: widget.patientData,
          page1Data: widget.page1Data,
          page2Data: page2Data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Page 2 - HAI/DAI Information'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CheckboxListTile(
                title: const Text('HAI Occurred'),
                value: haiOccurred,
                onChanged: (value) {
                  setState(() => haiOccurred = value!);
                },
              ),
              if (haiOccurred) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'No. of Episodes of HAI',
                  ),
                  onChanged: (value) => numberOfEpisodesHAI = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Site of HAI'),
                  onChanged: (value) => haiSite = value,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Microbial Etiology'),
                  onChanged: (value) => microbialEtiologyHAI = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Susceptibility Pattern'),
                  onChanged: (value) => susceptibilityPatternHAI = value,
                ),
              ],
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('DAI Occurred'),
                value: daiOccurred,
                onChanged: (value) {
                  setState(() => daiOccurred = value!);
                },
              ),
              if (daiOccurred) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'No. of Episodes of DAI',
                  ),
                  onChanged: (value) => numberOfEpisodesDAI = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Site of DAI'),
                  onChanged: (value) => daiSite = value,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Microbial Etiology'),
                  onChanged: (value) => microbialEtiologyDAI = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Susceptibility Pattern'),
                  onChanged: (value) => susceptibilityPatternDAI = value,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _navigateToPage3();
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page3Screen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> page1Data;
  final Map<String, dynamic> page2Data;

  const Page3Screen({
    super.key,
    required this.patientData,
    required this.page1Data,
    required this.page2Data,
  });

  @override
  State<Page3Screen> createState() => _Page3ScreenState();
}

class _Page3ScreenState extends State<Page3Screen> {
  // Complaints
  String? complaint1, complaint2, complaint3;
  bool neutropenia = false, leukemia = false, lymphoma = false;
  bool hivWithCd4 = false, splenectomy = false, onChemo = false;
  bool earlyPostTransplant = false, prednisoneUse = false;

  // General
  String? pulse, bp, respiratoryRate;

  // Systemic
  String? respiratoryExam, cardioExam, abdominalExam, nervousExam;

  // Lab
  String? tlc, anc;

  void _goToRadiologyPage() {
    final complaints = {
      'complaint1': complaint1,
      'complaint2': complaint2,
      'complaint3': complaint3,
      'neutropenia': neutropenia,
      'leukemia': leukemia,
      'lymphoma': lymphoma,
      'hivWithCd4': hivWithCd4,
      'splenectomy': splenectomy,
      'onChemotherapy': onChemo,
      'earlyPostTransplant': earlyPostTransplant,
      'prednisoneUse': prednisoneUse,
    };

    final exam = {
      'pulse': pulse,
      'bp': bp,
      'respiratoryRate': respiratoryRate,
      'respiratoryExam': respiratoryExam,
      'cardioExam': cardioExam,
      'abdominalExam': abdominalExam,
      'nervousExam': nervousExam,
      'tlc': tlc,
      'anc': anc,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RadiologyLabPage(
          patientData: widget.patientData,
          page1Data: widget.page1Data,
          page2Data: widget.page2Data,
          complaints: complaints,
          examination: exam,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Page 3 - Examination'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Complaints on Admission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Complaint 1'),
              onChanged: (v) => complaint1 = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Complaint 2'),
              onChanged: (v) => complaint2 = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Complaint 3'),
              onChanged: (v) => complaint3 = v),
          CheckboxListTile(
              title: const Text('Neutropenia'),
              value: neutropenia,
              onChanged: (v) => setState(() => neutropenia = v!)),
          CheckboxListTile(
              title: const Text('Leukemia'),
              value: leukemia,
              onChanged: (v) => setState(() => leukemia = v!)),
          CheckboxListTile(
              title: const Text('Lymphoma'),
              value: lymphoma,
              onChanged: (v) => setState(() => lymphoma = v!)),
          CheckboxListTile(
              title: const Text('HIV with CD4 <200'),
              value: hivWithCd4,
              onChanged: (v) => setState(() => hivWithCd4 = v!)),
          CheckboxListTile(
              title: const Text('Splenectomy'),
              value: splenectomy,
              onChanged: (v) => setState(() => splenectomy = v!)),
          CheckboxListTile(
              title: const Text('On Chemotherapy'),
              value: onChemo,
              onChanged: (v) => setState(() => onChemo = v!)),
          CheckboxListTile(
              title: const Text('Early Post Transplant'),
              value: earlyPostTransplant,
              onChanged: (v) => setState(() => earlyPostTransplant = v!)),
          CheckboxListTile(
              title: const Text('Prednisone > 40mg for >2 weeks'),
              value: prednisoneUse,
              onChanged: (v) => setState(() => prednisoneUse = v!)),
          const SizedBox(height: 16),
          const Text('General Examination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Pulse'),
              onChanged: (v) => pulse = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'B.P.'),
              onChanged: (v) => bp = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Respiratory Rate'),
              onChanged: (v) => respiratoryRate = v),
          const SizedBox(height: 16),
          const Text('Systemic Examination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Respiratory'),
              onChanged: (v) => respiratoryExam = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Cardiovascular'),
              onChanged: (v) => cardioExam = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Abdomen'),
              onChanged: (v) => abdominalExam = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'Nervous System'),
              onChanged: (v) => nervousExam = v),
          const SizedBox(height: 16),
          const Text('Lab Investigations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
              decoration: const InputDecoration(labelText: 'TLC'),
              onChanged: (v) => tlc = v),
          TextFormField(
              decoration: const InputDecoration(labelText: 'ANC'),
              onChanged: (v) => anc = v),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _goToRadiologyPage,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class RadiologyLabPage extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> page1Data;
  final Map<String, dynamic> page2Data;
  final Map<String, dynamic> complaints;
  final Map<String, dynamic> examination;

  const RadiologyLabPage({
    super.key,
    required this.patientData,
    required this.page1Data,
    required this.page2Data,
    required this.complaints,
    required this.examination,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController xrayFindingsController =
        TextEditingController();
    final TextEditingController ctFindingsController = TextEditingController();
    final TextEditingController usgFindingsController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Page 4 - Radiology'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: xrayFindingsController,
              decoration:
                  const InputDecoration(labelText: 'Chest X-Ray Findings'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ctFindingsController,
              decoration: const InputDecoration(labelText: 'CT/MRI Findings'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: usgFindingsController,
              decoration: const InputDecoration(labelText: 'USG Findings'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('Next'),
              onPressed: () {
                final radiology = {
                  'xrayFindings': xrayFindingsController.text,
                  'ctFindings': ctFindingsController.text,
                  'usgFindings': usgFindingsController.text,
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceAndDrugPage(
                      patientData: patientData,
                      page1Data: page1Data,
                      page2Data: page2Data,
                      complaints: complaints,
                      examination: examination,
                      radiology: radiology,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class DeviceAndDrugPage extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final Map<String, dynamic> page1Data;
  final Map<String, dynamic> page2Data;
  final Map<String, dynamic> complaints;
  final Map<String, dynamic> examination;
  final Map<String, dynamic> radiology;

  const DeviceAndDrugPage({
    super.key,
    required this.patientData,
    required this.page1Data,
    required this.page2Data,
    required this.complaints,
    required this.examination,
    required this.radiology,
  });

  @override
  State<DeviceAndDrugPage> createState() => _DeviceAndDrugPageState();
}

class _DeviceAndDrugPageState extends State<DeviceAndDrugPage> {
  final TextEditingController otherDrugController = TextEditingController();
  final TextEditingController deviceTypeController = TextEditingController();
  final TextEditingController drugNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Page 5 - Devices & Drugs'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Device Inserted:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: deviceTypeController,
            decoration: const InputDecoration(labelText: 'Type of Device'),
          ),
          const SizedBox(height: 16),
          const Text('Antibiotic/Antifungal Administered:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: drugNameController,
            decoration: const InputDecoration(labelText: 'Drug Name'),
          ),
          const SizedBox(height: 16),
          const Text('Any Other Drug Given:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: otherDrugController,
            decoration: const InputDecoration(labelText: 'Enter details'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            child: const Text('Final Submit'),
            onPressed: () async {
              final devices = [
                {'deviceType': deviceTypeController.text}
              ];
              final drugs = [
                {'drug': drugNameController.text}
              ];
              final others = otherDrugController.text;

              final fullData = {
                'patient': widget.patientData,
                ...widget.page1Data,
                ...widget.page2Data,
                'complaints': widget.complaints,
                'examination': widget.examination,
                'radiology': widget.radiology,
                'devices': devices,
                'drugs': drugs,
                'otherDrugs': others,
              };

              String path = await FileUtils.savePatientDataToFile(fullData);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmationScreen(filePath: path),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String filePath;
  const ConfirmationScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Confirmation'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              '✅ Patient record saved successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Path:\n$filePath',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final file = File(filePath);
                  if (await file.exists()) {
                    final content = await file.readAsString();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Patient Record'),
                          content: SingleChildScrollView(child: Text(content)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File not found')),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Error reading file: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error reading file: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final result = await OpenFile.open(filePath);
                  debugPrint('OpenFile result: ${result.message}');
                  if (result.type != ResultType.done && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                } catch (e) {
                  debugPrint('Error opening file: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening file: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in Default App'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                try {
                  final box = context.findRenderObject() as RenderBox?;
                  Share.shareXFiles(
                    [XFile(filePath)],
                    text: 'Patient Medical Record File',
                    subject: 'Medical Record Sharing',
                    sharePositionOrigin: box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null,
                  ).then((result) {
                    debugPrint('Share result: $result');
                  });
                } catch (e) {
                  debugPrint('Error sharing file: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sharing file: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Share File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // Show a loading indicator
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saving to Downloads...')),
                  );
                }

                final result = await FileUtils.saveToDownloads(
                  context: context,
                  sourceFilePath: filePath,
                );

                if (context.mounted) {
                  if (result.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved to: ${result.path}'),
                        duration: const Duration(seconds: 5),
                      ),
                    );

                    // Update the displayed path if successful
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('File Saved'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('File saved successfully!'),
                            const SizedBox(height: 8),
                            Text('Location: ${result.path}'),
                            const SizedBox(height: 16),
                            const Text(
                              'Note: On newer Android versions, the file may only be accessible through the app. '
                              'Use the "Share File" button to save it elsewhere.',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${result.message}'),
                        duration: const Duration(seconds: 5),
                      ),
                    );

                    // Show permission help dialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Storage Permission Issue'),
                        content: const Text(
                            'This app requires storage permission to save files externally. '
                            'Please use the "Share File" button instead to save the file through your preferred app.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Save to Downloads'),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveResult {
  final bool success;
  final String path;
  final String message;

  SaveResult({
    required this.success,
    this.path = '',
    this.message = '',
  });
}

class FileUtils {
  static Future<String> savePatientDataToFile(Map<String, dynamic> data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'record_$timestamp.txt';
      final filePath = '${dir.path}/$fileName';

      final file = File(filePath);
      final content = _formatData(data);
      await file.writeAsString(content);

      debugPrint('File saved successfully at: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return '';
    }
  }

  static String _formatData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('PATIENT MEDICAL RECORD');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('----------------------------------------');

    data.forEach((key, value) {
      buffer.writeln('\n[$key]');
      if (value is Map) {
        value.forEach((k, v) => buffer.writeln('$k: $v'));
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          buffer.writeln('Item ${i + 1}: ${value[i]}');
        }
      } else {
        buffer.writeln(value.toString());
      }
    });
    return buffer.toString();
  }

  static Future<SaveResult> saveToDownloads({
    required BuildContext context,
    required String sourceFilePath,
  }) async {
    try {
      debugPrint('Starting saveToDownloads operation');
      debugPrint('Source file path: $sourceFilePath');

      // First check if the source file exists
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist');
        return SaveResult(
          success: false,
          message: 'Source file does not exist',
        );
      }

      // Request storage permissions with proper handling and UI
      bool hasPermission = await _requestStoragePermissions(context);
      if (!hasPermission) {
        debugPrint('Storage permission denied by user');
        return SaveResult(
          success: false,
          message: 'Storage permission is required to save files',
        );
      }

      final fileName = sourceFilePath.split('/').last;
      debugPrint('File name extracted: $fileName');

      if (Platform.isAndroid) {
        debugPrint('Device is running Android');

        // Check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final int sdkInt = androidInfo.version.sdkInt;
        debugPrint('Android SDK version: $sdkInt');

        // Android 10 (API 29) and above
        if (sdkInt >= 29) {
          debugPrint('Using modern Android approach (API ≥ 29)');
          final result =
              await _saveToDownloadsModernAndroid(sourceFilePath, fileName);
          debugPrint(
              'Modern Android save result: ${result.success ? 'Success' : 'Failed'} - ${result.path}');
          return result;
        }
        // Android 9 and below
        else {
          debugPrint('Using legacy Android approach (API < 29)');
          final result =
              await _saveToDownloadsLegacyAndroid(sourceFilePath, fileName);
          debugPrint(
              'Legacy Android save result: ${result.success ? 'Success' : 'Failed'} - ${result.path}');
          return result;
        }
      }
      // iOS and other platforms
      else {
        debugPrint(
            'Device is not running Android. Using documents directory approach');
        final result =
            await _saveToDocumentsDirectory(sourceFilePath, fileName);
        debugPrint(
            'Non-Android save result: ${result.success ? 'Success' : 'Failed'} - ${result.path}');
        return result;
      }
    } catch (e) {
      debugPrint('Error in saveToDownloads: $e');
      return SaveResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Fixed permission handling method
  static Future<bool> _requestStoragePermissions(BuildContext context) async {
    debugPrint('Requesting storage permissions');

    try {
      // Check if running on Android 11+
      bool isAndroid11OrAbove = false;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isAndroid11OrAbove = androidInfo.version.sdkInt >= 30;
        debugPrint('Android 11+ detected: $isAndroid11OrAbove');
      }

      // For Android 11+, we need to request MANAGE_EXTERNAL_STORAGE
      if (isAndroid11OrAbove) {
        final manageStatus = await Permission.manageExternalStorage.status;

        // If already granted, return true
        if (manageStatus.isGranted) {
          debugPrint('Manage external storage permission already granted');
          return true;
        }

        // If permanently denied, prompt to open settings
        if (manageStatus.isPermanentlyDenied) {
          debugPrint(
              'Manage storage permission permanently denied, showing settings dialog');
          final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Storage Permission Required'),
                  content: const Text(
                    'This app needs "Allow management of all files" permission to save files. '
                    'Please open settings and enable this permission.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldOpenSettings) {
            debugPrint('Opening app settings for manage external storage');
            await openAppSettings();

            // After returning from settings, check permission again
            final newStatus = await Permission.manageExternalStorage.status;
            debugPrint(
                'New manage storage permission status after settings: ${newStatus.isGranted}');
            return newStatus.isGranted;
          }
          return false;
        }

        // Request manage external storage permission and explain clearly
        debugPrint('Requesting manage external storage permission');
        final showExplanation = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Storage Permission Required'),
                content: const Text(
                  'This app needs permission to "Manage All Files" in order to save files to your Downloads folder. '
                  'Please grant this permission on the next screen.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!showExplanation) {
          return false;
        }

        // Request the permission
        final manageResult = await Permission.manageExternalStorage.request();
        debugPrint(
            'Manage external storage permission result: ${manageResult.isGranted}');

        // On Android 11+, this is all we need
        return manageResult.isGranted;
      }
      // For Android 10 and below, use regular storage permission
      else {
        // Check current permission status
        PermissionStatus storageStatus = await Permission.storage.status;

        // If already granted, return true
        if (storageStatus.isGranted) {
          debugPrint('Storage permission already granted');
          return true;
        }

        // If permanently denied, prompt to open settings
        if (storageStatus.isPermanentlyDenied) {
          debugPrint(
              'Storage permission permanently denied, showing settings dialog');
          final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Storage Permission Required'),
                  content: const Text(
                    'Storage permission is required to save files to your device. '
                    'Please open settings and grant permission.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldOpenSettings) {
            debugPrint('Opening app settings for storage permission');
            await openAppSettings();

            // After returning from settings, check permission again
            final newStatus = await Permission.storage.status;
            debugPrint(
                'New storage permission status after settings: ${newStatus.isGranted}');
            return newStatus.isGranted;
          }
          return false;
        }

        // Show explanation before requesting
        final showExplanation = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Storage Permission Required'),
                content: const Text(
                  'This app needs storage permission to save files to your device. '
                  'Please grant permission on the next screen.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!showExplanation) {
          return false;
        }

        // Request permission
        debugPrint('Requesting storage permission');
        storageStatus = await Permission.storage.request();
        debugPrint(
            'Storage permission request result: ${storageStatus.isGranted}');

        return storageStatus.isGranted;
      }
    } catch (e) {
      debugPrint('Error while requesting permissions: $e');
      return false;
    }
  }

  // Helper method to get the Downloads directory
  static Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Get external storage directory
        final directory = await getExternalStorageDirectory();

        if (directory != null) {
          // Find the root of external storage by going up until we find the Android folder
          final List<String> pathParts = directory.path.split('/');
          int androidIndex = pathParts.indexOf('Android');

          if (androidIndex > 0) {
            // Get the path to the root of external storage
            final String rootPath =
                pathParts.sublist(0, androidIndex).join('/');

            // This is the standard Download directory on most Android devices
            final downloadsDir = Directory('$rootPath/Download');

            // Verify the directory exists
            if (await downloadsDir.exists()) {
              return downloadsDir;
            }
          }
        }

        // If we couldn't find Download directory, try another approach
        // Get all external storage directories
        final List<Directory>? extDirs = await getExternalStorageDirectories();
        if (extDirs != null && extDirs.isNotEmpty) {
          // Use the first external directory as a base
          final baseDir = extDirs[0].path;
          final rootPath = baseDir.split('Android')[0];
          final downloadsDir = Directory('$rootPath/Download');

          // Create the directory if it doesn't exist
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          return downloadsDir;
        }
      } catch (e) {
        debugPrint('Error finding Downloads directory: $e');
      }
    }

    // If we can't get the Downloads directory, return null
    return null;
  }

  // Check if device is running Android 11 (API 30) or above
  static Future<bool> _isAndroid11OrAbove() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  // Add media scanner function to make files visible in gallery/file explorer
  static Future<void> _scanFile(String filePath) async {
    try {
      // Use platform channel to invoke media scanner
      const platform = MethodChannel('com.yourapp/mediaScanner');
      await platform.invokeMethod('scanFile', {'path': filePath});
      debugPrint('Media scan requested for: $filePath');
    } catch (e) {
      debugPrint('Error scanning file: $e');
      // Try alternative approach if platform channel fails
      await _scanFileAlternative(filePath);
    }
  }

  // Alternative media scanning approach
  static Future<void> _scanFileAlternative(String filePath) async {
    try {
      // Create an empty file that triggers a media scan when created
      final File triggerFile = File('$filePath.nomedia');
      await triggerFile.create();
      await Future.delayed(const Duration(milliseconds: 500));
      await triggerFile.delete();
      debugPrint('Alternative media scan completed for: $filePath');
    } catch (e) {
      debugPrint('Error in alternative media scan: $e');
    }
  }

  // Modern Android implementation with media scanning
  static Future<SaveResult> _saveToDownloadsModernAndroid(
      String sourceFilePath, String fileName) async {
    try {
      debugPrint('Attempting to save file on modern Android (API 29+)');

      // First check if we have permission
      final manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        debugPrint('Manage external storage permission not granted');
        return SaveResult(
          success: false,
          message: 'Storage permission is required',
        );
      }

      // For Android 11+, we'll use a more direct approach since we have MANAGE_EXTERNAL_STORAGE
      if (await _isAndroid11OrAbove()) {
        try {
          // Get the Downloads directory path
          final downloadsDir = await _getDownloadsDirectory();
          if (downloadsDir != null) {
            // Create a MedicalRecords folder
            final recordsDir = Directory('${downloadsDir.path}/MedicalRecords');
            if (!await recordsDir.exists()) {
              await recordsDir.create(recursive: true);
            }

            // Copy the file
            final newPath = '${recordsDir.path}/$fileName';
            final newFile = await File(sourceFilePath).copy(newPath);

            // Notify the media scanner about the new file
            await _scanFile(newFile.path);

            debugPrint('File saved successfully to Downloads: ${newFile.path}');
            return SaveResult(
              success: true,
              path: newFile.path,
              message: 'File saved to Downloads/MedicalRecords',
            );
          }
        } catch (e) {
          debugPrint('Error accessing Downloads directory: $e');
        }
      }

      // Fallback to app's external storage if we can't access Downloads
      final allExternalDirs = await getExternalStorageDirectories();
      debugPrint('External directories found: ${allExternalDirs?.length ?? 0}');

      if (allExternalDirs != null && allExternalDirs.isNotEmpty) {
        // Try to find the primary external storage
        final externalDir = allExternalDirs[0];
        final savedDir = Directory('${externalDir.path}/MedicalRecords');

        // Create directory if it doesn't exist
        if (!await savedDir.exists()) {
          await savedDir.create(recursive: true);
        }

        // Copy the file
        final newPath = '${savedDir.path}/$fileName';
        final newFile = await File(sourceFilePath).copy(newPath);

        // Notify the media scanner about the new file
        await _scanFile(newFile.path);

        debugPrint('File saved to external app directory: ${newFile.path}');
        return SaveResult(
          success: true,
          path: newFile.path,
          message: 'File saved to external storage',
        );
      }

      // If we're here, we couldn't save externally - save to app directory as last resort
      return await _saveToDocumentsDirectory(sourceFilePath, fileName);
    } catch (e) {
      debugPrint('Error in _saveToDownloadsModernAndroid: $e');
      return SaveResult(
        success: false,
        message: 'Error saving file: $e',
      );
    }
  }

  // Legacy Android implementation with media scanning
  static Future<SaveResult> _saveToDownloadsLegacyAndroid(
      String sourceFilePath, String fileName) async {
    try {
      // Request storage permission (crucial for Android 9 and below)
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        return SaveResult(
          success: false,
          message: 'Storage permission denied',
        );
      }

      // For Android 9 and below, we can directly access the Download directory
      Directory? downloadsDir;

      try {
        // Get external storage directory
        final directory = await getExternalStorageDirectory();

        if (directory != null) {
          // Find the root of external storage by going up until we find the Android folder
          final List<String> pathParts = directory.path.split('/');
          int androidIndex = pathParts.indexOf('Android');

          if (androidIndex > 0) {
            // Get the path to the root of external storage
            final String rootPath =
                pathParts.sublist(0, androidIndex).join('/');

            // This is the standard Download directory on most Android devices
            downloadsDir = Directory('$rootPath/Download');

            // Create the directory if it doesn't exist (usually exists by default)
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }

            // Create a MedicalRecords subfolder for better organization
            final recordsDir = Directory('${downloadsDir.path}/MedicalRecords');
            if (!await recordsDir.exists()) {
              await recordsDir.create(recursive: true);
            }

            final newPath = '${recordsDir.path}/$fileName';
            final newFile = await File(sourceFilePath).copy(newPath);

            // Notify the media scanner about the new file
            await _scanFile(newFile.path);

            debugPrint('File saved successfully to: ${newFile.path}');

            return SaveResult(
              success: true,
              path: newFile.path,
              message: 'File saved to Downloads/MedicalRecords',
            );
          }
        }
      } catch (e) {
        debugPrint('Error accessing external storage: $e');
      }

      // If we got here, we couldn't save to the public Download directory
      // Try using a different approach as a fallback
      try {
        // Get direct path to downloads using Environment.DIRECTORY_DOWNLOADS
        // This is a more reliable approach on some devices
        final List<Directory>? extDirs = await getExternalStorageDirectories();
        if (extDirs != null && extDirs.isNotEmpty) {
          final externalDir = extDirs[0];

          // Create MedicalRecords directory
          final recordsDir = Directory('${externalDir.path}/MedicalRecords');
          if (!await recordsDir.exists()) {
            await recordsDir.create(recursive: true);
          }

          final newPath = '${recordsDir.path}/$fileName';
          final newFile = await File(sourceFilePath).copy(newPath);

          // Notify the media scanner about the new file
          await _scanFile(newFile.path);

          debugPrint(
              'File saved successfully to fallback path: ${newFile.path}');

          return SaveResult(
            success: true,
            path: newFile.path,
            message: 'File saved to external storage',
          );
        }
      } catch (e) {
        debugPrint('Error in fallback external storage approach: $e');
      }

      // Last resort: save to app's documents directory
      return await _saveToDocumentsDirectory(sourceFilePath, fileName);
    } catch (e) {
      debugPrint('Error in _saveToDownloadsLegacyAndroid: $e');
      return SaveResult(
        success: false,
        message: 'Error saving file: $e',
      );
    }
  }

  // iOS and fallback implementation
  static Future<SaveResult> _saveToDocumentsDirectory(
      String sourceFilePath, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // Create a MedicalRecords subfolder
      final savedDir = Directory('${dir.path}/MedicalRecords');
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }

      final newPath = '${savedDir.path}/$fileName';
      final newFile = await File(sourceFilePath).copy(newPath);

      debugPrint('File saved successfully to: ${newFile.path}');

      return SaveResult(
        success: true,
        path: newFile.path,
        message: 'File saved to application documents/MedicalRecords',
      );
    } catch (e) {
      debugPrint('Error in _saveToDocumentsDirectory: $e');
      return SaveResult(
        success: false,
        message: 'Error saving file: $e',
      );
    }
  }
}
