import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class OnboardingForm extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final String? jobId;
  final String? jobApplicationId;

  const OnboardingForm({super.key, required this.candidate, this.jobId, this.jobApplicationId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobDetailsCtrl>();
    final formKey = GlobalKey<FormState>();
    final pageController = PageController();
    final employeeName = TextEditingController(text: candidate['candidateDetails']?['name'] ?? '');
    final firstName = TextEditingController(text: candidate['candidateDetails']?['firstName'] ?? '');
    final lastName = TextEditingController(text: candidate['candidateDetails']?['lastName'] ?? '');
    final email = TextEditingController(text: candidate['candidateDetails']?['email'] ?? '');
    final workerMobileContactNumber = TextEditingController();
    final documentType = TextEditingController();
    final documentNumber = TextEditingController();
    final birthdate = TextEditingController();
    final physicalLocation = TextEditingController();
    final homeCity = TextEditingController();
    final homeState = TextEditingController();
    final homeZipCode = TextEditingController();

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Employee Onboarding',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
            ),
            elevation: 0,
            centerTitle: true,
            backgroundColor: decoration.colorScheme.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Get.close(1),
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildProgressHeader(),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildPersonalInfoPage(employeeName, firstName, lastName, email, workerMobileContactNumber, controller),
                        _buildDocumentationPage(documentType, documentNumber, birthdate),
                        _buildLocationPage(physicalLocation, homeCity, homeState, homeZipCode),
                      ],
                    ),
                  ),
                  if (!isKeyboardVisible)
                    _buildNavigationButtons(
                      pageController,
                      formKey,
                      controller,
                      candidate,
                      employeeName,
                      firstName,
                      lastName,
                      email,
                      workerMobileContactNumber,
                      documentType,
                      documentNumber,
                      birthdate,
                      physicalLocation,
                      homeCity,
                      homeState,
                      homeZipCode,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
            'Welcome ${candidate['candidateDetails']?['name'] ?? 'New Employee'}!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text('Let\'s complete your onboarding process', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          Obx(() {
            final currentStep = Get.find<JobDetailsCtrl>().currentOnboardingStep.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [_buildStepIndicator(0, currentStep, 'Personal'), _buildStepIndicator(1, currentStep, 'Documents'), _buildStepIndicator(2, currentStep, 'Location')],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, int currentStep, String label) {
    final isActive = step <= currentStep;
    final isCompleted = step < currentStep;
    return Row(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? decoration.colorScheme.primary : Colors.grey[300]),
          child: Icon(isCompleted ? Icons.check_rounded : Icons.circle, color: Colors.white, size: isCompleted ? 12 : 10),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? decoration.colorScheme.primary : Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage(
    TextEditingController employeeName,
    TextEditingController firstName,
    TextEditingController lastName,
    TextEditingController email,
    TextEditingController workerMobileContactNumber,
    JobDetailsCtrl controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Personal Information', Icons.person_rounded, [
            _buildProfileImageSection(controller),
            const SizedBox(height: 24),
            _buildFormField(employeeName, 'Full Name', Icons.person_rounded, true),
            _buildFormField(firstName, 'First Name', Icons.person_outline_rounded, true),
            _buildFormField(lastName, 'Last Name', Icons.person_outline_rounded, true),
            _buildFormField(email, 'Email Address', Icons.email_rounded, true, isEmail: true),
            _buildFormField(workerMobileContactNumber, 'Mobile Number', Icons.phone_rounded, true, keyboardType: TextInputType.phone),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentationPage(TextEditingController documentType, TextEditingController documentNumber, TextEditingController birthdate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Documentation & Identity', Icons.description_rounded, [
            _buildDropdownField(documentType, 'Document Type', Icons.description_rounded, ['Driver License', 'Passport', 'National ID', 'State ID']),
            _buildFormField(documentNumber, 'Document Number', Icons.numbers_rounded, true),
            _buildDatePickerField(birthdate, 'Date of Birth', Icons.calendar_today_rounded),
          ]),
        ],
      ),
    );
  }

  Widget _buildLocationPage(TextEditingController physicalLocation, TextEditingController homeCity, TextEditingController homeState, TextEditingController homeZipCode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Location Details', Icons.location_on_rounded, [
            _buildFormField(physicalLocation, 'Work Location', Icons.business_rounded, true),
            _buildFormField(homeCity, 'Home City', Icons.location_city_rounded, true),
            _buildFormField(homeState, 'Home State', Icons.map_rounded, true),
            _buildFormField(homeZipCode, 'Zip Code', Icons.local_post_office_rounded, true, keyboardType: TextInputType.number),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 24, color: decoration.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(JobDetailsCtrl controller) {
    return Center(
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () => controller.pickFile('profileImage'),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.image.value != null ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.grey[100],
                  border: Border.all(color: controller.image.value != null ? decoration.colorScheme.primary.withOpacity(0.3) : Colors.grey[300]!, width: 3),
                ),
                child: controller.image.value != null
                    ? ClipOval(child: Icon(Icons.person_rounded, size: 30, color: decoration.colorScheme.primary))
                    : Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text('Tap to upload your photo', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, bool isRequired, {bool isEmail = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: keyboardType == TextInputType.phone ? 10 : null,
        decoration: InputDecoration(
          counterText: "",
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (isEmail && value != null && value.isNotEmpty) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(TextEditingController controller, String label, IconData icon, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an option';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: Get.context!,
            initialDate: DateTime.now().subtract(const Duration(days: 6570)),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: decoration.colorScheme.primary)),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your date of birth';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNavigationButtons(
    PageController pageController,
    GlobalKey<FormState> formKey,
    JobDetailsCtrl controller,
    Map<String, dynamic> candidate,
    TextEditingController employeeName,
    TextEditingController firstName,
    TextEditingController lastName,
    TextEditingController email,
    TextEditingController workerMobileContactNumber,
    TextEditingController documentType,
    TextEditingController documentNumber,
    TextEditingController birthdate,
    TextEditingController physicalLocation,
    TextEditingController homeCity,
    TextEditingController homeState,
    TextEditingController homeZipCode,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Obx(() {
        final currentStep = controller.currentOnboardingStep.value;
        return Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.currentOnboardingStep.value--;
                    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: decoration.colorScheme.primary,
                    side: BorderSide(color: decoration.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Previous', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: currentStep == 0 ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (currentStep < 2) {
                    if (_validateCurrentPage(currentStep, formKey)) {
                      controller.currentOnboardingStep.value++;
                      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  } else {
                    if (formKey.currentState!.validate()) {
                      controller.startOnboarding(
                        candidateId: candidate['candidateId'],
                        jobApplicationId: jobApplicationId,
                        jobId: jobId,
                        employeeName: employeeName.text,
                        firstName: firstName.text,
                        lastName: lastName.text,
                        nonTmobileEmail: email.text,
                        workerMobileContactNumber: workerMobileContactNumber.text,
                        documentType: documentType.text,
                        documentNumber: documentNumber.text,
                        birthdate: birthdate.text,
                        physicalLocation: physicalLocation.text,
                        homeCity: homeCity.text,
                        homeState: homeState.text,
                        homeZipCode: homeZipCode.text,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: decoration.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: Icon(currentStep < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded, size: 18),
                label: Text(currentStep < 2 ? 'Next' : 'Complete Onboarding', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _validateCurrentPage(int currentStep, GlobalKey<FormState> formKey) {
    return formKey.currentState!.validate();
  }
}
