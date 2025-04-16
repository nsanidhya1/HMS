import 'package:flutter/material.dart';

void main() => runApp(PatientFormApp());

class PatientFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: Color(0xFF005DA3), // Jaypee's primary blue
          secondary: Color(0xFF007DC5), // Lighter blue accent
        ),
        scaffoldBackgroundColor: Color(0xFFE3F2FD), // Light blue background
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF005DA3), // Primary blue for app bar
          foregroundColor: Colors.white, // White text on app bar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6F00), // Orange for buttons
            foregroundColor: Colors.white, // White text on buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor:
              Color(0xFFF5F5F5), // Light grey background for input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Color(0xFF005DA3)), // Blue border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide:
                BorderSide(color: Color(0xFF007DC5)), // Lighter blue on focus
          ),
          labelStyle: TextStyle(color: Color(0xFF005DA3)), // Blue label text
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Default black text
          bodyMedium: TextStyle(color: Colors.black54), // Subtle grey text
        ),
      ),
      home: PatientFormScreen(),
    );
  }
}

class PatientFormScreen extends StatefulWidget {
  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
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
      BuildContext context, Function(DateTime) onSelected) async {
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Page2Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60, // Adjust height if needed
        backgroundColor: Color(0xFF005DA3), // Primary blue
        elevation: 2, // Add shadow if required
        centerTitle: true,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/img.png', // Path to your logo image in assets
                height: 40, // Adjust the height as needed
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Patient Form',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Place of Initial Admission
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
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
                items: <String>['ICU', 'Ward', 'Emergency']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Transfer In ICU From
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Transfer In ICU From',
                ),
                value: transferInICUFrom.isEmpty ? null : transferInICUFrom,
                onChanged: (String? newValue) {
                  setState(() {
                    transferInICUFrom = newValue!;
                  });
                },
                items: <String>['Ward', 'Different Hospital', 'Other (Specify)']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Date of Admission in Ward
              ListTile(
                title: Text(dateOfAdmissionInWard == null
                    ? 'Date of Admission in Ward'
                    : 'Date of Admission in Ward: ${dateOfAdmissionInWard!.toLocal()}'
                        .split(' ')[0]),
                trailing: Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfAdmissionInWard = pickedDate;
                    });
                  });
                },
              ),
              Divider(),

              // Date of Admission in ICU
              ListTile(
                title: Text(dateOfAdmissionInICU == null
                    ? 'Date of Admission in ICU'
                    : 'Date of Admission in ICU: ${dateOfAdmissionInICU!.toLocal()}'
                        .split(' ')[0]),
                trailing: Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfAdmissionInICU = pickedDate;
                    });
                  });
                },
              ),
              Divider(),

              // Date of Final Outcome
              ListTile(
                title: Text(dateOfFinalOutcome == null
                    ? 'Date of Final Outcome'
                    : 'Date of Final Outcome: ${dateOfFinalOutcome!.toLocal()}'
                        .split(' ')[0]),
                trailing: Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                onTap: () {
                  _selectDate(context, (pickedDate) {
                    setState(() {
                      dateOfFinalOutcome = pickedDate;
                    });
                  });
                },
              ),
              Divider(),

              // Whether Underwent Operative Procedure
              CheckboxListTile(
                title: Text('Whether Underwent Operative Procedure'),
                value: underwentOperativeProcedure,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    underwentOperativeProcedure = value!;
                  });
                },
              ),

              // If YES, show Date and Procedure Name fields
              if (underwentOperativeProcedure) ...[
                // Date of Operative Procedure
                ListTile(
                  title: Text(dateOfOperativeProcedure == null
                      ? 'Date of Operative Procedure'
                      : 'Date of Operative Procedure: ${dateOfOperativeProcedure!.toLocal()}'
                          .split(' ')[0]),
                  trailing: Icon(Icons.calendar_today,
                      color: Theme.of(context).primaryColor),
                  onTap: () {
                    _selectDate(context, (pickedDate) {
                      setState(() {
                        dateOfOperativeProcedure = pickedDate;
                      });
                    });
                  },
                ),
                SizedBox(height: 16),

                // Name of Operative Procedure
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name of Operative Procedure',
                  ),
                  onChanged: (value) {
                    setState(() {
                      nameOfOperativeProcedure = value;
                    });
                  },
                ),
                SizedBox(height: 16),
              ],

              // Final Outcome
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Final Outcome',
                ),
                value: finalOutcome.isEmpty ? null : finalOutcome,
                onChanged: (String? newValue) {
                  setState(() {
                    finalOutcome = newValue!;
                  });
                },
                items: <String>['Death', 'Discharge', 'Transfer']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Additional fields
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Antibiotics taken prior to admission'),
                onChanged: (value) => setState(() {
                  antibioticsPriorAdmission = value;
                }),
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Antibiotics given within 48 hrs'),
                onChanged: (value) => setState(() {
                  antibioticsWithin48hrs = value;
                }),
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(labelText: 'Provisional Diagnosis'),
                onChanged: (value) => setState(() {
                  provisionalDiagnosis = value;
                }),
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(labelText: 'Underlying Disease'),
                onChanged: (value) => setState(() {
                  underlyingDisease = value;
                }),
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Device inserted outside the Hospital'),
                onChanged: (value) => setState(() {
                  deviceInsertedOutsideHospital = value;
                }),
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(labelText: 'Any Other Drug Given'),
                onChanged: (value) => setState(() {
                  anyOtherDrugGiven = value;
                }),
              ),
              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Navigate to Page 2
                    _navigateToPage2(context);
                  }
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page2Screen extends StatefulWidget {
  @override
  _Page2ScreenState createState() => _Page2ScreenState();
}

class _Page2ScreenState extends State<Page2Screen> {
  bool haiOccurred = false;
  bool daiOccurred = false;
  bool bloodStreamSelected = false; // Track if Blood Stream is selected
  bool isSecondaryBSI = false; // Track if secondary BSI is selected
  String haiDetails = '';
  String daiDetails = '';
  String microbialEtiology = '';
  String bloodStreamSource = '';
  String specifySecondaryBSI = ''; // To specify source in case of secondary BSI
  bool ventilatorSelected = false;
  bool urinaryCatheterSelected = false;
  bool centralLineCatheterSelected = false;
  bool otherDAISelected = false;
  String? otherDAISites;
  String? microbialEtiologyDAI;
  String? susceptibilityPatternDAI;
  // Function to update Blood Stream Source
  void _onBloodStreamSourceChanged(String? value) {
    setState(() {
      bloodStreamSource = "null";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HAI/DAI Form'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CheckboxListTile(
              title: Text('HAI Occurred'),
              value: haiOccurred,
              onChanged: (value) {
                setState(() {
                  haiOccurred = value!;
                });
              },
            ),
            if (haiOccurred) ...[
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'No. of Episodes of HAI'),
                onChanged: (value) {
                  // Update the number of episodes
                },
              ),
              SizedBox(height: 16),

              // Site(s) Involved in HAI
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Site(s) Involved in HAI:'),
                  CheckboxListTile(
                    title: Text('Respiratory Tract'),
                    value: false, // Update with actual value based on selection
                    onChanged: (value) {
                      // Handle respiratory tract selection
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Urinary Tract'),
                    value: false, // Update with actual value based on selection
                    onChanged: (value) {
                      // Handle urinary tract selection
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Blood Stream'),
                    value: bloodStreamSelected,
                    onChanged: (value) {
                      setState(() {
                        bloodStreamSelected = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Other'),
                    value: false, // Update with actual value based on selection
                    onChanged: (value) {
                      // Handle other selection
                    },
                  ),
                ],
              ),
              if (bloodStreamSelected) ...[
                // Blood Stream specific inputs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('If site involved is Blood Stream, specify:'),
                    RadioListTile<String>(
                      title: Text('Primary'),
                      value: 'Primary',
                      groupValue: bloodStreamSource,
                      onChanged: _onBloodStreamSourceChanged,
                    ),
                    RadioListTile<String>(
                      title: Text('Secondary'),
                      value: 'Secondary',
                      groupValue: bloodStreamSource,
                      onChanged: _onBloodStreamSourceChanged,
                    ),
                    if (bloodStreamSource == 'Secondary') ...[
                      // Source of Secondary BSI
                      Text('In case of Secondary BSI, source is:'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            title: Text('Respiratory'),
                            value: 'Respiratory',
                            groupValue: specifySecondaryBSI,
                            onChanged: (value) {
                              setState(() {
                                specifySecondaryBSI = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('Urinary'),
                            value: 'Urinary',
                            groupValue: specifySecondaryBSI,
                            onChanged: (value) {
                              setState(() {
                                specifySecondaryBSI = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Text('Other'),
                            value: 'Other',
                            groupValue: specifySecondaryBSI,
                            onChanged: (value) {
                              setState(() {
                                specifySecondaryBSI = value!;
                              });
                            },
                          ),
                          if (specifySecondaryBSI == 'Other') ...[
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Specify other source:',
                              ),
                              onChanged: (value) {
                                // Update other source of Secondary BSI
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ],
              SizedBox(height: 16),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Microbial Etiology for HAI'),
                onChanged: (value) {
                  microbialEtiology = value;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Write susceptibility pattern here:'),
                onChanged: (value) {
                  // Handle susceptibility pattern input
                },
              ),
            ],
            SizedBox(height: 16),

            // DAI Occurred Section
            // Inside the build method of Page2Screen's State class
            CheckboxListTile(
              title: Text('DAI Occurred'),
              value: daiOccurred,
              onChanged: (value) {
                setState(() {
                  daiOccurred = value!;
                });
              },
            ),
            if (daiOccurred) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Whether Device Associated Infection (DAI) Occurred:'),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('YES'),
                        Radio<bool>(
                          value: true,
                          groupValue: daiOccurred,
                          onChanged: (value) {
                            setState(() {
                              daiOccurred = value!;
                            });
                          },
                        ),
                        Text('NO'),
                        Radio<bool>(
                          value: false,
                          groupValue: daiOccurred,
                          onChanged: (value) {
                            setState(() {
                              daiOccurred = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'No. of Episodes of DAI:'),
                onChanged: (value) {
                  daiDetails = value;
                },
              ),
              SizedBox(height: 16),
              Text('Site(s) Involved in DAI:'),
              CheckboxListTile(
                title: Text('Ventilator'),
                value: ventilatorSelected,
                onChanged: (value) {
                  setState(() {
                    ventilatorSelected = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Urinary Catheter'),
                value: urinaryCatheterSelected,
                onChanged: (value) {
                  setState(() {
                    urinaryCatheterSelected = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Central Line Catheter'),
                value: centralLineCatheterSelected,
                onChanged: (value) {
                  setState(() {
                    centralLineCatheterSelected = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Other'),
                value: otherDAISelected,
                onChanged: (value) {
                  setState(() {
                    otherDAISelected = value!;
                  });
                },
              ),
              if (otherDAISelected)
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Specify other site(s):'),
                  onChanged: (value) {
                    otherDAISites = value;
                  },
                ),
              SizedBox(height: 16),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Microbial Etiology for DAI:'),
                onChanged: (value) {
                  microbialEtiologyDAI = value;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText:
                        'Write susceptibility pattern in the box provided:'),
                onChanged: (value) {
                  susceptibilityPatternDAI = value;
                },
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Page 3
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Page3Screen()), // Replace with your Page 3 class
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page3Screen extends StatefulWidget {
  @override
  _Page3ScreenState createState() => _Page3ScreenState();
}

class _Page3ScreenState extends State<Page3Screen> {
  // Variables for the form
  String? complaint1;
  String? complaint2;
  String? complaint3;
  bool neutropenia = false;
  bool leukemia = false;
  bool lymphoma = false;
  bool hivWithCd4 = false;
  bool splenectomy = false;
  bool onChemotherapy = false;
  bool earlyPostTransplant = false;
  bool prednisoneUse = false;

  String? pulse;
  String? bp;
  String? respiratoryRate;

  String? respiratoryExam;
  String? cardioExam;
  String? abdominalExam;
  String? nervousExam;

  String? tlc;
  String? anc;

  // Radiology Section Variables
  String? chestXrayFindings;
  String? ctMriFindings;
  String? usgFindings;
  DateTime? chestXrayDate;
  DateTime? ctMriDate;
  DateTime? usgDate;

  // Antibiotics Section Variables
  String? antibioticsBeforeAdmission;
  String? antibioticsWithin48Hours;

  String? provisionalDiagnosis;
  String? underlyingDisease;

  // Function to show the date picker
  Future<void> _pickDate(BuildContext context, DateTime? initialDate,
      ValueChanged<DateTime?> onDatePicked) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      onDatePicked(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PART–A Form'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Complaints on Admission Section
            Text(
              'COMPLAINTS ON ADMISSION',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Complaint 1'),
              onChanged: (value) => setState(() => complaint1 = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Complaint 2'),
              onChanged: (value) => setState(() => complaint2 = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Complaint 3'),
              onChanged: (value) => setState(() => complaint3 = value),
            ),
            CheckboxListTile(
              title: Text('Neutropenia (ANC< 500/μL)'),
              value: neutropenia,
              onChanged: (value) => setState(() => neutropenia = value!),
            ),
            CheckboxListTile(
              title: Text('Leukemia'),
              value: leukemia,
              onChanged: (value) => setState(() => leukemia = value!),
            ),
            CheckboxListTile(
              title: Text('Lymphoma'),
              value: lymphoma,
              onChanged: (value) => setState(() => lymphoma = value!),
            ),
            CheckboxListTile(
              title: Text('HIV with CD4 <200/mm³'),
              value: hivWithCd4,
              onChanged: (value) => setState(() => hivWithCd4 = value!),
            ),
            CheckboxListTile(
              title: Text('Splenectomy'),
              value: splenectomy,
              onChanged: (value) => setState(() => splenectomy = value!),
            ),
            CheckboxListTile(
              title: Text('On Chemotherapy'),
              value: onChemotherapy,
              onChanged: (value) => setState(() => onChemotherapy = value!),
            ),
            CheckboxListTile(
              title: Text('Early Post Transplant'),
              value: earlyPostTransplant,
              onChanged: (value) =>
                  setState(() => earlyPostTransplant = value!),
            ),
            CheckboxListTile(
              title: Text('Prednisone >40 mg (>2 weeks) or equivalent'),
              value: prednisoneUse,
              onChanged: (value) => setState(() => prednisoneUse = value!),
            ),

            SizedBox(height: 16),

            // General Examination Section
            Text(
              'GENERAL EXAMINATION',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Pulse (per minute)'),
              onChanged: (value) => setState(() => pulse = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'B.P. (mm Hg)'),
              onChanged: (value) => setState(() => bp = value),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Respiratory Rate (per minute)'),
              onChanged: (value) => setState(() => respiratoryRate = value),
            ),

            SizedBox(height: 16),

            // Systemic Examination Section
            Text(
              'SYSTEMIC EXAMINATION',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Respiratory Examination'),
              onChanged: (value) => setState(() => respiratoryExam = value),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Cardio Vascular Examination'),
              onChanged: (value) => setState(() => cardioExam = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Abdominal Examination'),
              onChanged: (value) => setState(() => abdominalExam = value),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Nervous System Examination'),
              onChanged: (value) => setState(() => nervousExam = value),
            ),

            SizedBox(height: 16),

            // Lab Investigations Section
            Text(
              'LAB INVESTIGATIONS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Total Leukocyte Count (TLC) (μL)'),
              onChanged: (value) => setState(() => tlc = value),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Absolute Neutrophil Count (ANC) (μL)'),
              onChanged: (value) => setState(() => anc = value),
            ),

            SizedBox(height: 16),

            // Radiology Section
            Text(
              'RADIOLOGY',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                  'Chest X-ray Date: ${chestXrayDate != null ? chestXrayDate.toString().split(' ')[0] : 'Select Date'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, chestXrayDate, (picked) {
                setState(() {
                  chestXrayDate = picked;
                });
              }),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Chest X-ray Findings'),
              onChanged: (value) => setState(() => chestXrayFindings = value),
            ),
            ListTile(
              title: Text(
                  'CT/MRI Date: ${ctMriDate != null ? ctMriDate.toString().split(' ')[0] : 'Select Date'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, ctMriDate, (picked) {
                setState(() {
                  ctMriDate = picked;
                });
              }),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'CT/MRI Findings'),
              onChanged: (value) => setState(() => ctMriFindings = value),
            ),
            ListTile(
              title: Text(
                  'USG/Other Date: ${usgDate != null ? usgDate.toString().split(' ')[0] : 'Select Date'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, usgDate, (picked) {
                setState(() {
                  usgDate = picked;
                });
              }),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'USG/Other Findings'),
              onChanged: (value) => setState(() => usgFindings = value),
            ),

            SizedBox(height: 16),

            // Antibiotics Section
            Text(
              'ANTIBIOTICS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Antibiotics prior to admission'),
              onChanged: (value) =>
                  setState(() => antibioticsBeforeAdmission = value),
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Antibiotics given within 48 hours'),
              onChanged: (value) =>
                  setState(() => antibioticsWithin48Hours = value),
            ),

            SizedBox(height: 16),

            // Provisional Diagnosis Section
            Text(
              'PROVISIONAL DIAGNOSIS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Provisional Diagnosis'),
              onChanged: (value) =>
                  setState(() => provisionalDiagnosis = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Underlying Disease'),
              onChanged: (value) => setState(() => underlyingDisease = value),
            ),

            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PartBFormScreen()), // Navigate to the new page
                );
              },
              child: Text('Next'),
            )
          ],
        ),
      ),
    );
  }
}

class PartBFormScreen extends StatefulWidget {
  @override
  _PartBFormScreenState createState() => _PartBFormScreenState();
}

class _PartBFormScreenState extends State<PartBFormScreen> {
  List<Map<String, dynamic>> daysData = [];

  // Function to add a new day entry
  void _addNewDay() {
    setState(() {
      daysData.add({
        'date': DateTime.now(), // Initialize with current date
        'fever': false,
        'bradycardia': false,
        'tachycardia': false,
        'tachypnea': false,
        'apnea': false,
        'ventilatorMode': '',
        'PaO2': '',
        'FiO2': '',
        'PEEP': '',
        'SPO2': '',
        'respiratorySuctioning': false,
        'increaseSecretions': false,
        'newSputum': false,
        'changeSputum': false,
        'raleWheezing': false,
        'urinaryUrgency': false,
        'urinaryFrequency': false,
        'urinaryDysuria': false,
        'bloodTenderness': false,
        'bloodErythema': false,
        'diarrhea': false
      });
    });
  }

  // Function to handle input changes
  void _handleInputChange(int dayIndex, String field, dynamic value) {
    setState(() {
      daysData[dayIndex][field] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _addNewDay(); // Initialize with one day's data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PART-B Form'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Add new day button
            ElevatedButton(
              onPressed: _addNewDay,
              child: Text('Add New Day'),
            ),
            // Dynamic form for each day
            for (int i = 0; i < daysData.length; i++) ...[
              // Date picker for each day
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date:'),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: daysData[i]['date'],
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        _handleInputChange(i, 'date', selectedDate);
                      }
                    },
                    child:
                        Text('${daysData[i]['date'].toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Signs & Symptoms
              Text('Signs & Symptoms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Fever (>38°C)'),
                value: daysData[i]['fever'],
                onChanged: (value) => _handleInputChange(i, 'fever', value),
              ),
              CheckboxListTile(
                title: Text('Bradycardia (<1 year age)'),
                value: daysData[i]['bradycardia'],
                onChanged: (value) =>
                    _handleInputChange(i, 'bradycardia', value),
              ),
              CheckboxListTile(
                title: Text('Tachycardia (<1 year age)'),
                value: daysData[i]['tachycardia'],
                onChanged: (value) =>
                    _handleInputChange(i, 'tachycardia', value),
              ),

              // Pneumonia
              Text('Pneumonia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Tachypnea'),
                value: daysData[i]['tachypnea'],
                onChanged: (value) => _handleInputChange(i, 'tachypnea', value),
              ),
              CheckboxListTile(
                title: Text('Apnea'),
                value: daysData[i]['apnea'],
                onChanged: (value) => _handleInputChange(i, 'apnea', value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ventilator Mode'),
                onChanged: (value) =>
                    _handleInputChange(i, 'ventilatorMode', value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'PaO2'),
                onChanged: (value) => _handleInputChange(i, 'PaO2', value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'FiO2'),
                onChanged: (value) => _handleInputChange(i, 'FiO2', value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'PEEP'),
                onChanged: (value) => _handleInputChange(i, 'PEEP', value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'SPO2'),
                onChanged: (value) => _handleInputChange(i, 'SPO2', value),
              ),

              // Respiratory suctioning frequency
              CheckboxListTile(
                title: Text('Respiratory Suctioning Frequency'),
                value: daysData[i]['respiratorySuctioning'],
                onChanged: (value) =>
                    _handleInputChange(i, 'respiratorySuctioning', value),
              ),

              // Increase secretions/suctioning requirement
              CheckboxListTile(
                title: Text('Increased Secretions/Suctioning Requirement'),
                value: daysData[i]['increaseSecretions'],
                onChanged: (value) =>
                    _handleInputChange(i, 'increaseSecretions', value),
              ),

              // Urinary Tract
              Text('Urinary Tract',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Urgency'),
                value: daysData[i]['urinaryUrgency'],
                onChanged: (value) =>
                    _handleInputChange(i, 'urinaryUrgency', value),
              ),
              CheckboxListTile(
                title: Text('Frequency'),
                value: daysData[i]['urinaryFrequency'],
                onChanged: (value) =>
                    _handleInputChange(i, 'urinaryFrequency', value),
              ),
              CheckboxListTile(
                title: Text('Dysuria'),
                value: daysData[i]['urinaryDysuria'],
                onChanged: (value) =>
                    _handleInputChange(i, 'urinaryDysuria', value),
              ),

              // Blood Stream
              Text('Blood Stream',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Localized Tenderness (Catheter Site)'),
                value: daysData[i]['bloodTenderness'],
                onChanged: (value) =>
                    _handleInputChange(i, 'bloodTenderness', value),
              ),
              CheckboxListTile(
                title: Text('Erythema'),
                value: daysData[i]['bloodErythema'],
                onChanged: (value) =>
                    _handleInputChange(i, 'bloodErythema', value),
              ),

              // Gastro-Intestinal
              Text('Gastro-Intestinal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Diarrhea'),
                value: daysData[i]['diarrhea'],
                onChanged: (value) => _handleInputChange(i, 'diarrhea', value),
              ),

              SizedBox(height: 20), // Spacing after each day input
            ],
            // Submit button
            ElevatedButton(
              onPressed: () {
                print('Form Submitted');
                // Navigate to the NextPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InvestigationPage()), // This pushes the NextPage onto the navigation stack
                );
              },
              child: Text('Next'),
            )
          ],
        ),
      ),
    );
  }
}

class InvestigationPage extends StatefulWidget {
  @override
  _InvestigationPageState createState() => _InvestigationPageState();
}

class _InvestigationPageState extends State<InvestigationPage> {
  DateTime _selectedDate = DateTime.now();

  // Method to show Date Picker and update the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        _selectedDate;

    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Microbiological Investigations'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Investigations (Cultures)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildInvestigationRow('Blood', 'Site 1', context),
            _buildInvestigationRow('Blood', 'Site 2', context),
            _buildInvestigationRow('Urine', '', context),
            _buildInvestigationRow('ET Aspiration', '', context),
            _buildInvestigationRow('BAL', '', context),
            _buildInvestigationRow('Sputum', '', context),
            _buildInvestigationRow('Pleural Fluid', '', context),
            _buildInvestigationRow('Central line Catheter Tip', '', context),
            _buildInvestigationRow('Any Other', '', context),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RadiologyLabPage()), // Replace with your page class
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a row for each investigation
  Widget _buildInvestigationRow(
      String investigationType, String site, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$investigationType Site: $site',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _buildDateField(context),
        _buildTextFormField('Culture Result'),
        _buildTextFormField('Antimicrobial Susceptibility Testing (DTP1)'),
        _buildTextFormField('DTP2'),
        SizedBox(height: 16),
      ],
    );
  }

  // Method to build DatePicker field
  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate(context); // Pass context to _selectDate method
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
              text: "${_selectedDate.toLocal()}".split(' ')[0]),
          decoration: InputDecoration(
            labelText: 'Date',
            hintText: 'Tap to select a date',
          ),
        ),
      ),
    );
  }

  // Method to build a text field for general input
  Widget _buildTextFormField(String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
    );
  }
}

class RadiologyLabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part B: Investigations'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Radiological Investigations Section
            Text('RADIOLOGICAL INVESTIGATIONS:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildTableHeader(['INVESTIGATION', 'DATE', 'FINDINGS']),
            _buildRows(1), // Adjust row count for entries

            SizedBox(height: 16),

            // Laboratory Findings Section
            Text('LABORATORY FINDINGS:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildTableHeader(['INVESTIGATION', 'DATE', 'RES']),
            _buildRows(1), // Adjust row count for entries

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
// Navigate to the DeviceAndDrugPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceAndDrugPage(),
                  ),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create table headers dynamically
  Widget _buildTableHeader(List<String> headers) {
    return Row(
      children: headers.map((header) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              header,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper to create rows for user input
  Widget _buildRows(int count) {
    return Column(
      children: List.generate(count, (index) {
        return Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter INFO',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter date',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter findings/result',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class DeviceAndDrugPage extends StatefulWidget {
  @override
  _DeviceAndDrugPageState createState() => _DeviceAndDrugPageState();
}

class _DeviceAndDrugPageState extends State<DeviceAndDrugPage> {
  // Track whether a device was inserted
  bool _isDeviceInserted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part C & D: Devices and Drugs'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Part C Header
            Text(
              'PART-C: TO BE FILLED IN CASE IF ANY OF THE BELOW DEVICES IS INSERTED IN THE PATIENT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Checkbox for device insertion
            Row(
              children: [
                Text('Any Device inserted in the Patient?'),
                Spacer(),
                Checkbox(
                  value: _isDeviceInserted,
                  onChanged: (value) {
                    setState(() {
                      _isDeviceInserted = value!;
                    });
                  },
                ),
                Text(_isDeviceInserted ? 'Yes' : 'No'),
              ],
            ),
            SizedBox(height: 16),

            // Conditionally show device table
            if (_isDeviceInserted)
              Column(
                children: [
                  Text(
                    'Enter Details for Devices:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildDeviceTable(),
                ],
              ),

            SizedBox(height: 16),

            // Part D Header
            Text(
              'PART-D: Antibiotic/Antifungal Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDrugTable(),

            SizedBox(height: 16),

            // Any Other Drug Section
            Text(
              'ANY OTHER DRUG GIVEN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter details',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Navigate to confirmation screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Device Table
  Widget _buildDeviceTable() {
    return Column(
      children: [
        _buildTableHeader([
          'EPISODE',
          'SITE OF INSERTION',
          'DATE OF INSERTION',
          'DATE OF REMOVAL',
          'DEVICE DAYS'
        ]),
        _buildDeviceInputRow(),
      ],
    );
  }

  // Drug Table
  Widget _buildDrugTable() {
    return Column(
      children: [
        _buildTableHeader([
          'Antibiotic/Antifungal',
          'Route',
          'Start Date',
          'Completion Date'
        ]),
        _buildDrugInputRow(),
      ],
    );
  }

  // Table Header Helper
  Widget _buildTableHeader(List<String> headers) {
    return Row(
      children: headers.map((header) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              header,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Device Input Row
  Widget _buildDeviceInputRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: '1',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter site',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter date',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter date',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter days',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // Drug Input Row
  Widget _buildDrugInputRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter ',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter ',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter ',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// Confirmation Screen
class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        backgroundColor: Color(0xFF005DA3),
      ),
      body: Center(
        child: Text(
          'Your response has been taken',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
