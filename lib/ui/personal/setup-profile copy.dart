import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dropdown/find_dropdown.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/step-indicator.dart';
import '../../widgets/textfield_widget.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({Key? key}) : super(key: key);

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();
  var statesKey = GlobalKey<FindDropdownState>();
  var citiesKey = GlobalKey<FindDropdownState>();

  double statusBarHeight = 5.0;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();

  int _gender = 0;

  final List<String> stateList = ['Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jammu and Kashmir','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal','Andaman and Nicobar','Chandigarh','Dadra and Nagar Haveli','Daman and Diu','Lakshadweep','Delhi','Puducherry'];

  final List<String> cityList = ['Jaipur', 'Kota', 'Alwar'];

  @override
  void initState(){
    super.initState();
    phoneNoController = TextEditingController(text : "9876543210");
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        child: ClipPath(
                          clipper: OvalClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 242.0,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 8.0), 16.0, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {

                              },
                              child: Image.asset(
                                'assets/icons/back.png',
                                width: 20.0,
                                height: 20.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 31.0,),
                            const Text(
                              Strings.setupProfile,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8.0,),
                            const Text(
                              "Step 1 : Revuer Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 14.0,),
                            StepIndicator(totalStep: 3, step: 1),
                            const SizedBox(height: 20.0,),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff2A3B53).withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: const Offset(1, 1),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xff2A3B53).withOpacity(0.08),
                                      spreadRadius: 0,
                                      blurRadius: 20.0,
                                      offset: const Offset(0, 0),
                                    )
                                  ]
                              ),
                              child: Form(
                                key: _formKey1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ClipOval(
                                                child: Image.asset(
                                                  'assets/images/dummy_avtar.png',
                                                  width: 78.0,
                                                  height: 78.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 10.0,),
                                              const Flexible(
                                                child: Text(
                                                  "Capture or select an image from gallery",
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.w400,
                                                      color: secondaryColor
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: const BoxDecoration(
                                              color: primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              'assets/icons/camera.png',
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0,),

                                    const LabelWidget(labelText: Strings.firstName),
                                    const SizedBox(height: 6.0,),
                                    CustomTextField(
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      textController: firstNameController,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                      onChanged: (value) {

                                      },
                                    ),


                                    const LabelWidget(labelText: Strings.lastName),
                                    const SizedBox(height: 6.0,),
                                    CustomTextField(
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      textController: lastNameController,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                      onChanged: (value) {

                                      },
                                    ),

                                    const LabelWidget(labelText: Strings.state),
                                    const SizedBox(height: 4.0,),
                                    FindDropdown(
                                      items: stateList,
                                      onChanged: (item) {
                                        statesKey.currentState?.setSelectedItem(<String>[]);
                                      },
                                      showSearchBox: true,
                                      backgroundColor: Colors.white,
                                      placeholder: 'Select State',
                                      label: 'Select State',
                                      labelVisible:false,
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                    ),
                                    const SizedBox(height: 15.0,),

                                    const LabelWidget(labelText: Strings.city),
                                    const SizedBox(height: 4.0,),
                                    FindDropdown(
                                      items: cityList,
                                      onChanged: (item) {
                                        citiesKey.currentState?.setSelectedItem(<String>[]);
                                      },
                                      showSearchBox: true,
                                      backgroundColor: Colors.white,
                                      placeholder: 'Select City',
                                      label: 'Select City',
                                      labelVisible:false,
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                    ),
                                    const SizedBox(height: 15.0,),

                                    const LabelWidget(labelText: Strings.dob),
                                    const SizedBox(height: 6.0,),
                                    CustomTextField(
                                      isSuffixImg: true,
                                      imgSuffixIcon: Container(
                                        margin: const EdgeInsets.only(right: 1.0),
                                        padding: const EdgeInsets.all(14.0),
                                        child: Image.asset(
                                            'assets/icons/calendar.png',
                                            width: 16.2,
                                            height: 18.0,
                                            fit: BoxFit.fill
                                        ),
                                      ),
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      textController: dobController,
                                      placeholder: 'Select Date',
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: const ColorScheme.light(
                                                  primary: primaryColor, // <-- SEE HERE
                                                  onPrimary: Colors.white, // <-- SEE HERE
                                                  onSurface: secondaryColor, // <-- SEE HERE
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    primary: secondaryColor, // button text color
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (pickedDate != null) {
                                          print(
                                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate =
                                          DateFormat('MMMM d, y').format(pickedDate);
                                          print(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          setState(() {
                                            dobController.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        } else {}

                                      },
                                    ),

                                    const LabelWidget(labelText: Strings.gender),
                                    const SizedBox(height: 6.0,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _gender = 1),
                                            child: Container(
                                              padding: const EdgeInsets.all(6.0),
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: _gender == 1 ? primaryColor : grayColor,
                                                    width: 1, //                   <--- border width here
                                                  ),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.04),
                                                      spreadRadius: 0,
                                                      blurRadius: 8.0,
                                                      offset: const Offset(0, 0),
                                                    )
                                                  ]
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/icons/male.png',
                                                      width: 18.0,
                                                      height: 18.0,
                                                      fit: BoxFit.fitWidth
                                                  ),
                                                  const SizedBox(width: 5.0,),
                                                  Text(
                                                    'Male',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight: _gender == 1 ? FontWeight.w500 : FontWeight.w400,
                                                        color: _gender == 1 ? secondaryColor : thirdColor
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _gender = 2),
                                            child: Container(
                                              padding: const EdgeInsets.all(6.0),
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: _gender == 2 ? primaryColor : grayColor,
                                                    width: 1, //                   <--- border width here
                                                  ),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.04),
                                                      spreadRadius: 0,
                                                      blurRadius: 8.0,
                                                      offset: const Offset(0, 0),
                                                    )
                                                  ]
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/icons/female.png',
                                                      width: 18.0,
                                                      height: 18.0,
                                                      fit: BoxFit.fitWidth
                                                  ),
                                                  const SizedBox(width: 5.0,),
                                                  Text(
                                                    'Female',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight: _gender == 2 ? FontWeight.w500 : FontWeight.w400,
                                                        color: _gender == 2 ? secondaryColor : thirdColor
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _gender = 3),
                                            child: Container(
                                              padding: const EdgeInsets.all(6.0),
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: _gender == 3 ? primaryColor : grayColor,
                                                    width: 1, //                   <--- border width here
                                                  ),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.04),
                                                      spreadRadius: 0,
                                                      blurRadius: 8.0,
                                                      offset: const Offset(0, 0),
                                                    )
                                                  ]
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/icons/other.png',
                                                      width: 18.0,
                                                      height: 18.0,
                                                      fit: BoxFit.fitWidth
                                                  ),
                                                  const SizedBox(width: 5.0,),
                                                  Text(
                                                    'Other',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight: _gender == 3 ? FontWeight.w500 : FontWeight.w400,
                                                        color: _gender == 3 ? secondaryColor : thirdColor
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16.0,),
                                    const Text(
                                      "Contact Info",
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    const SizedBox(height: 16.0,),

                                    const LabelWidget(labelText: Strings.emailAddress),
                                    const SizedBox(height: 6.0,),
                                    CustomTextField(
                                      textController: emailController,
                                      isSuffixImg: true,
                                      imgSuffixIcon: GestureDetector(
                                        onTap: () {

                                        },
                                        child: Container(
                                          height: 50.0,
                                          margin: const EdgeInsets.only(right: 15.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: const [
                                              Text(
                                                  "Verify Now",
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                      onChanged: (value) {

                                      },
                                    ),

                                    const LabelWidget(labelText: Strings.phoneNoLabel),
                                    const SizedBox(height: 6.0,),
                                    CustomTextField(
                                      textController: phoneNoController,
                                      isImg: true,
                                      imgIcon: Container(
                                        height: 50.0,
                                        margin: const EdgeInsets.only(left: 15.0),
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        child: const Text(
                                          '+91 ',
                                          style: TextStyle(color: secondaryColor, fontSize: 16.0, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      isSuffixImg: true,
                                      imgSuffixIcon: GestureDetector(
                                        onTap: () {

                                        },
                                        child: Container(
                                          height: 50.0,
                                          margin: const EdgeInsets.only(right: 15.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                  'assets/icons/check.png',
                                                  width: 20.0,
                                                  height: 20.0,
                                                  fit: BoxFit.fill
                                              ),
                                              const SizedBox(width: 8.0,),
                                              const Text(
                                                'Verified',
                                                style: TextStyle(color: secondaryColor, fontSize: 14.0, fontWeight: FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      boxShadowColor: Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                      onChanged: (value) {

                                      },
                                    ),

                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28.0,),
                            ButtonWidget(
                              buttonContent: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Save & Next",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0
                                    ),
                                  ),
                                  const SizedBox(width: 10.0,),
                                  Image.asset(
                                    "assets/icons/arrow-right.png",
                                    width: 22,
                                    height: 12,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                //Navigator.pushReplacementNamed(context, '/welcome');
                              },
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

}
